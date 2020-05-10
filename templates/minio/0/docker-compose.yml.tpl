# #####################################################################
# This is a rancher template for generating `docker-compose` files.
# Refer to Rancher docs on syntax:
# - https://rancher.com/docs/rancher/v1.6/en/cli/variable-interpolation/#templating
# - https://docs.docker.com/compose/compose-file/compose-file-v2/
# #####################################################################
version: '2'

# +++++++++++++++++++++++
# BEGIN SERVICES
# +++++++++++++++++++++++
services:
  # ************************************
  # SERVICE
  # - primary application
  # ************************************
  minio:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${minio_image}"
{{- else }}
    image: ${minio_image}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      IOBJ_RUN_MODE: ${minio_runmode}
      IOBJ_API_KEY: ${minio_key}
      IOBJ_API_SECRET: ${minio_secret}
{{- if eq .Values.minio_volcount "1" }}
      IOBJ_DISKS_RANGE: ""
{{- else }}
      IOBJ_DISKS_RANGE: "1:${minio_volcount}"
{{- end }}
{{- if eq .Values.minio_runmode "cluster" }}
      IOBJ_CLUSTER_1_BASENAME: "minio-"
      IOBJ_CLUSTER_1_PEER_INDEX_RANGE: "1:${minio_nodecount}"
      IOBJ_CLUSTER_1_PEER_DISKS_RANGE: "1:${minio_volcount}"
{{- end }}
      IOBJ_TENANT_NAME: ${minio_tenant}
      IOBJ_REGION_NAME: ${minio_region}
      IOBJ_REGION_COMMENT: "${minio_region_comment}"
      IOBJ_NORMAL_CLASS_PARITY: 2
      IOBJ_DURABLE_CLASS_PARITY: ""
      IOBJ_THROTTLE_API_REQUEST: 1600
      IOBJ_THROTTLE_TIMEOUT: 10
      IOBJ_ENABLE_BROWSER: ${minio_browser}
      IOBJ_COMPRESS_FILE: "${minio_compress_ext}"
      IOBJ_COMPRESS_MIMETYPE: "${minio_compress_mime}"
      IOBJ_DISK_USAGE_CHECK_DELAY: 10
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.minio.role: "{{ .Stack.Name }}/node"
      io.rancher.container.hostname_override: container_name
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
    # -----------------------------------
    # VOLUMES
    # - https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes
    # - specify vol name to use the specified volume
    # - just write path to create dynamic named volume
    # -----------------------------------
    volumes:
{{- range $idx, $e := atoi .Values.minio_volcount | until }}
{{-   if and (eq .Values.datavolume_backing "local") (.Values.datavolume_name) }}
      - ${datavolume_name}_{{ add1 $idx }}:/data/export{{ add1 $idx }}
{{-   else if (eq .Values.datavolume_backing "local") }}
      - /data/export{{ add1 $idx }}
{{-   else if (eq .Values.datavolume_backing "hostdir") }}
      - ${hostdir_basepath}{{ add1 $idx }}:/data/export{{ add1 $idx }}
{{-   end }}
{{- end }}
    # -----------------------------------
    # LIMIT CPU
    # - can't use `cpus` in rancher 1.6, hacking it by using the older `cpu-quota`
    # -----------------------------------
{{- if (.Values.docker_cpu_quota_limit) }}
    #cpus: ${docker_cpu_limit}
    cpu_quota: ${docker_cpu_quota_limit}
{{- end }}
    cpu_shares: ${docker_cpu_weight_limit}
    # -----------------------------------
    # LIMIT RAM
    # -----------------------------------
{{- if (.Values.docker_memory_limit) }}
    mem_limit: "${docker_memory_limit}m"
{{- end }}
{{- if (.Values.docker_memory_swap_limit) }}
    memswap_limit: "${docker_memory_swap_limit}m"
{{- end }}

# +++++++++++++++++++++++
# END SERVICES
# +++++++++++++++++++++++

# +++++++++++++++++++++++
# BEGIN VOLUMES
# +++++++++++++++++++++++

{{- if and (eq .Values.datavolume_backing "local") (.Values.datavolume_name) }}
volumes:
  # ************************************
  # VOLUME
  # - holds data
  # ************************************
{{-   range $idx, $e := atoi .Values.minio_volcount | until }}
  {{.Values.datavolume_name}}_{{add1 $idx}}:
    per_container: true
    driver: local
{{-   end }}
{{- end }}

# +++++++++++++++++++++++
# END VOLUMES
# +++++++++++++++++++++++

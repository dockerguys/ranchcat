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
{{-   if (.Values.minio_image_custom) }}
    image: "${docker_registry_name}/${minio_image_custom}"
{{-   else }}
    image: "${docker_registry_name}/${minio_image}"
{{-   end }}
{{- else }}
{{-   if (.Values.minio_image_custom) }}
    image: ${minio_image_custom}
{{-   else }}
    image: ${minio_image}
{{-   end }}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      LOS_RUN_MODE: ${minio_runmode}
      LOS_API_KEY: ${minio_key}
      LOS_API_SECRET: ${minio_secret}
{{- if eq .Values.minio_volcount "1" }}
      LOS_DISKS_RANGE: ""
{{- else }}
      LOS_DISKS_RANGE: "1:${minio_volcount}"
{{- end }}
{{- if eq .Values.minio_runmode "cluster" }}
      LOS_CLUSTER_1_BASENAME: "{{.Stack.Name }}-minio-"
      LOS_CLUSTER_1_PEER_INDEX_RANGE: "1:${minio_nodecount}"
      LOS_CLUSTER_1_PEER_DISKS_RANGE: "1:${minio_volcount}"
{{- end }}
      LOS_TENANT_NAME: ${minio_tenant}
      LOS_REGION_NAME: ${minio_region}
      LOS_REGION_COMMENT: "${minio_region_comment}"
      LOS_NORMAL_CLASS_PARITY: 2
      LOS_DURABLE_CLASS_PARITY: ""
      LOS_THROTTLE_API_REQUEST: 1600
      LOS_THROTTLE_TIMEOUT: 10
      LOS_ENABLE_BROWSER: ${minio_browser}
      LOS_COMPRESS_FILE: "${minio_compress_ext}"
      LOS_COMPRESS_MIMETYPE: "${minio_compress_mime}"
      LOS_DISK_USAGE_CHECK_DELAY: 10
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.minio.role: "{{ .Stack.Name }}/node"
      io.rancher.container.hostname_override: container_name
      # if cluster-mode, make sure only 1 container in stack is running on each host
      # https://rancher.com/docs/rancher/v1.6/en/cattle/scheduling
{{- if eq .Values.host_negative_affinity "ensure" }}
      io.rancher.scheduler.affinity:container_label_ne: io.minio.role={{ .Stack.Name }}/node
{{- else if eq .Values.host_negative_affinity "best-effort" }}
      io.rancher.scheduler.affinity:container_label_soft_ne: io.minio.role={{ .Stack.Name }}/node
{{- end }}
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
{{- if ne .Values.datavolume_backing "none" }}
    # -----------------------------------
    # VOLUMES
    # - https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes
    # - specify vol name to use the specified volume
    # - just write path to create dynamic named volume
    # -----------------------------------
    volumes:
{{-   if eq .Values.datavolume_backing "hostdir" }}
{{-     range $idx, $e := atoi .Values.minio_volcount | until }}
      - ${hostdir_basepath}{{ add1 $idx }}:/data/export{{ add1 $idx }}
{{-     end }}
{{-   else }}
{{-     if (.Values.datavolume_name) }}
{{-       range $idx, $e := atoi .Values.minio_volcount | until }}
      - ${datavolume_name}{{ add1 $idx }}:/data/export{{ add1 $idx }}
{{-       end }}
{{-     else }}
{{-       range $idx, $e := atoi .Values.minio_volcount | until }}
      - /data/export{{ add1 $idx }}
{{-       end }}
{{-     end }}
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

{{- if eq .Values.datavolume_backing "local" }}
{{-   if (.Values.datavolume_name) }}
# +++++++++++++++++++++++
# BEGIN VOLUMES
# +++++++++++++++++++++++

volumes:
  # ************************************
  # VOLUME
  # - holds data
  # ************************************
{{-     range $idx, $e := atoi .Values.minio_volcount | until }}
  {{ $.Values.datavolume_name }}{{ add1 $idx }}:
    per_container: true
    driver: local
{{-     end }}

# +++++++++++++++++++++++
# END VOLUMES
# +++++++++++++++++++++++
{{-   end }}
{{- end }}

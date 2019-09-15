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
  # - v2ray core server
  # ************************************
  v2ray:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${v2ray_image}"
{{- else }}
    image: ${v2ray_image}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      V2RAY_BUF_READV: ${v2ray_buf_readv}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.v2ray.role: "{{ .Stack.Name }}/server"
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
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
    # VOLUMES
    # - https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes
    # - specify vol name to use the specified volume
    # - just write path to create dynamic named volume
    # -----------------------------------
    volumes:
{{- if (.Values.datavolume_name) }}
      - ${datavolume_name}_conf:/etc/v2ray
{{- else }}
      - /etc/v2ray
{{- end }}
    # -----------------------------------
    # LIMIT RAM
    # -----------------------------------
{{- if (.Values.docker_memory_limit) }}
    mem_limit: "${docker_memory_limit}m"
    memswap_limit: "${docker_memory_limit}m"
{{- end }}


# +++++++++++++++++++++++
# BEGIN VOLUMES
# - stores database files
# - https://docs.docker.com/compose/compose-file/compose-file-v2/#volume-configuration-reference
# +++++++++++++++++++++++

{{- if (.Values.datavolume_name) }}
volumes:
  # ************************************
  # VOLUME
  # - holds the database
  # ************************************
  {{.Values.datavolume_name}}_conf:
{{-   if eq .Values.volume_exists "true" }}
    external: true
{{-   end }}
    driver: local
{{- end }}

# +++++++++++++++++++++++
# END VOLUMES
# +++++++++++++++++++++++

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
{{-   if (.Values.v2ray_image_custom) }}
    image: "${docker_registry_name}/${v2ray_image_custom}"
{{-   else }}
    image: "${docker_registry_name}/${v2ray_image}"
{{-   end }}
{{- else }}
{{-   if (.Values.v2ray_image_custom) }}
    image: ${v2ray_image_custom}
{{-   else }}
    image: ${v2ray_image}
{{-   end }}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      V2RAY_CLIENT_DEFAULT_GUID: ${v2ray_default_client_guid}
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
    # LIMIT RAM
    # -----------------------------------
{{- if (.Values.docker_memory_limit) }}
    mem_limit: "${docker_memory_limit}m"
    memswap_limit: "${docker_memory_limit}m"
{{- end }}

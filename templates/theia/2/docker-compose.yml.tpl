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
  webstudio:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
{{-   if (.Values.theia_image_custom) }}
    image: "${docker_registry_name}/${theia_image_custom}"
{{-   else }}
    image: "${docker_registry_name}/${theia_image}"
{{-   end }}
{{- else }}
{{-   if (.Values.theia_image_custom) }}
    image: ${theia_image_custom}
{{-   else }}
    image: ${theia_image}
{{-   end }}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
{{- if eq .Values.runas_root "true" }}
      WEBSTUDIO_RUNAS_ROOT: "yes"
{{- else }}
      WEBSTUDIO_RUNAS_ROOT: "no"
{{- end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.theia.role: "{{ .Stack.Name }}/ide"
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
{{- if (.Values.datavolume_name) }}
      - ${datavolume_name}:${datavolume_mount_path}
{{- else }}
      - ${datavolume_mount_path}
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

{{- if (.Values.datavolume_name) }}
volumes:
  {{.Values.datavolume_name}}:
    external: true
{{-   if eq .Values.datavolume_storage_driver "rancher-nfs" }}
    driver: rancher-nfs
{{-   else }}
    driver: local
{{-   end }}
{{- end }}

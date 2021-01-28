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
  # - speedbench
  # ************************************
  speedbench:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
{{-   if (.Values.speedbench_image_custom) }}
    image: "${docker_registry_name}/${speedbench_image_custom}"
{{-   else }}
    image: "${docker_registry_name}/${speedbench_image}"
{{-   end }}
{{- else }}
{{-   if (.Values.speedbench_image_custom) }}
    image: ${speedbench_image_custom}
{{-   else }}
    image: ${speedbench_image}
{{-   end }}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      SPEEDBENCH_LOG_VERBOSE: "${speedbench_verbose}"
      SPEEDBENCH_ENABLE_METRICS: "${speedbench_metrics}"
      SPEEDBENCH_MAX_TOKENS: "${speedbench_tokens}"
      SPEEDBENCH_INFO_REGION: "${speedbench_region}"
      SPEEDBENCH_INFO_DATAZONE: "${speedbench_datazone}"
      SPEEDBENCH_INFO_ISP: "${speedbench_isp}"
      SPEEDBENCH_MAX_TOKENS: "${speedbench_tokens}"
      SPEEDBENCH_INFO_IPV6_ENABLED: "${speedbench_ipv6}"
      SPEEDBENCH_INFO_IPV4_ENABLED: true
      SPEEDBENCH_ENABLE_SSL: false
      SPEEDBENCH_SHUTDOWN_GRACE: "10s"
      SPEEDBENCH_INFO_HOSTNAME: ""
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.rancher.container.hostname_override: container_name
      io.speedbench.role: "{{ .Stack.Name }}/server"
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
      io.rancher.scheduler.affinity:container_label_soft_ne: "io.speedbench.role={{ .Stack.Name }}/server"
    # -----------------------------------
    # VOLUMES
    # - https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes
    # - specify vol name to use the specified volume
    # - just write path to create dynamic named volume
    # -----------------------------------
    volumes:
{{- if (.Values.datavolume_name) }}
      - ${datavolume_name}_data:/var/run/ndt
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

# +++++++++++++++++++++++
# END SERVICES
# +++++++++++++++++++++++

# +++++++++++++++++++++++
# BEGIN VOLUMES
# +++++++++++++++++++++++

{{- if (.Values.datavolume_name) }}
volumes:
  {{.Values.datavolume_name}}_data:
{{-   if eq .Values.volume_exists "true" }}
    external: true
{{-   end }}
{{-   if eq .Values.storage_driver "rancher-nfs" }}
    driver: rancher-nfs
{{-     if eq .Values.volume_exists "false" }}
{{-       if (.Values.storage_driver_nfsopts_host) }}
    driver_opts:
      host: ${storage_driver_nfsopts_host}
      exportBase: ${storage_driver_nfsopts_export}
{{-         if eq .Values.storage_retain_volume "true" }}
      onRemove: retain
{{-         else }}
      onRemove: purge
{{-         end }}
{{-       end }}
{{-     end }}
{{-   else }}
    driver: local
{{-   end }}
{{- end }}

# +++++++++++++++++++++++
# END VOLUMES
# +++++++++++++++++++++++

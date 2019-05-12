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
  vault:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${vault_image}"
{{- else }}
    image: ${vault_image}
{{- end }}
    # -----------------------------------
    # Special privileges
    # -----------------------------------
    cap_add:
      - IPC_LOCK
{{- if ne .Values.storage_backend "file" }}
    # -----------------------------------
    # LINKS
    # -----------------------------------
{{-   if .Values.storage_backend_service }}
    external_links:
    - ${storage_backend_service}:storage
{{-   end }}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      VAULT_LOCAL_CONFIG: |
        {
          "storage":{"${storage_backend}":{ ${storage_backend_config} }},
          "ui": true,
          "listener":{"tcp":{"address":"0.0.0.0:8200","tls_disable":1}},
          "cluster_name":"${cluster_name}"
        }
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.vault.role: "{{ .Stack.Name }}/server"
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
{{- if eq .Values.storage_backend "file" }}
    # -----------------------------------
    # VOLUMES
    # - https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes
    # - specify vol name to use the specified volume
    # - just write path to create dynamic named volume
    # -----------------------------------
    volumes:
{{-   if (.Values.datavolume_name) }}
      - ${datavolume_name}_data:/vault/file
{{-   else }}
      - /vault/file
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

{{- if eq .Values.storage_backend "file" }}
{{-   if (.Values.datavolume_name) }}
volumes:
  {{.Values.datavolume_name}}_data:
{{-     if eq .Values.volume_exists "true" }}
    external: true
{{-     end }}
{{-     if eq .Values.storage_driver "rancher-nfs" }}
    driver: rancher-nfs
{{-       if eq .Values.volume_exists "false" }}
{{-         if (.Values.storage_driver_nfsopts_host) }}
    driver_opts:
      host: ${storage_driver_nfsopts_host}
      exportBase: ${storage_driver_nfsopts_export}
{{-           if eq .Values.storage_retain_volume "true" }}
      onRemove: retain
{{-           else }}
      onRemove: purge
{{-           end }}
{{-         end }}
{{-       end }}
{{-     else }}
    driver: local
{{-     end }}
{{-   end }}
{{- end }}

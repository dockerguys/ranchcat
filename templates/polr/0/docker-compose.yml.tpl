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
  polr:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${polr_image}"
{{- else }}
    image: ${polr_image}
{{- end }}
{{- if ne .Values.db_vendor "sqlite3" }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      DB_TYPE: ${db_vendor}
{{- if ne .Values.db_vendor "sqlite3" }}
      DB_HOST: "db:3306"
{{- end }}
      DB_NAME: ${db_name}
      DB_USER: ${db_username}
      DB_PASSWD: ${db_password}
    # -----------------------------------
    # Links to other containers
    # - database service as "db"
    # -----------------------------------
    external_links:
      - ${db_service}:db
{{- end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.polr.role: "{{ .Stack.Name }}/server"
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
{{- end }}
{{- if (.Values.docker_memory_swap_limit) }}
    memswap_limit: "${docker_memory_swap_limit}m"
{{- end }}

# +++++++++++++++++++++++
# END SERVICES
# +++++++++++++++++++++++

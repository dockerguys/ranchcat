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
  osticket:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${osticket_image}"
{{- else }}
    image: ${osticket_image}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      MYSQL_HOST: "db"
      MYSQL_USER: "${osticket_dbuser}"
      MYSQL_PREFIX: "ost_"
      MYSQL_DATABASE: "${osticket_dbname}"
      MYSQL_PASSWORD: "${osticket_dbpassword}"
      INSTALL_SECRET: "${install_secret}"
      INSTALL_NAME: "${brand_name}"
      INSTALL_EMAIL: "helpdesk@${brand_domain}"
      ADMIN_EMAIL: "${admin_name}@${brand_domain}"
      ADMIN_USER: "${admin_name}"
      ADMIN_PASSWORD: "${admin_password}"
      SMTP_HOST: "${smtp_host}"
      SMTP_PORT: "${smtp_port}"
      SMTP_FROM: "helpdesk@${brand_domain}"
      SMTP_USER: "${smtp_user}"
      SMTP_PASSWORD: "${smtp_password}"
      SMTP_TLS="0"
    # -----------------------------------
    # Links to other containers
    # - database service as "db"
    # -----------------------------------
    external_links:
      - ${db_service}:db
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.osticket.role: "{{ .Stack.Name }}/server"
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
    # -----------------------------------
    # Misc behavior
    # -----------------------------------
    restart: always
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

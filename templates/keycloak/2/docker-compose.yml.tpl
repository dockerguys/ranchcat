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
  keycloak:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${keycloak_image}"
{{- else }}
    image: ${keycloak_image}
{{- end }}
{{- if ne .Values.db_vendor "h2" }}
    # -----------------------------------
    # External link
    # - link to db server
    # -----------------------------------
    external_links:
      - ${db_service}:db
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      PROXY_ADDRESS_FORWARDING: true
      KEYCLOAK_HTTP_PORT: 8080
      PROXY_TERMINATE_SSL: true
      BIND: "0.0.0.0"
      KEYCLOAK_USER: ${keycloak_user}
      KEYCLOAK_PASSWORD: ${keycloak_password}
      KEYCLOAK_LOGLEVEL: ${keycloak_loglevel}
      ROOT_LOGLEVEL: ${keycloak_loglevel}
      KEYCLOAK_WELCOME_THEME: ${keycloak_theme}
      KEYCLOAK_DEFAULT_THEME: ${keycloak_theme}
      KEYCLOAK_OPERATING_MODE_CONFIG: "${keycloak_opmode_config}.xml"
{{- if eq .Values.debug_mode "true" }}
      KEYCLOAK_DEBUG_MODE: "true"
{{- end }}
{{- if and (eq .Values.keycloak_enable_feature_docker "true") (eq .Values.keycloak_enable_feature_js "true") }}
      KEYCLOAK_STARTUP_EXTARGS: "-Dkeycloak.profile.feature.docker=enabled -Dkeycloak.profile.feature.scripts=enabled ${keycloak_extarg}"
{{- else if eq .Values.keycloak_enable_feature_docker "true" }}
      KEYCLOAK_STARTUP_EXTARGS: "-Dkeycloak.profile.feature.docker=enabled ${keycloak_extarg}"
{{- else if eq .Values.keycloak_enable_feature_js "true" }}
      KEYCLOAK_STARTUP_EXTARGS: "-Dkeycloak.profile.feature.scripts=enabled ${keycloak_extarg}"
{{- else }}
      KEYCLOAK_STARTUP_EXTARGS: ${keycloak_extarg}
{{- end }}
      DB_VENDOR: ${db_vendor}
      DB_USER: ${keycloak_dbuser}
      DB_PASSWORD: ${keycloak_dbpassword}
      DB_DATABASE: ${keycloak_dbname}
      DB_ADDR: db
{{- if eq .Values.db_vendor "mysql" }}
      DB_PORT: 3306
      MYSQL_PORT_3306_TCP_ADDR: db
      MYSQL_PORT_3306_TCP_PORT: 3306
      MYSQL_ADDR: db
      MYSQL_DATABASE: ${keycloak_dbname}
      MYSQL_USER: ${keycloak_dbuser}
      MYSQL_PASSWORD: ${keycloak_dbpassword}
{{- end}}
{{- if eq .Values.db_vendor "mariadb" }}
      DB_PORT: 3306
      MARIADB_PORT_3306_TCP_ADDR: db
      MARIADB_PORT_3306_TCP_PORT: 3306
      MARIADB_ADDR: db
      MARIADB_DATABASE: ${keycloak_dbname}
      MARIADB_USER: ${keycloak_dbuser}
      MARIADB_PASSWORD: ${keycloak_dbpassword}
{{- end}}
{{- if eq .Values.db_vendor "postgres" }}
      DB_PORT: 5432
      DB_SCHEMA: ${keycloak_dbschema}"public"
      POSTGRES_PORT_5432_TCP_ADDR: db
      POSTGRES_PORT_5432_TCP_PORT: 5432
      POSTGRES_ADDR: db
      POSTGRES_DATABASE: ${keycloak_dbname}
      POSTGRES_USER: ${keycloak_dbuser}
      POSTGRES_PASSWORD: ${keycloak_dbpassword}
{{- end}}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.keycloak.role: "{{ .Stack.Name }}/server"
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
      - ${datavolume_name}_data:/opt/jboss/keycloak/standalone/data
{{- else }}
      - /opt/jboss/keycloak/standalone/data
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

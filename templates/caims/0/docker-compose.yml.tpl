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
  caims:
    # -----------------------------------
    # Image
    # - support private registry and custom image
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
{{-   if (.Values.caims_image_custom) }}
    image: "${docker_registry_name}/${caims_image_custom}"
{{-   else }}
    image: "${docker_registry_name}/${caims_image}"
{{-   end }}
{{- else }}
{{-   if (.Values.caims_image_custom) }}
    image: ${caims_image_custom}
{{-   else }}
    image: ${caims_image}
{{-   end }}
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
      CAIMS_HTTP_PORT: 8080
      PROXY_TERMINATE_SSL: true
      BIND: "0.0.0.0"
      CAIMS_USER: ${caims_user}
      CAIMS_PASSWORD: ${caims_password}
      CAIMS_LOGLEVEL: ${caims_loglevel}
      ROOT_LOGLEVEL: ${caims_loglevel}
{{- if (.Values.caims_theme) }}
      CAIMS_WELCOME_THEME: ${caims_theme}
      CAIMS_DEFAULT_THEME: ${caims_theme}
{{- end }}
      CAIMS_OPERATING_MODE_CONFIG: "${caims_opmode_config}.xml"
{{- if eq .Values.caims_opmode_config "standalone-ha" }}
      JGROUPS_DISCOVERY_PROTOCOL: JDBC_PING
      JGROUPS_DISCOVERY_PROPERTIES: datasource_jndi_name=java:jboss/datasources/CaimsDS,info_writer_sleep_time=500
{{- end }}
{{- if eq .Values.debug_mode "true" }}
      CAIMS_DEBUG_MODE: "true"
{{- end }}
{{- if and (eq .Values.caims_enable_feature_docker "true") (eq .Values.caims_enable_feature_js "true") }}
      CAIMS_STARTUP_EXTARGS: "-Dcaims.profile.feature.docker=enabled -Dcaims.profile.feature.scripts=enabled -Dcaims.profile.feature.upload_scripts=enabled ${caims_extarg}"
{{- else if eq .Values.caims_enable_feature_docker "true" }}
      CAIMS_STARTUP_EXTARGS: "-Dcaims.profile.feature.docker=enabled ${caims_extarg}"
{{- else if eq .Values.caims_enable_feature_js "true" }}
      CAIMS_STARTUP_EXTARGS: "-Dcaims.profile.feature.scripts=enabled -Dcaims.profile.feature.upload_scripts=enabled ${caims_extarg}"
{{- else }}
      CAIMS_STARTUP_EXTARGS: ${caims_extarg}
{{- end }}
      DB_VENDOR: ${db_vendor}
      DB_USER: ${caims_dbuser}
      DB_PASSWORD: ${caims_dbpassword}
      DB_DATABASE: ${caims_dbname}
      DB_ADDR: db
{{- if eq .Values.db_vendor "mysql" }}
      DB_PORT: 3306
      MYSQL_PORT_3306_TCP_ADDR: db
      MYSQL_PORT_3306_TCP_PORT: 3306
      MYSQL_ADDR: db
      MYSQL_DATABASE: ${caims_dbname}
      MYSQL_USER: ${caims_dbuser}
      MYSQL_PASSWORD: ${caims_dbpassword}
{{- end}}
{{- if eq .Values.db_vendor "mariadb" }}
      DB_PORT: 3306
      MARIADB_PORT_3306_TCP_ADDR: db
      MARIADB_PORT_3306_TCP_PORT: 3306
      MARIADB_ADDR: db
      MARIADB_DATABASE: ${caims_dbname}
      MARIADB_USER: ${caims_dbuser}
      MARIADB_PASSWORD: ${caims_dbpassword}
{{- end}}
{{- if eq .Values.db_vendor "postgres" }}
      DB_PORT: 5432
      DB_SCHEMA: ${caims_dbschema}
      POSTGRES_PORT_5432_TCP_ADDR: db
      POSTGRES_PORT_5432_TCP_PORT: 5432
      POSTGRES_ADDR: db
      POSTGRES_DATABASE: ${caims_dbname}
      POSTGRES_USER: ${caims_dbuser}
      POSTGRES_PASSWORD: ${caims_dbpassword}
{{- end}}
{{- if (.Values.caims_metrics) }}
      CAIMS_STATISTICS: ${caims_metrics}
{{- end}}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.caims.role: "{{ .Stack.Name }}/server"
      io.rancher.scheduler.affinity:container_label_ne: io.caims.role={{ .Stack.Name }}/server
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
{{-   if eq .Values.db_vendor "h2" }}
      - ${datavolume_name}_data:/opt/jboss/caims/standalone/data
{{-   end }}
      - ${datavolume_name}_theme:/opt/jboss/caims/themes
{{- else }}
{{-   if eq .Values.db_vendor "h2" }}
      - /opt/jboss/caims/standalone/data
{{-   end }}
      - /opt/jboss/caims/themes
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
{{-   if eq .Values.db_vendor "h2" }}
  # -----------------------------------
  # Data volume
  # -----------------------------------
  {{.Values.datavolume_name}}_data:
    driver: local
{{-   end }}
  # -----------------------------------
  # Theme volume
  # -----------------------------------
  {{.Values.datavolume_name}}_theme:
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

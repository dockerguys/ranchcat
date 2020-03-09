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
  # - portus front-end
  # ************************************
  portus:
    # -----------------------------------
    # Image
    # -----------------------------------
    image: opensuse/portus:2.4.3
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      # encrypt and sign sessions
      PORTUS_SECRET_KEY_BASE: ${portus_rootpasswd}
      # generate private key for JWT requests with registry
      PORTUS_KEY_PATH: /certs/registry.key
      # password of the special user -- portus
      PORTUS_PASSWORD: ${portus_dbpasswd}
      # defines the FQDN to be used. JWT token passed between Portus and the registry relies on this!
      PORTUS_MACHINE_FQDN_VALUE: ${portus_domain}
      # disable ssl to use lb ssl termination
      PORTUS_CHECK_SSL_USAGE_ENABLED: false
      # serve static using nginx by map to /srv/Portus/public
      RAILS_SERVE_STATIC_FILES: true
      # just to be sure
      CCONFIG_PREFIX: PORTUS
      # db settings
      PORTUS_DB_HOST: db
      PORTUS_DB_USERNAME: ${db_username}
      PORTUS_DB_PASSWORD: ${portus_dbpasswd}
      PORTUS_DB_DATABASE: ${db_name}
      PORTUS_DB_ADAPTER: ${db_vendor}
      PORTUS_DB_POOL: 5
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
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
      io.dockerhub.role: "{{ .Stack.Name }}/webui"
    # -----------------------------------
    # VOLUMES
    # - https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes
    # - specify vol name to use the specified volume
    # - just write path to create dynamic named volume
    # -----------------------------------
    volumes:
{{- if (.Values.datavolume_name) }}
      - ${datavolume_name}_certs:/certs
{{- else }}
      - /certs
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

  # ************************************
  # SERVICE
  # - portus background
  # ************************************
  portus-bg:
    # -----------------------------------
    # Image
    # -----------------------------------
    image: opensuse/portus:2.4.3
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      # bg container
      PORTUS_BACKGROUND: true
      # just to be sure
      CCONFIG_PREFIX: PORTUS
      # defines the FQDN to be used. JWT token passed between Portus and the registry relies on this!
      PORTUS_MACHINE_FQDN_VALUE: ${portus_domain}
      # encrypt and sign sessions
      PORTUS_SECRET_KEY_BASE: ${portus_rootpasswd}
      # generate private key for JWT requests with registry
      PORTUS_KEY_PATH: /certs/registry.key
      # password of the special user -- portus
      PORTUS_PASSWORD: ${portus_dbpasswd}
      # db settings
      PORTUS_DB_HOST: db
      PORTUS_DB_USERNAME: ${db_username}
      PORTUS_DB_PASSWORD: ${portus_dbpasswd}
      PORTUS_DB_DATABASE: ${db_name}
      PORTUS_DB_ADAPTER: ${db_vendor}
      PORTUS_DB_POOL: 5
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
      io.dockerhub.role: "{{ .Stack.Name }}/webbg"
    # -----------------------------------
    # VOLUMES
    # - https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes
    # - specify vol name to use the specified volume
    # - just write path to create dynamic named volume
    # -----------------------------------
    volumes:
{{- if (.Values.datavolume_name) }}
      - ${datavolume_name}_certs:/certs
{{- else }}
      - /certs
{{- end }}
    # -----------------------------------
    # Links to other containers
    # - database service as "db"
    # -----------------------------------
    external_links:
      - ${db_service}:db
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
    # Dependencies
    # -----------------------------------
    depends_on:
      - portus

  # ************************************
  # SERVICE
  # - main application server
  # ************************************
  registry:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${registry_image}"
{{- else }}
    image: ${registry_image}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      REGISTRY_LOG_LEVEL: warn
      REGISTRY_LOG_ACCESSLOG_DISABLED: false
      REGISTRY_STORAGE_DELETE_ENABLED: true
      REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE: /certs/registry.crt
      REGISTRY_AUTH_TOKEN_ISSUER: ${portus_domain}
      REGISTRY_AUTH_TOKEN_SERVICE: ${portus_domain}:5000
      REGISTRY_AUTH_TOKEN_REALM: http://portus:3000/v2/token
      REGISTRY_NOTIFICATIONS_ENDPOINTS: >
        - name: portus
          url: http://portus:3000/v2/webhooks/events
          timeout: 2000ms
          threshold: 5
          backoff: 1s
      REGISTRY_HTTP_SECRET: ${registry_shared_secret}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.dockerhub.role: "{{ .Stack.Name }}/registry"
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
      - ${datavolume_name}_certs:/certs
      - ${datavolume_name}_images:/var/lib/registry
{{- else }}
      - /certs
      - /var/lib/registry
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
# - stores the static files to serve
# - https://docs.docker.com/compose/compose-file/compose-file-v2/#volume-configuration-reference
# +++++++++++++++++++++++

{{- if (.Values.datavolume_name) }}
volumes:
  # ************************************
  # VOLUME
  # ************************************
  {{.Values.datavolume_name}}_images:
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

  # ************************************
  # VOLUME
  # ************************************
  {{.Values.datavolume_name}}_certs:
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

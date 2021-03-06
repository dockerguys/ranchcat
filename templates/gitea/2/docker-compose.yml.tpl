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
{{- if eq .Values.enable_redis "true" }}
  # ************************************
  # SERVICE
  # - same host affinity as nextcloud
  # - caching service for nextcloud
  # ************************************
  redis:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{-   if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${redis_image}"
{{-   else }}
    image: ${redis_image}
{{-   end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.nextcloud.role: "caching-server"
{{-   if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{-   end }}
{{-   if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{-   end }}
    # -----------------------------------
    # Misc behavior
    # -----------------------------------
    restart: always
    # -----------------------------------
    # LIMIT CPU
    # - can't use `cpus` in rancher 1.6, hacking it by using the older `cpu-quota`
    # - hardcode redis container cpu quota to 1 cpu.
    # -----------------------------------
    cpu_quota: 100000
    cpu_shares: ${docker_cpu_weight_limit}
    # -----------------------------------
    # LIMIT RAM
    # - hardcode redis container memory limit to 256m and disable swap
    # -----------------------------------
    mem_limit: "${redis_cache_size_mb}m"
    memswap_limit: "${redis_cache_size_mb}m"
{{- end }}
  # ************************************
  # SERVICE
  # - primary application
  # ************************************
  gitea:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${gitea_image}"
{{- else }}
    image: ${gitea_image}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      OPENID_OVERRIDE_DOMAIN: "${gitea_openid_domain}"
      OPENID_OVERRIDE_IP: "${gitea_openid_ip}"
      GITEA_SETUP_SKIP_DATABASE_INIT: "${skip_db_init}"
      DISABLE_REGISTRATION: "${disable_registration}"
      REQUIRE_SIGNIN_VIEW: "${view_require_signin}"
      GITEA_ATTACHMENT_MAX_SIZE: "${gitea_attachment_max_size}"
      GITEA_ATTACHMENT_MAX_FILES: "${gitea_attachment_max_files}"
{{- if eq .Values.enable_redis "true" }}
      GITEA_CACHE_ADAPTER: "redis"
      GITEA_CACHE_HOST: "network=tcp,addr=redis:6379,password=,db=0,pool_size=100,idle_timeout=180"
      GITEA_SESSION_ENGINE: "redis"
      GITEA_SESSION_ENGINE_CONNECTOR: "network=tcp,addr=redis:6379,password=,db=0,pool_size=100,idle_timeout=180"
{{- else }}
      GITEA_SESSION_ENGINE: "file"
      GITEA_SESSION_ENGINE_CONNECTOR: "/data/gitea/sessions"
{{- end }}
      UPDATE_CERT_CA_ON_START: "${renew_ca_onstart}"
      ADMIN_NAME: "${admin_name}"
      ADMIN_DEFAULT_PASSWORD: "${admin_password}"
      GITEA_DOMAIN: ${gitea_domain}
      ROOT_URL: "${gitea_public_url}"
      SECRET_KEY: ${gitea_secret}
      LFS_SECRET: ${gitea_lfs_secret}
      LOG_LEVEL: ${gitea_loglevel}
      APP_ID: ${gitea_appid}
      APP_NAME: ${gitea_appname}
      RUN_MODE: ${gitea_runmode}
      NOREPLY_ADDRESS: "noreply.${gitea_domain}"
      OPENID_REGISTRATION_WHITELIST: ${gitea_oauth_whitelist}
      DISABLE_LOCAL_REGISTRATION: ${disable_local_registration}
      SSH_DOMAIN: ${gitea_domain}
      DISABLE_SSH: ${gitea_disable_ssh}
      INSTALL_LOCK: ${gitea_install_lock}
      DB_TYPE: ${db_vendor}
{{- if eq .Values.db_vendor "mysql" }}
      DB_HOST: "db:3306"
{{- end }}
{{- if eq .Values.db_vendor "postgres" }}
      DB_HOST: "db:5432"
{{- end }}
{{- if eq .Values.db_vendor "mssql" }}
      DB_HOST: "db:1433"
{{- end }}
      DB_NAME: ${db_name}
      DB_USER: ${db_username}
      DB_PASSWD: ${db_password}
{{- if eq .Values.gitea_runmode "prod" }}
      DB_ENABLE_LOG: "false"
{{- else }}
      DB_ENABLE_LOG: "true"
{{- end }}
{{- if ne .Values.db_vendor "sqlite3" }}
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
      io.githost.role: "{{ .Stack.Name }}/server"
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
{{- if eq .Values.enable_redis "true" }}
    # -----------------------------------
    # DEPENDENCIES
    # - redis for caching
    # -----------------------------------
    depends_on:
      - redis
{{- end }}
    # -----------------------------------
    # VOLUMES
    # - https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes
    # - specify vol name to use the specified volume
    # - just write path to create dynamic named volume
    # -----------------------------------
    volumes:
{{- if (.Values.datavolume_name) }}
      - ${datavolume_name}_data:/data
{{- else }}
      - /data
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

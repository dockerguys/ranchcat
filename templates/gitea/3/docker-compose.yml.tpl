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
  # - same host affinity as gitea
  # - caching service for gitea
  # ************************************
  redis:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{-   if (.Values.docker_registry_name) }}
{{-     if (.Values.redis_image_custom) }}
    image: "${docker_registry_name}/${redis_image_custom}"
{{-     else }}
    image: "${docker_registry_name}/${redis_image}"
{{-     end }}
{{-   else }}
{{-     if (.Values.redis_image_custom) }}
    image: ${redis_image_custom}
{{-     else }}
    image: ${redis_image}
{{-     end }}
{{-   end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.githost.role: "{{ .Stack.Name }}/caching"
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
{{-   if (.Values.docker_registry_name) }}
{{-     if (.Values.gitea_image_custom) }}
    image: "${docker_registry_name}/${gitea_image_custom}"
{{-     else }}
    image: "${docker_registry_name}/${gitea_image}"
{{-     end }}
{{-   else }}
{{-     if (.Values.gitea_image_custom) }}
    image: ${gitea_image_custom}
{{-     else }}
    image: ${gitea_image}
{{-     end }}
{{-   end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      GITEA_DISABLE_SSH: true
      GITEA_SSH_DOMAIN: "${gitea_domain}"
      GITEA_NOREPLY_ADDRESS: "noreply.${gitea_domain}"
{{- if eq .Values.enable_redis "true" }}
      GITEA_CACHE_ENABLED: true
      GITEA_CACHE_ADAPTER: "redis"
      GITEA_CACHE_HOST: "network=tcp,addr=redis:6379,password=,db=0,pool_size=100,idle_timeout=180"
      GITEA_SESSION_BACKEND: "redis"
      GITEA_SESSION_BACKEND_CONN_STR: "network=tcp,addr=redis:6379,password=,db=0,pool_size=100,idle_timeout=180"
{{- else }}
      GITEA_CACHE_ENABLED: true
      GITEA_CACHE_ADAPTER: "memory"
      GITEA_SESSION_BACKEND: "file"
      GITEA_SESSION_BACKEND_CONN_STR: "/data/gitea/sessions"
{{- end }}
      # administrative
      GITEA_ADMIN_NAME: "${admin_name}"
      GITEA_ADMIN_DEFAULT_PASSWORD: "${admin_password}"
      GITEA_SECRET_KEY: "${gitea_secret}"
{{- if eq .Values.skip_fsperm_check "true" }}
      GITEA_SKIP_FS_CHECK: "yes"
{{- else }}
      GITEA_SKIP_FS_CHECK: "no"
{{- end }}
      GITEA_RUN_MODE: "${gitea_runmode}"
      GITEA_INSTALL_LOCK: ${gitea_install_lock}
      GITEA_METRICS_TOKEN: "${metrics_token}"
      GITEA_REVERSE_PROXY_CIDR: "${reverse_proxy_cidr}"
      GITEA_REVERSE_PROXY_LIMIT: ${reverse_proxy_limit}
      GITEA_DOMAIN: "${gitea_domain}"
      GITEA_ROOT_URL: "${gitea_public_url}"
      GITEA_SWAGGER_ENABLE: ${enable_swagger}
      GITEA_DISABLE_STARS: ${disable_stars}
      GITEA_ENABLE_REPO_ORPHAN_ADOPT: ${enable_adopt_repos}
      GITEA_ORG_DISABLE_CREATE: ${disable_create_org}
      GITEA_DISABLE_MIGRATE: ${disable_migrate}
      GITEA_DISABLE_MIRROR: ${disable_mirror}
      GITEA_DEFAULT_LICENSE: ${default_license}
      GITEA_DISABLE_REPO_FEATURE: ${disable_repo_features}
      # server limits
      GITEA_ENABLE_UPLOAD: true
      GITEA_UPLOAD_MAX_FILES: ${max_upload_files}
      GITEA_UPLOAD_MAX_FILE_SIZE: ${max_upload_size}
      GITEA_ATTACHMENT_MAX_SIZE: ${max_upload_size}
      GITEA_ATTACHMENT_MAX_FILES: ${max_upload_files}
      GITEA_MIGRATE_MAX_ATTEMPTS: ${migrate_max_attempts}
      GITEA_MIGRATE_WHITELIST: ${migrate_whitelist}
      GITEA_MIGRATE_BLACKLIST: ${migrate_blacklist}
      GITEA_MIRROR_MIN_INTERVAL: "${mirror_min_interval}m"
      GITEA_CRON_MIRROR_UPDATE_FREQ: "${mirror_min_interval}m"
      GITEA_MAX_REPOS: ${max_repos}
      GITEA_PR_QUEUE: ${pr_max_queue}
      GITEA_MIRROR_QUEUE: ${mirror_max_queue}
      GITEA_INDEXER_MAX_FILE_SIZE: ${indexer_max_file_size}
      # webpage
      GITEA_APP_ID: "${gitea_appid}"
      GITEA_APP_NAME: "${gitea_appname}"
      GITEA_SHOW_MAX_FILE_SIZE: ${render_file_size}
      GITEA_SHOW_CSV_MAX_FILE_SIZE: ${render_csv_size}
      GITEA_THEME_COLOR: "${gitea_theme_color}"
      GITEA_HOME_AUTHOR: "${gitea_appname}"
      GITEA_HOME_KEYWORDS: "${www_keywords}"
      GITEA_HOME_DESCRIPTION: "${gitea_description}"
      GITEA_HOME_SHOW_BRANDING: ${www_branding}
      GITEA_HOME_SHOW_VERSION: ${www_version}
      GITEA_HOME_SHOW_TEMPLATE_RENDER_TIME: ${www_render_time}
      # security
      OPENID_REGISTER_WHITELIST: "${oauth_whitelist}"
      OPENID_OVERRIDE_DOMAIN: "${openid_domain}"
      OPENID_OVERRIDE_IP: "${openid_ip}"
      GITEA_COOKIE_EXPIRE_DAYS: ${cookie_expire_days}
      GITEA_PASSWORD_MIN_LENGTH: ${min_password_length}
      GITEA_REQUIRE_SIGNIN: ${view_require_signin}
      GITEA_REGISTER_DISABLED: ${disable_registration}
      GITEA_LOCAL_REGISTER_DISABLED: ${disable_local_registration}
      GITEA_DELETE_TEMP_USER_COMMENT: "${temp_user_period}m"
      # LFS
      LFS_ENABLED: ${lfs_enabled}
      LFS_SECRET: "${lfs_secret}"
      LFS_MAX_SIZE: ${lfs_max_size}
{{- if eq .Values.lfs_backend "local" }}
      LFS_BACKEND: local
      GITEA_ATTACHMENT_BACKEND: "local"
{{- else }}
      LFS_BACKEND: minio
      GITEA_ATTACHMENT_BACKEND: "minio"
      LFS_S3_USERID: "${s3_userid}"
      LFS_S3_SECRET: "${s3_secret}"
      LFS_S3_BUCKET: "${s3_bucket}"
      LFS_S3_REGION: "${s3_region}"
{{- end }}
{{- if eq .Values.lfs_backend "s3" }}
      LFS_S3_ENDPOINT: "${s3_endpoint}"
      LFS_S3_SERVE_DIRECT: ${s3_serve_direct}
{{- end }}
{{- if eq .Values.lfs_backend "s3compat" }}
      LFS_S3_SERVE_DIRECT: false
      LFS_S3_ENDPOINT: "s3"
{{- end }}
      # database
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
      DB_SSL: false
      DB_SCHEMA: ${db_schema}
      DB_SQLITE_TIMEOUT: ${db_sqlite_timeout}
      DB_ITERATE_BUFFER_SIZE: ${db_iterate_buffer}
{{- if eq .Values.gitea_runmode "prod" }}
      DB_ENABLE_LOG: false
{{- else }}
      DB_ENABLE_LOG: true
{{- end }}
{{- if eq .Values.skip_db_init "true" }}
      GITEA_INSTALL_SKIP_DBINIT: "yes"
{{- else }}
      GITEA_INSTALL_SKIP_DBINIT: "no"
{{- end }}
      # logging
	    GITEA_LOG_LEVEL: "${gitea_loglevel}"
{{- if eq .Values.gitea_runmode "prod" }}
	    GITEA_LOG_STACKTRACE: "Error"
{{- else }}
	    GITEA_LOG_STACKTRACE: "Warn"
{{- end }}
{{- if or (ne .Values.db_vendor "sqlite3") (eq .Values.lfs_backend "s3compat") }}
    # -----------------------------------
    # Links to other containers
    # - database service as "db"
    # -----------------------------------
    external_links:
{{-   if ne .Values.db_vendor "sqlite3" }}
      - ${db_service}:db
{{-   end }}
{{-   if eq .Values.lfs_backend "s3compat" }}
      - ${s3_service}:s3
{{-   end }}
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

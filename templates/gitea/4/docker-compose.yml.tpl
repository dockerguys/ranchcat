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
{{- if eq .Values.skip_fsperm_check "true" }}
      GITEA_SKIP_FS_CHECK: yes
{{- else }}
      GITEA_SKIP_FS_CHECK: no
{{- end }}
      # openid
      OPENID_REGISTER_WHITELIST: "${oauth_whitelist}"
      OPENID_OVERRIDE_DOMAIN: "${openid_domain}"
      OPENID_OVERRIDE_IP: "${openid_ip}"
      # LFS
      LFS_ENABLED: ${lfs_enable}
      LFS_SECRET: "${lfs_secret}"
      LFS_MAX_SIZE: ${lfs_max_size}
{{- if eq .Values.storage_backend "local" }}
      GITEA_ATTACHMENT_BACKEND: "local"
      GITEA_AVATAR_BACKEND: "local"
      GITEA_REPO_AVATAR_BACKEND: "local"
      LFS_BACKEND: local
{{- else }}
      GITEA_ATTACHMENT_BACKEND: "minio"
      GITEA_AVATAR_BACKEND: "minio"
      GITEA_REPO_AVATAR_BACKEND: "minio"
      LFS_BACKEND: minio
      LFS_S3_USERID: "${s3_userid}"
      LFS_S3_SECRET: "${s3_secret}"
      LFS_S3_BUCKET: "${s3_bucket}"
      LFS_S3_REGION: "${s3_region}"
{{- end }}
{{- if eq .Values.storage_backend "s3" }}
      LFS_S3_ENDPOINT: "${s3_endpoint}"
      LFS_S3_SERVE_DIRECT: ${s3_serve_direct}
      LFS_S3_SSL: ${s3_enable_ssl}
{{- end }}
{{- if eq .Values.storage_backend "s3compat" }}
      LFS_S3_SERVE_DIRECT: false
      LFS_S3_ENDPOINT: "s3"
      LFS_S3_SSL: true
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
      DB_MAX_IDLE_CONNS: ${db_max_idle_conn}
      DB_MAX_OPEN_CONNS: ${db_max_open_conn}
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
      # git settings
      GIT_TIMEOUT_DEFAULT: ${git_timeout_default}
      GIT_TIMEOUT_MIGRATE: ${git_timeout_migrate}
      GIT_TIMEOUT_MIRROR: ${git_timeout_mirror}
      GIT_TIMEOUT_CLONE: ${git_timeout_clone}
      GIT_TIMEOUT_PULL: ${git_timeout_pull}
      GIT_TIMEOUT_GC: ${git_timeout_gc}
      GIT_LARGE_OBJECT_THRESHOLD: ${git_lo_threshold}
      # os level settings
{{- if eq .Values.skip_fsperm_check "true" }}
      GITEA_SKIP_FS_CHECK: "yes"
{{- else }}
      GITEA_SKIP_FS_CHECK: "no"
{{- end }}
      # cache session and issue indexer queue will use redis if enabled
      # note that "issue indexer queue" is not the same as "issue indexer"!
{{- if eq .Values.enable_redis "true" }}
      GITEA_CACHE_ENABLED: true
      GITEA_CACHE_ADAPTER: "redis"
      GITEA_CACHE_HOST: "redis://redis:6379/0?pool_size=100&idle_timeout=180s"
      GITEA_SESSION_BACKEND: "redis"
      GITEA_SESSION_BACKEND_CONNSTR: "redis://redis:6379/0?pool_size=100&idle_timeout=180s"
      GITEA_ISSUE_INDEXER_QUEUE_TYPE: "redis"
      GITEA_ISSUE_INDEXER_QUEUE_CONNSTR: "redis://redis:6379/0?pool_size=100&idle_timeout=180s"
{{- else }}
      GITEA_CACHE_ENABLED: true
      GITEA_CACHE_ADAPTER: "memory"
      GITEA_SESSION_BACKEND: "file"
      GITEA_SESSION_BACKEND_CONNSTR: "/data/gitea/sessions"
      GITEA_ISSUE_INDEXER_QUEUE_TYPE: "persistable-channel"
{{- end }}
      # queues
      GITEA_QUEUE_TYPE: "persistable-channel"
      GITEA_QUEUE_SIZE: 20
      GITEA_QUEUE_BATCH_SIZE: 20
      GITEA_QUEUE_MAX_WORKERS: 10
      GITEA_QUEUE_BLOCK_TIMEOUT: "1s"
      GITEA_QUEUE_BOOST_TIMEOUT: "5m"
      GITEA_QUEUE_BOOST_WORKERS: 1
      GITEA_ISSUE_INDEXER_QUEUE_SIZE: 20
      GITEA_ISSUE_INDEXER_QUEUE_BATCH_SIZE: 20
      GITEA_MIRROR_QUEUE_SIZE: ${mirror_max_queue}
      GITEA_PR_QUEUE_SIZE: ${pr_max_queue}
      GITEA_MAILER_QUEUE_SIZE: 100
      # indexer: todo support elasticsearch
      GITEA_INDEXER_STARTUP_TIMEOUT: "30s"
      GITEA_INDEXER_MAX_FILE_SIZE: ${indexer_max_file_size}
{{- if (.Values.elasticsearch_service) }}
      GITEA_ISSUE_INDEXER_TYPE: "elasticsearch"
      GITEA_ISSUE_INDEXER_NAME: "gitea_issues"
      GITEA_ISSUE_INDEXER_CONNSTR: "http://${elasticsearch_user}@elasticsearch:9200"
{{- else }}
      GITEA_ISSUE_INDEXER_TYPE: bleve
      GITEA_ISSUE_INDEXER_NAME: ""
      GITEA_ISSUE_INDEXER_CONNSTR: ""
{{- end }}
{{- if eq .Values.enable_search_code "true" }}
      GITEA_CODE_INDEXER_ENABLED: true
      GITEA_CODE_INDEXER_INCLUDE: "${code_search_include}"
      GITEA_CODE_INDEXER_EXCLUDE: "${code_search_exclude}"
{{- if (.Values.elasticsearch_service) }}
      GITEA_CODE_INDEXER_TYPE: "elasticsearch"
      GITEA_CODE_INDEXER_CONNSTR: "http://${elasticsearch_user}@elasticsearch:9200"
{{-   else }}
      GITEA_CODE_INDEXER_TYPE: "bleve"
      GITEA_CODE_INDEXER_CONNSTR: ""
{{-   end }}
{{- else }}
      GITEA_CODE_INDEXER_ENABLED: false
{{- end }}
      # logging
      GITEA_LOG_LEVEL: "${gitea_loglevel}"
      GITEA_ENABLE_ACCESS_LOG: "${gitea_access_log}"
{{- if eq .Values.gitea_runmode "prod" }}
      GITEA_LOG_STACKTRACE: "Error"
{{- else }}
      GITEA_LOG_STACKTRACE: "Warn"
      GITEA_ENABLE_DB_LOG: true
{{- end }}
      # cron
      GITEA_CRON_MIRROR_UPDATE_FREQ: "${mirror_min_interval}m"
      GITEA_CRON_SYNC_EXTERNAL_USERS_ABSOLUTE: true
      GITEA_CRON_SYNC_EXTERNAL_USERS_FREQ: "${external_user_sync_interval}h"
      GITEA_CRON_UPDATE_MIGRATE_POSTER_ID_FREQ: "24h"
      GITEA_CRON_CLEAN_ARCHIVE_FREQ: "24h"
      GITEA_CRON_CLEAN_ARCHIVE_MAX_AGE: "24h"
      GITEA_CRON_REPO_HEALTHCHECK_FREQ: "24h"
      GITEA_CRON_REPO_STAT_FREQ: "24h"
      GITEA_CRON_CLEANUP_HOOK_TASKS_METHOD: "OlderThan"
      GITEA_CRON_CLEANUP_HOOK_TASKS_MAX_AGE: "168h"
      GITEA_CRON_CLEANUP_HOOK_TASKS_MAX_KEEP: "10"
      GITEA_CRON_CLEANUP_HOOK_TASKS_FREQ: "24h"
      GITEA_CRON_GC_REPOS: false
      GITEA_CRON_DELETE_INACTIVE_ACCOUNTS: false
      GITEA_CRON_DELETE_REPO_ARCHIVES: false
      GITEA_CRON_RESYNC_ALL_HOOKS: false
      GITEA_CRON_REINIT_MISSING_REPOS: false
      GITEA_CRON_DELETE_MISSING_REPOS: false
      GITEA_CRON_DELETE_GENERATED_REPO_AVATARS: false
      GITEA_CRON_DELETE_OLD_ACTIONS: false
      # attachment, uploads and release
{{- if eq .Values.max_upload_size "0" }}
      GITEA_ENABLE_UPLOAD: false
      GITEA_ATTACHMENT_ENABLED: false
{{- else }}
      GITEA_ENABLE_UPLOAD: true
      GITEA_UPLOAD_MAX_FILES: ${max_upload_files}
      GITEA_UPLOAD_MAX_FILE_SIZE: ${max_upload_size}
      GITEA_UPLOAD_MIMETYPE: "${upload_mimetypes}"
      GITEA_RELEASE_MIMETYPE: "${upload_mimetypes}"
      GITEA_ATTACHMENT_ENABLED: true
      GITEA_ATTACHMENT_MAX_SIZE: ${max_upload_size}
      GITEA_ATTACHMENT_MAX_FILES: ${max_upload_files}
      GITEA_ATTACHMENT_MIMETYPES: "${upload_mimetypes}"
{{- end }}
      # mirror and migrate
{{- if eq .Values.mirror_feature "Enable" }}
      GITEA_ENABLE_MIRROR: true
      GITEA_MIRROR_DISABLE_PULL: false
      GITEA_MIRROR_DISABLE_PUSH: false
{{- else if eq .Values.mirror_feature "Disable" }}
      GITEA_ENABLE_MIRROR: false
      GITEA_MIRROR_DISABLE_PULL: false
      GITEA_MIRROR_DISABLE_PUSH: false
{{- else if eq .Values.mirror_feature "NoPush" }}
      GITEA_ENABLE_MIRROR: true
      GITEA_MIRROR_DISABLE_PULL: false
      GITEA_MIRROR_DISABLE_PUSH: true
{{- else if eq .Values.mirror_feature "NoPull" }}
      GITEA_ENABLE_MIRROR: true
      GITEA_MIRROR_DISABLE_PULL: false
      GITEA_MIRROR_DISABLE_PUSH: false
{{- end }}
      GITEA_MIRROR_DEFAULT_INTERVAL: "8h"
      GITEA_MIRROR_MIN_INTERVAL: "${mirror_min_interval}m"
{{- if eq .Values.migrate_feature "Enable" }}
      GITEA_DISABLE_MIGRATE: false
      GITEA_MIGRATE_ALLOW_LAN: true
{{- else if eq .Values.migrate_feature "NoLAN" }}
      GITEA_DISABLE_MIGRATE: false
      GITEA_MIGRATE_ALLOW_LAN: false
{{- else }}
      GITEA_DISABLE_MIGRATE: true
      GITEA_MIGRATE_ALLOW_LAN: false
{{- end }}
      GITEA_MIGRATE_MAX_ATTEMPTS: ${migrate_max_attempts}
      GITEA_MIGRATE_WHITELIST: ${migrate_whitelist}
      GITEA_MIGRATE_BLACKLIST: ${migrate_blacklist}
      GITEA_MIGRATE_RETRY_BACKOFF: 3
      # email
{{- if (.Values.email_host) }}
      GITEA_ENABLE_MAILER: true
      GITEA_MAILER_TYPE: smtp
      GITEA_MAILER_HOST: "${email_host}"
      GITEA_MAILER_USER: "${email_account_user}"
      GITEA_MAILER_PASSWORD: "${email_account_password}"
      GITEA_MAILER_FROM: "${email_from}"
      GITEA_MAILER_SUBJECT_PREFIX: "${email_subject_prefix}"
{{- else }}
      GITEA_ENABLE_MAILER: false
{{- end }}
      GITEA_NOREPLY_ADDRESS: "noreply.${gitea_domain}"
      GITEA_NOTIFY_EMAIL_DEFAULT: "onmention"
      # ssh
      GITEA_DISABLE_SSH: true
      GITEA_SSH_DOMAIN: "${gitea_domain}"
      # metrics
      GITEA_METRICS_TOKEN: "${metrics_token}"
      GITEA_ENABLE_PPROF: ${enable_pprof}
      # sign repo
      GITEA_REPO_SIGN_KEY: "default"
      GITEA_REPO_SIGN_INIT_COMMIT: "pubkey"
      GITEA_REPO_SIGN_CRUD_ACTIONS: "pubkey,parentsigned"
      GITEA_REPO_SIGN_MERGES: "pubkey,basesigned,commitssigned"
      # http
      GITEA_DOMAIN: "${gitea_domain}"
      GITEA_ROOT_URL: "${gitea_public_url}"
      GITEA_REVERSE_PROXY_CIDR: "${reverse_proxy_cidr}"
      GITEA_REVERSE_PROXY_LIMIT: ${reverse_proxy_limit}
      GITEA_CORS_ACAO: "${cors_acao}"
      GITEA_ENABLE_HTTP_GZIP: ${enable_http_gzip}
      GITEA_DISABLE_HTTP_GIT: false
      # kanban
      GITEA_PROJECT_BOARD_KANBAN_TYPE: "To Do, In Progress, Done"
      GITEA_PROJECT_BOARD_TRIAGE_TYPE: "Needs Triage, High Priority, Low Priority, Closed"
      # explore
{{- if eq .Values.explore_feature "Disable" }}
      GITEA_EXPLORE_DISABLED: true
      GITEA_EXPLORE_REQUIRE_SIGNIN: true
{{- else if eq .Values.explore_feature "MustLogin" }}
      GITEA_EXPLORE_DISABLED: false
      GITEA_EXPLORE_REQUIRE_SIGNIN: true
{{- else }}
      GITEA_EXPLORE_DISABLED: false
      GITEA_EXPLORE_REQUIRE_SIGNIN: false
{{- end }}
      GITEA_EXPLORE_PAGINATE: ${explore_paginate}
      # api
      GITEA_SWAGGER_ENABLE: ${enable_swagger}
      GITEA_API_TOKEN_HASH_CACHE: ${api_token_hash_cache}
      GITEA_API_DEFAULT_GIT_TREES_PAGINATE: 1000
      GITEA_API_DEFAULT_MAX_BLOB_SIZE: 10485760
      # login and register
      GITEA_LOCAL_REGISTER_DISABLED: ${disable_local_registration}
      GITEA_REGISTER_DISABLED: ${disable_registration}
      GITEA_REQUIRE_SIGNIN: ${view_require_signin}
      GITEA_PASSWORD_MIN_LENGTH: ${min_password_length}
      GITEA_COOKIE_EXPIRE_DAYS: ${cookie_expire_days}
      GITEA_DELETE_TEMP_USER_COMMENT: "${temp_user_period}m"
      GITEA_PASSWORD_COMPLEXITY: "lower,digit"
      GITEA_LOCAL_REGISTER_ONLY: false
      # administrative
      GITEA_ADMIN_NAME: "${admin_name}"
      GITEA_ADMIN_DEFAULT_PASSWORD: "${admin_password}"
      GITEA_SECRET_KEY: "${gitea_secret}"
      GITEA_RUN_MODE: "${gitea_runmode}"
      GITEA_ENABLE_FEDERATION: ${gitea_federation}
      GITEA_DISABLE_STARS: ${disable_stars}
      GITEA_ENABLE_REPO_ORPHAN_ADOPT: ${enable_adopt_repos}
      GITEA_ORG_DISABLE_CREATE: ${disable_create_org}
      GITEA_DISABLE_REPO_FEATURE: "${disable_repo_features}"
      GITEA_DEFAULT_LICENSE: "${default_license}"
      GITEA_APP_ID: "${gitea_appid}"
      GITEA_MAX_REPOS: ${max_repos}
      GITEA_INSTALL_LOCK: ${gitea_install_lock}
      GITEA_ISSUE_LOCK_REASON: "${issue_lock_reasons}"
      GITEA_GRACEFUL_STOP_TIMEOUT: "${gitea_graceful_stop_timeout}s"
      # webpage
      GITEA_APP_NAME: "${gitea_appname}"
      GITEA_HOME_DESCRIPTION: "${gitea_description}"
      GITEA_SHOW_MAX_FILE_SIZE: ${render_file_size}
      GITEA_SHOW_CSV_MAX_FILE_SIZE: ${render_csv_size}
      GITEA_THEME_COLOR: "${gitea_theme_color}"
      GITEA_HOME_KEYWORDS: "${www_keywords}"
      GITEA_HOME_SHOW_BRANDING: ${www_show_branding}
      GITEA_HOME_SHOW_VERSION: ${www_show_version}
      GITEA_HOME_SHOW_TEMPLATE_RENDER_TIME: ${www_show_render_time}
      GITEA_HOME_AUTHOR: "${gitea_appname}"
      GITEA_EMOJI_REACTIONS: "${gitea_reaction_emojis}"
      GITEA_CUSTOM_EMOJIS: "${gitea_custom_emojis}"
{{- if or (ne .Values.db_vendor "sqlite3") (eq .Values.storage_backend "s3compat") (.Values.elasticsearch_service) }}
    # -----------------------------------
    # Links to other containers
    # - database service as "db"
    # - s3 service as "s3"
    # - elasticsearch service as "elasticsearch"
    # -----------------------------------
    external_links:
{{-   if ne .Values.db_vendor "sqlite3" }}
      - ${db_service}:db
{{-   end }}
{{-   if eq .Values.storage_backend "s3compat" }}
      - ${s3_service}:s3
{{-   end }}
{{-   if (.Values.elasticsearch_service) }}
      - ${elasticsearch_service}:elasticsearch
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

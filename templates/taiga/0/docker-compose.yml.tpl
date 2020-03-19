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
  # - rancher loadbalancer (internal)
  # ************************************
  lbs:
    image: rancher/lb-service-haproxy
  labels:
    io.taiga.role: "{{ .Stack.Name }}/lbs"
  # ************************************
  # SERVICE
  # - same host affinity as backend
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
      io.taiga.role: "{{ .Stack.Name }}/caching"
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

  # ************************************
  # SERVICE
  # - sql
  # ************************************
  pgsql:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${pgsql_image}"
{{- else }}
    image: ${pgsql_image}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      POSTGRES_PASSWORD: "${taiga_secret}"
      POSTGRES_DB: "taiga"
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.taiga.role: "{{ .Stack.Name }}/db"
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
      - /var/lib/postgresql/data
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
    # Misc behavior
    # -----------------------------------
    restart: always
    # -----------------------------------
    # LIMIT RAM
    # -----------------------------------
{{- if (.Values.docker_memory_limit) }}
    mem_limit: "${docker_memory_limit}m"
{{- end }}
{{- if (.Values.docker_memory_swap_limit) }}
    memswap_limit: "${docker_memory_swap_limit}m"
{{- end }}

  # ************************************
  # SERVICE
  # - taiga frontend
  # ************************************
  tgfront:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${taiga_frontend_image}"
{{- else }}
    image: ${taiga_frontend_image}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      TAIGA_DOMAIN_NAME: "${taiga_domain}"
{{- if eq .Values.ssl_enabled "true" }}
      TAIGA_HTTP_PROTOCOL: "https"
      TAIGA_WS_PROTOCOL: "wss"
{{- else }}
      TAIGA_HTTP_PROTOCOL: "http"
      TAIGA_WS_PROTOCOL: "ws"
{{- end }}
      TAIGA_ENABLE_DEBUG: "${taiga_debug_mode}"
      TAIGA_ENABLE_PUBLIC_REGISTER: "${taiga_enable_register}"
      TAIGA_ENABLE_GRAVATAR: "${taiga_enable_gravatar}"
      TAIGA_SUPPORT_URL: "${taiga_support_url}"
      TAIGA_TERMS_URL: "${taiga_terms_url}"
      TAIGA_PRIVACY_URL: "${taiga_privacy_url}"
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.taiga.role: "{{ .Stack.Name }}/frontend"
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
    # -----------------------------------
    # DEPENDENCIES
    # - redis for caching
    # -----------------------------------
    depends_on:
      - taiga
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

  # ************************************
  # SERVICE
  # - taiga backend
  # ************************************
  taiga:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${taiga_backend_image}"
{{- else }}
    image: ${taiga_backend_image}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      TAIGA_SECRET: "${taiga_secret}"
      TAIGA_DOMAIN_NAME: "${taiga_domain}"
{{- if eq .Values.ssl_enabled "true" }}
      TAIGA_HTTP_PROTOCOL: "https"
      TAIGA_WS_PROTOCOL: "wss"
{{- else }}
      TAIGA_HTTP_PROTOCOL: "http"
      TAIGA_WS_PROTOCOL: "ws"
{{- end }}
      TAIGA_DB_SERVER: "pgsql"
      TAIGA_DB_NAME: "taiga"
      TAIGA_DB_PASSWORD: "${taiga_secret}"
      TAIGA_RABBITMQ_SERVER: "rabbit"
      TAIGA_RABBITMQ_SERVER_PORT: "5672"
      TAIGA_RABBITMQ_USER: "taiga"
      TAIGA_RABBITMQ_PASSWORD: "${taiga_secret}"
      TAIGA_RABBITMQ_VHOST: "taiga"
      TAIGA_REDIS_SERVER: "redis"
      TAIGA_REDIS_PORT: "6379"
      TAIGA_REDIS_DB: 0
      TAIGA_REDIS_PASSWORD: ""
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.taiga.role: "{{ .Stack.Name }}/backend"
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
      - ${datavolume_name}_conf:/taiga/conf
      - ${datavolume_name}_media:/taiga/media
{{- else }}
      - /taiga/conf
      - /taiga/media
{{- end }}
    # -----------------------------------
    # DEPENDENCIES
    # - redis for caching
    # -----------------------------------
    depends_on:
      - pgsql
      - redis
      - rabbit
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

  # ************************************
  # SERVICE
  # - events
  # ************************************
  events:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${taiga_events_image}"
{{- else }}
    image: ${taiga_events_image}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      TAIGA_SECRET: "${taiga_secret}"
      RABBIT_HOST: "rabbit"
      RABBIT_PORT: "5672"
      RABBIT_USER: "taiga"
      RABBIT_PASSWORD: "${taiga_secret}"
      RABBIT_VHOST: "taiga"
    depends_on:
      - rabbit
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

  # ************************************
  # SERVICE
  # - rabbitmq
  # ************************************
  rabbit:
    # -----------------------------------
    # Image
    # -----------------------------------
    image: "rabbitmq:3.8-alpine"
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      RABBITMQ_DEFAULT_USER: "taiga"
      RABBITMQ_DEFAULT_PASS: "${taiga_secret}"
      RABBITMQ_DEFAULT_VHOST: taiga
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
  # -----------------------------------
  # conf volume
  # -----------------------------------
  {{.Values.datavolume_name}}_conf:
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
  # -----------------------------------
  # media volume
  # -----------------------------------
  {{.Values.datavolume_name}}_media:
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

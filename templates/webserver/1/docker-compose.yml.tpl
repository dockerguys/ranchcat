# =====================================================================
# This is a rancher template for generating `docker-compose` files.
# Refer to Rancher docs on syntax:
# - https://rancher.com/docs/rancher/v1.6/en/cli/variable-interpolation/#templating
# - https://docs.docker.com/compose/compose-file/compose-file-v2/
# =====================================================================
version: '2'

# =======================
# BEGIN SERVICES
# =======================
services:
  # ************************************
  # SERVICE
  # - sidekick to nginx
  # - init persist volume that stores the static files to serve
  # ************************************
  nginx-www:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/busybox"
{{- else }}
    image: busybox
{{- end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.rancher.container.start_once: true
    # -----------------------------------
    # Volumes
    # - supports data volumes
    # -----------------------------------
    volumes:
{{- if (.Values.datavolume_name) }}
      - ${datavolume_name}_www:/usr/html
{{- else }}
      - /usr/html
{{- end }}
    command: mkdir -p /usr/html/errors /usr/html/sites/default

  # ************************************
  # SERVICE
  # - sidekick to nginx
  # - init persist volume that stores nginx configs
  # ************************************
  nginx-conf:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/busybox"
{{- else }}
    image: busybox
{{- end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.rancher.container.start_once: true
    # -----------------------------------
    # Volumes
    # - supports data volumes
    # -----------------------------------
    volumes:
{{- if (.Values.datavolume_name) }}
      - ${datavolume_name}_conf:/etc/nginx/conf.d
{{- else }}
      - /etc/nginx/conf.d
{{- end }}

  # ************************************
  # SERVICE
  # - main application server
  # ************************************
  nginx:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${nginx_image}"
{{- else }}
    image: ${nginx_image}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      NGINX_EVENTS_MAX_CONNECTIONS: "${nginx_max_connect}"
      NGINX_ERROR_LOG_LEVEL: "${nginx_log_level}"
      NGINX_HTTP_UPLOAD_MAX_SIZE: "${nginx_upload_max_size}m"
      NGINX_HTTP_KEEPALIVE_TIMEOUT: "${nginx_keepalive_timeout}"
      NGINX_HTTP_KEEPALIVE_DISABLE: "${nginx_keepalive_disable}"
      NGINX_HTTP_KEEPALIVE_REQUESTS: "${nginx_keepalive_requests}"
{{- if eq .Values.keycloak_enable_feature_docker "true" }}
      NGINX_CONSOLE_LOG: "true"
{{- else }}
      NGINX_CONSOLE_LOG: "false"
{{- end }}
{{- if eq .Values.nginx_expose_server_version "true" }}
      NGINX_HTTP_EXPOSE_SERVER_VERSION: "on"
{{- else }}
      NGINX_HTTP_EXPOSE_SERVER_VERSION: "off"
{{- end }}
{{- if eq .Values.nginx_send_file "true" }}
      NGINX_HTTP_SEND_FILE: "on"
{{- else }}
      NGINX_HTTP_SEND_FILE: "off"
{{- end }}
{{- if eq .Values.nginx_tcp_no_push "true" }}
      NGINX_HTTP_TCP_NOPUSH: "on"
{{- else }}
      NGINX_HTTP_TCP_NOPUSH: "off"
{{- end }}
{{- if eq .Values.nginx_tcp_no_delay "true" }}
      NGINX_HTTP_TCP_NODELAY: "on"
{{- else }}
      NGINX_HTTP_TCP_NODELAY: "off"
{{- end }}
{{- if eq .Values.nginx_enable_gzip "true" }}
      NGINX_HTTP_ENABLE_GZIP: "on"
{{- else }}
      NGINX_HTTP_ENABLE_GZIP: "off"
{{- end }}
{{- if eq .Values.nginx_enable_webapi_svc "true" }}
      NGINX_ENABLE_WEBAPI_PUBLIC_SERVICES: "true"
      NGINX_WEBAPI_PUBLIC_SERVICES_PORT: "${nginx_webapi_svc_port}"
{{- else }}
      NGINX_ENABLE_WEBAPI_PUBLIC_SERVICES: "false"
{{- end }}
{{- if eq .Values.nginx_cdn_svc_port "true" }}
      NGINX_ENABLE_CDN_HOSTING: "true"
      NGINX_CDN_HOSTING_PORT: "${nginx_cdn_svc_port}"
{{- else }}
      NGINX_ENABLE_CDN_HOSTING: "false"
{{- end }}
{{- if eq .Values.nginx_cdn_svc_port "true" }}
      NGINX_ENABLE_SUBSITE_HOSTING: "true"
      NGINX_SUBSITE_HOSTING_PORT: "${nginx_subsite_svc_port}"
{{- else }}
      NGINX_ENABLE_SUBSITE_HOSTING: "false"
{{- end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.rancher.sidekicks: nginx-www, nginx-conf
      io.webserver.role: "{{ .Stack.Name }}/server"
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
    # -----------------------------------
    # VOLUMES
    # - use vols from sidekick
    # -----------------------------------
    volumes_from:
      - nginx-www
      - nginx-conf
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

# =======================
# END SERVICES
# =======================

# =======================
# BEGIN VOLUMES
# =======================

{{- if (.Values.datavolume_name) }}
volumes:
  # ************************************
  # VOLUME
  # - stores the static files to serve
  # ************************************
  {{.Values.datavolume_name}}_www:
{{-   if eq .Values.storage_driver "rancher-nfs" }}
    driver: ${storage_driver}
{{-     if (.Values.storage_driver_nfsopts_host) }}
    driver_opts: 
      host: ${storage_driver_nfsopts_host}
      exportBase: ${storage_driver_nfsopts_export}
{{-       if eq .Values.storage_retain_volume "true" }}
      onRemove: retain
{{-       end }}
{{-     end }}
{{-   else }}
    driver: local
{{-   end }}
  # ************************************
  # VOLUME
  # - stores the static files to serve
  # ************************************
  {{.Values.datavolume_name}}_conf:
{{-   if eq .Values.storage_driver "rancher-nfs" }}
    driver: ${storage_driver}
{{-     if (.Values.storage_driver_nfsopts_host) }}
    driver_opts: 
      host: ${storage_driver_nfsopts_host}
      exportBase: ${storage_driver_nfsopts_export}
{{-       if eq .Values.storage_retain_volume "true" }}
      onRemove: retain
{{-       end }}
{{-     end }}
{{-   else }}
    driver: local
{{-   end }}
{{- end }}

# =======================
# END VOLUMES
# =======================

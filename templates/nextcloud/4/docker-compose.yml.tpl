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
  # - sidekick to nextcloud
  # - init persist volume that stores /var/www/html
  # ************************************
  nextcloud-src:
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
      - ${datavolume_name}_src:/var/www/html
{{- else }}
      - /var/www/html
{{- end }}

{{- if (.Values.extra_volume_a) }}
  # ************************************
  # SERVICE
  # - sidekick to nextcloud
  # - mounts external volumes
  # ************************************
  nextcloud-extvols:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{-   if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/busybox"
{{-   else }}
    image: busybox
{{-   end }}
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
{{-   if (.Values.extra_volume_a) }}
      - ${extra_volume_a}:/var/www/${extra_volume_a}
{{-   end }}
{{- end }}

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
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${redis_image}"
{{- else }}
    image: ${redis_image}
{{- end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.nextcloud.role="caching-server"
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
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
    mem_limit: "256m"
    memswap_limit: "256m"

  # ************************************
  # SERVICE
  # - primary application
  # ************************************
  nextcloud:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${nextcloud_image}"
{{- else }}
    image: ${nextcloud_image}
{{- end }}
    # -----------------------------------
    # TTY/STDIN
    # -----------------------------------
    tty: true
    stdin_open: true
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      NEXTCLOUD_UPDATE: "1"
      DEFAULT_ADMIN: "${nextcloud_user}"
      DEFAULT_ADMIN_PASSWORD: "${nextcloud_password}"
      DATABASE_BACKEND: "${db_vendor}"
      DATABASE_HOSTNAME: "db"
      DATABASE_NAME: "${nextcloud_dbname}"
      DATABASE_USER: "${nextcloud_dbuser}"
      DATABASE_PASSWORD: "${nextcloud_dbpassword}"
      CACHING_BACKEND: "redis"
      CACHING_HOST: "redis"
      TRUSTED_DOMAINS: "localhost *"
{{- if (.Values.extra_volume_a) }}
      EXTERNAL_MOUNTPOINTS: "${extra_volume_a}"
{{- end }}
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
      io.nextcloud.role="server"
      io.rancher.sidekicks: nextcloud-src, nextcloud-www
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
      - nextcloud-src
{{- if (.Values.extra_volume_a) }}
      - nextcloud-extvols
{{- end }}
    # -----------------------------------
    # DEPENDENCIES
    # - redis for caching
    # -----------------------------------
    depends_on:
      - redis
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
    memswap_limit: "${docker_memory_swap_limit}m"

# =======================
# END SERVICES
# =======================

# =======================
# BEGIN VOLUMES
# =======================

{{- if or (.Values.datavolume_name) (.Values.extra_volume_a) }}
volumes:
{{- end }}
{{- if (.Values.datavolume_name) }}
  # ************************************
  # VOLUME
  # - holds nextcloud server data
  # ************************************
  {{.Values.datavolume_name}}_src:
{{-   if eq .Values.storage_driver "rancher-nfs" }}
    driver: ${storage_driver}
{{-     if eq .Values.volume_exists "true" }}
    external: true
{{-     end }}
{{-     if (.Values.storage_driver_nfsopts_host) }}
    driver_opts: 
      host: ${storage_driver_nfsopts_host}
      export: ${storage_driver_nfsopts_export}/${datavolume_name}_src
{{-     end }}
{{-   else }}
    driver: local
{{-     if eq .Values.volume_exists "true" }}
    external: true
{{-     end }}
{{-   end }}
{{- end }}
{{- if (.Values.extra_volume_a) }}
  # ************************************
  # VOLUME
  # - external volume 1
  # ************************************
  {{.Values.extra_volume_a}}:
{{-   if eq .Values.storage_driver "rancher-nfs" }}
    driver: ${storage_driver}
    external: true
{{-     if (.Values.storage_driver_nfsopts_host) }}
    driver_opts: 
      host: ${storage_driver_nfsopts_host}
      export: ${storage_driver_nfsopts_export}/${extra_volume_a}
{{-     end }}
{{-   else }}
    driver: local
    external: true
{{-   end }}
{{- end }}

# =======================
# END VOLUMES
# =======================

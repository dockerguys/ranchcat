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
      io.nextcloud.role: "caching-server"
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
      DATABASE_ALREADY_EXISTS: "${database_exists}"
      CACHING_BACKEND: "redis"
      CACHING_HOST: "redis"
      TRUSTED_DOMAINS: "localhost *"
{{- if (.Values.extra_volume_a) }}
      EXTERNAL_MOUNTPOINTS: "${extra_volume_a}"
{{- end }}
{{- if ne .Values.db_vendor "sqlite" }}
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
      io.nextcloud.role: "{{ .Stack.Name }}/server"
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
      - ${datavolume_name}_conf:/var/www/html/config
      - ${datavolume_name}_data:/var/www/html/data
      - ${datavolume_name}_apps:/var/www/html/custom_apps
      - ${datavolume_name}_themes:/var/www/html/themes
{{- else }}
      - /var/www/html/config
      - /var/www/html/data
      - /var/www/html/custom_apps
      - /var/www/html/themes
{{- end }}
{{- if (.Values.extra_volume_a) }}
      - ${extra_volume_a}:/var/www/${extra_volume_a}
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
{{- if (.Values.docker_memory_swap_limit) }}
    memswap_limit: "${docker_memory_swap_limit}m"
{{- end }}

# +++++++++++++++++++++++
# END SERVICES
# +++++++++++++++++++++++

# +++++++++++++++++++++++
# BEGIN VOLUMES
# +++++++++++++++++++++++

{{- if or (.Values.datavolume_name) (.Values.extra_volume_a) }}
volumes:
{{- end }}
{{- if (.Values.datavolume_name) }}
  # ************************************
  # VOLUME
  # - holds nextcloud server config
  # ************************************
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

  # ************************************
  # VOLUME
  # - holds nextcloud user data
  # ************************************
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

  # ************************************
  # VOLUME
  # - holds nextcloud custom apps
  # ************************************
  {{.Values.datavolume_name}}_apps:
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
  # - holds nextcloud themes
  # ************************************
  {{.Values.datavolume_name}}_themes:
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

{{- if (.Values.extra_volume_a) }}
  # ************************************
  # VOLUME
  # - external volume 1
  # ************************************
  {{.Values.extra_volume_a}}:
    external: true
{{-   if eq .Values.storage_driver "rancher-nfs" }}
    driver: ${storage_driver}
{{-   else }}
    driver: local
{{-   end }}

{{- end }}

# +++++++++++++++++++++++
# END VOLUMES
# +++++++++++++++++++++++

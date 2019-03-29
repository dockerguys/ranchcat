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
  # - sidekick to mysql-server
  # - init persist volume that stores the database
  # ************************************
  mysql-data:
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
      - ${datavolume_name}_db:/var/lib/mysql
{{- else }}
      - /var/lib/mysql
{{- end }}

  # ************************************
  # SERVICE
  # - main database server
  # ************************************
  mysql-server:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${mysql_image}"
{{- else }}
    image: ${mysql_image}
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
      MYSQL_SERVER_ID: "1"
{{- if (.Values.mysql_root_name)}}
      MYSQL_ROOT_USER: ${mysql_root_name}
{{- end}}
{{- if (.Values.mysql_root_password)}}
      MYSQL_ROOT_DEFAULT_PASSWORD: ${mysql_root_password}
{{- end}}
{{- if (.Values.mysql_database)}}
      MYSQL_INITIAL_DB: ${mysql_database}
{{- end}}
{{- if (.Values.mysql_user)}}
      MYSQL_INITIAL_DB_ADMIN: ${mysql_user}
{{- end}}
{{- if (.Values.mysql_password)}}
      MYSQL_INITIAL_DB_ADMIN_DEFAULT_PASSWORD: ${mysql_password}
{{- end}}
{{- if (.Values.mysql_auto_memory)}}
      MYSQL_INNODB_AUTO_MEMORY: "true"
{{- end}}
{{- if (.Values.mysql_extargs)}}
      MYSQL_EXTARGS: ${mysql_extargs}
{{- end}}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.rancher.sidekicks: mysql-data
      io.mysqldb.role: server
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
      - mysql-data
    volumes:
      - /etc/timezone:/etc/timezone:ro
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
  # - web ui
  # ************************************
  adminer:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${adminer_image}"
{{- else }}
    image: ${adminer_image}
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
      ADMINER_CSS_NAME: "${adminer_css}"
      ADMINER_PLUGINS: "${adminer_plugins}"
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.mysqldb.role: webadmin
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
    # -----------------------------------
    # LIMIT CPU
    # - can't use `cpus` in rancher 1.6, hacking it by using the older `cpu-quota`
    # -----------------------------------
    cpu_quota: 100000
    cpu_shares: 950
    # -----------------------------------
    # LIMIT RAM
    # -----------------------------------
    mem_limit: "512m"
    memswap_limit: "1024m"

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
  # - holds the database
  # ************************************
  {{.Values.datavolume_name}}_db:
{{-   if eq .Values.storage_driver "rancher-nfs" }}
    driver: ${storage_driver}
{{-     if (.Values.storage_driver_nfsopts_host) }}
    driver_opts: 
      host: ${storage_driver_nfsopts_host}
      export: ${storage_driver_nfsopts_export}/${datavolume_name}
{{-     end }}
{{-   else }}
    driver: local
{{-   end }}
{{- end }}

# =======================
# END VOLUMES
# =======================

version: '2'
services:
  nextcloud-data:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/busybox"
{{- else }}
    image: busybox
{{- end }}
    labels:
      io.rancher.container.start_once: true
      io.rancher.container.hostname_override: container_name
    volumes:
{{- if (.Values.datavolume_name) }}
      - ${datavolume_name}:/var/www/html
{{- else }}
      - /var/www/html
{{- end }}
  redis:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${redis_image}"
{{- else }}
    image: ${redis_image}
{{- end }}
    restart: always
    labels:
      io.rancher.container.pull_image: ${repull_image}
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
  nextcloud:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${nextcloud_image}"
{{- else }}
    image: ${nextcloud_image}
{{- end }}
    external_links:
      - ${db_service}:db
    labels:
      io.rancher.sidekicks: nextcloud-data
      io.rancher.container.pull_image: ${repull_image}
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
    volumes_from:
      - nextcloud-data
    tty: true
    stdin_open: true
    restart: always
    depends_on:
      - redis
    environment:
      ENABLE_REDIS: true
      DEFAULT_ADMIN: ${nextcloud_user}
      DEFAULT_ADMIN_PASSWORD: ${nextcloud_password}
{{- if eq .Values.db_vendor "mysql"}}
      MYSQL_DATABASE: ${nextcloud_dbname}
      MYSQL_USER: ${nextcloud_dbuser}
      MYSQL_PASSWORD: ${nextcloud_dbpassword}
      MYSQL_HOST: db
{{- end}}
{{- if eq .Values.db_vendor "postgres"}}
      POSTGRES_DB: ${nextcloud_dbname}
      POSTGRES_USER: ${nextcloud_dbuser}
      POSTGRES_PASSWORD: ${nextcloud_dbpassword}
      POSTGRES_HOST: db
{{- end}}
{{- if (.Values.datavolume_name) }}
volumes:
  {{.Values.datavolume_name}}:
  {{- if eq .Values.storage_driver "rancher-nfs" }}
    driver: ${storage_driver}
  {{-   if (.Values.storage_driver_nfsopts_host) }}
    driver_opts: 
      host: ${storage_driver_nfsopts_host}
      export: ${storage_driver_nfsopts_export}/${datavolume_name}
  {{-   end }}
  {{- end }}
{{- end }}

version: '2'
services:
  nextcloud-data:
    image: busybox
    labels:
      io.rancher.container.start_once: true
      io.rancher.container.hostname_override: container_name
    volumes:
      - /var/www/html
  nextcloud:
    image: ${nextcloud_image}
    external_links:
      - ${db_service}:db
    labels:
      io.rancher.sidekicks: nextcloud-data
{{- if (.Values.host_affinity_label)}}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end}}
    volumes_from:
      - nextcloud-data
    tty: true
    stdin_open: true
    environment:
      NEXTCLOUD_ADMIN_USER: ${nextcloud_user}
      NEXTCLOUD_ADMIN_PASSWORD: ${nextcloud_password}
{{- if eq .Values.db_vendor "sqlite"}}
      SQLITE_DATABASE: nextclouddb
{{- end}}
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
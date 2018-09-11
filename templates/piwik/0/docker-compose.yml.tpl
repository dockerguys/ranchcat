version: '2'
services:
  piwik-data:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/busybox"
{{- else }}
    image: busybox
{{- end }}
    labels:
      io.rancher.container.start_once: true
    volumes:
    - /var/www/html/config
  piwik:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${piwik_image}"
{{- else }}
    image: ${piwik_image}
{{- end }}
    external_links:
      - ${db_service}:db
    labels:
      io.rancher.sidekicks: piwik-data
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
    volumes_from:
      - piwik-data
    tty: true
    stdin_open: true
    environment:
      PIWIK_USER: ${piwik_user}
      PIWIK_PASSWORD: ${piwik_password}
      DB_VENDOR: ${db_vendor}
{{- if eq .Values.db_vendor "mariadb"}}
      MARIADB_ADDR: db
      MARIADB_DATABASE: ${piwik_dbname}
      MARIADB_USER: ${piwik_dbuser}
      MARIADB_PASSWORD: ${piwik_dbpassword}
{{- end}}
{{- if eq .Values.db_vendor "postgres"}}
      POSTGRES_ADDR: db
      POSTGRES_DATABASE: ${piwik_dbname}
      POSTGRES_USER: ${piwik_dbuser}
      POSTGRES_PASSWORD: ${piwik_dbpassword}
{{- end}}

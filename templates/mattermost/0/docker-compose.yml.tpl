version: '2'
services:
  mattermost-data:
    labels:
      io.rancher.container.start_once: 'true'
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/busybox"
{{- else }}
    image: busybox
{{- end }}
    volumes:
    - /mattermost/config
    - /mattermost/data
  mattermost:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${mattermost_image}"
{{- else }}
    image: ${mattermost_image}
{{- end }}
    environment:
      MM_USERNAME: ${mattermost_db_user}
      MM_PASSWORD: ${mattermost_db_password}
      MM_DBNAME: ${mattermost_db_name}
      DB_HOST: mysql
      DB_PORT_NUMBER: 3306
      MM_SQLSETTINGS_DRIVERNAME: mysql
      MM_SQLSETTINGS_DATASOURCE: ${mattermost_db_user}:${mattermost_db_password}@tcp(mysql:3306)/${mattermost_db_name}?charset=utf8mb4,utf8&readTimeout=30s&writeTimeout=30s
    external_links:
    - ${mysql_service}:mysql
    labels:
      io.rancher.sidekicks: mattermost-data
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
    volumes:
      - /etc/localtime:/etc/localtime:ro
    volumes_from:
      - mattermost-data
    tty: true
    stdin_open: true

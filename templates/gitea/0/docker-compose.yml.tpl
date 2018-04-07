version: '2'
services:
  gitea-data:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/busybox"
{{- else }}
    image: busybox
{{- end }}
    labels:
      io.rancher.container.start_once: true
    volumes:
      - /data
  gitea:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${gitea_image}"
{{- else }}
    image: ${gitea_image}
{{- end }}
    external_links:
      - ${db_service}:db
    labels:
      io.rancher.sidekicks: gitea-data
{{- if (.Values.repull_image) }}
      io.rancher.container.pull_image: always
{{- end }}
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
    volumes_from:
      - gitea-data
    environment:
      GITEA_DOMAIN: ${gitea_domain}
      ROOT_URL: "https://${gitea_domain}"
      SECRET_KEY: ${gitea_secret}
      LFS_SECRET: ${gitea_lfs_secret}
      LOG_LEVEL: ${gitea_loglevel}
      APP_NAME: ${gitea_appname}
      RUN_MODE: ${gitea_runmode}
      DISABLE_SSH: ${gitea_disable_ssh}
      DB_TYPE: ${db_vendor}
{{- if ne .Values.db_vendor "sqlite3" }}
      DB_HOST: "db:3306"
{{- end }}
      DB_NAME: ${db_name}
      DB_USER: ${db_username}
      DB_PASSWD: ${db_password}

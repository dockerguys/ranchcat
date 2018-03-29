version: '2'
services:
  keycloak-data:
    image: busybox
    labels:
      io.rancher.container.start_once: true
    volumes:
    - /opt/jboss/keycloak/standalone/data
  keycloak:
    image: ${keycloak_image}
    external_links:
      - ${db_service}:db
    labels:
      io.rancher.sidekicks: keycloak-data
{{- if (.Values.host_affinity_label)}}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end}}
    volumes_from:
      - keycloak-data
    tty: true
    stdin_open: true
    environment:
      PROXY_ADDRESS_FORWARDING: true
      KEYCLOAK_USER: ${keycloak_user}
      KEYCLOAK_PASSWORD: ${keycloak_password}
      DB_VENDOR: ${db_vendor}
      EXTARG_KEYCLOAK: ${keycloak_extarg}
{{- if eq .Values.db_vendor "mysql"}}
      MYSQL_ADDR: db
      MYSQL_DATABASE: ${keycloak_dbname}
      MYSQL_USER: ${keycloak_dbuser}
      MYSQL_PASSWORD: ${keycloak_dbpassword}
{{- end}}
{{- if eq .Values.db_vendor "mariadb"}}
      MARIADB_ADDR: db
      MARIADB_DATABASE: ${keycloak_dbname}
      MARIADB_USER: ${keycloak_dbuser}
      MARIADB_PASSWORD: ${keycloak_dbpassword}
{{- end}}
{{- if eq .Values.db_vendor "postgres"}}
      POSTGRES_ADDR: db
      POSTGRES_DATABASE: ${keycloak_dbname}
      POSTGRES_USER: ${keycloak_dbuser}
      POSTGRES_PASSWORD: ${keycloak_dbpassword}
{{- end}}

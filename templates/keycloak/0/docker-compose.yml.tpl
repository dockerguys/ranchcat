version: '2'
services:
  keycloak-data:
    image: busybox
    labels:
      io.rancher.container.start_once: true
    volumes:
    - /opt/jboss/keycloak/standalone/data
    command: chown -R 1000 /opt/jboss/keycloak/standalone/data
  keycloak:
    image: ${keycloak_image}
    external_links:
      - ${db_service}:db
    labels:
      io.rancher.sidekicks: keycloak-data
    volumes_from:
      - keycloak-data
    tty: true
    stdin_open: true
    environment:
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
{{- if eq .Values.db_vendor "postgres"}}
      POSTGRES_ADDR: db
      POSTGRES_DATABASE: ${keycloak_dbname}
      POSTGRES_USER: ${keycloak_dbuser}
      POSTGRES_PASSWORD: ${keycloak_dbpassword}
{{- end}}

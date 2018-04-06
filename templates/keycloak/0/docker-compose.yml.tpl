version: '2'
services:
  keycloak-data:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/busybox"
{{- else }}
    image: busybox
{{- end }}
    labels:
      io.rancher.container.start_once: true
    volumes:
    - /opt/jboss/keycloak/standalone/data
    command: chown -R 1000 /opt/jboss/keycloak/standalone/data
  keycloak:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${keycloak_image}"
{{- else }}
    image: ${keycloak_image}
{{- end }}
    external_links:
      - ${db_service}:db
    labels:
      io.rancher.sidekicks: keycloak-data
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
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
      MYSQL_PORT_3306_TCP_ADDR: db
      MYSQL_PORT_3306_TCP_PORT: 3306
      MYSQL_ADDR: db
      MYSQL_DATABASE: ${keycloak_dbname}
      MYSQL_USER: ${keycloak_dbuser}
      MYSQL_PASSWORD: ${keycloak_dbpassword}
{{- end}}
{{- if eq .Values.db_vendor "mariadb"}}
      MARIADB_PORT_3306_TCP_ADDR: db
      MARIADB_PORT_3306_TCP_PORT: 3306
      MARIADB_ADDR: db
      MARIADB_DATABASE: ${keycloak_dbname}
      MARIADB_USER: ${keycloak_dbuser}
      MARIADB_PASSWORD: ${keycloak_dbpassword}
{{- end}}
{{- if eq .Values.db_vendor "postgres"}}
      POSTGRES_PORT_5432_TCP_ADDR: db
      POSTGRES_PORT_5432_TCP_PORT: 5432
      POSTGRES_ADDR: db
      POSTGRES_DATABASE: ${keycloak_dbname}
      POSTGRES_USER: ${keycloak_dbuser}
      POSTGRES_PASSWORD: ${keycloak_dbpassword}
{{- end}}

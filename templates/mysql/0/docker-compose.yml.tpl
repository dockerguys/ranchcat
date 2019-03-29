version: '2'
services:
  mysql-lb:
    image: rancher/lb-service-haproxy:v0.6.4
    ports:
      - ${mysql_lb_port}:${mysql_lb_port}
  mysql-data:
    image: busybox
    labels:
      io.rancher.container.start_once: true
    volumes:
      - /var/lib/mysql
  mysql:
    image: ${mysql_image}
    environment:
      MYSQL_ROOT_DEFAULT_PASSWORD: ${mysql_root_password}
{{- if (.Values.mysql_root_name)}}
      MYSQL_ROOT_USER: ${mysql_root_name}
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
{{- if (.Values.mysql_extargs)}}
      MYSQL_EXTARGS: ${mysql_extargs}
{{- end}}
    tty: true
    stdin_open: true
    labels:
      io.rancher.sidekicks: mysql-data
    volumes_from:
      - mysql-data
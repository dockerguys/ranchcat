version: '2'
services:
  functions-data:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/busybox"
{{- else }}
    image: busybox
{{- end }}
    labels:
      io.rancher.container.start_once: true
    volumes:
{{- if (.Values.datavolume_name) }}
    - ${datavolume}:/app/data
{{- else }}
    - /app/data
{{- end }}
  functions-db-data:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/busybox"
{{- else }}
    image: busybox
{{- end }}
    labels:
      io.rancher.container.start_once: true
    volumes:
{{- if (.Values.datavolume_name) }}
    - ${datavolume}_db:/var/lib/postgresql/data
{{- else }}
    - /var/lib/postgresql/data
{{- end }}
  functions-ui:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${ironfunc_ui_image}"
{{- else }}
    image: ${ironfunc_ui_image}
{{- end }}
    environment:
      API_URL: http://api:8080
    stdin_open: true
    tty: true
    links:
    - functions-worker:api
    labels:
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- else }}
      io.rancher.container.pull_image: never
{{- end }}
  functions-worker:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${ironfunc_worker_image}"
{{- else }}
    image: ${ironfunc_worker_image}
{{- end }}
    environment:
      LOG_LEVEL: ${log_level}
      MQ_URL: redis://redis:6379/
      DB_URL: "postgres://postgres:${postgres_db_password}@postgres/ironfuncs?sslmode=disable"
    stdin_open: true
    volumes_from:
      - functions-data
    volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    tty: true
    links:
    - postgres:postgres
    - redis:redis
    labels:
      io.rancher.sidekicks: functions-data
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- else }}
      io.rancher.container.pull_image: never
{{- end }}
  redis:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${redis_image}"
{{- else }}
    image: ${redis_image}
{{- end }}
    stdin_open: true
    tty: true
    labels:
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- else }}
      io.rancher.container.pull_image: never
{{- end }}
  postgres:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${postgres_image}"
{{- else }}
    image: ${postgres_image}
{{- end }}
    environment:
      POSTGRES_PASSWORD: ${postgres_db_password}
      POSTGRES_USER: postgres
      POSTGRES_DB: ironfuncs
    stdin_open: true
    tty: true
    volumes_from:
      - functions-db-data
    labels:
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- else }}
      io.rancher.container.pull_image: never
{{- end }}
      io.rancher.sidekicks: functions-db-data

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
  {{.Values.datavolume_name}}_db:
  {{- if eq .Values.storage_driver "rancher-nfs" }}
    driver: ${storage_driver}
  {{-   if (.Values.storage_driver_nfsopts_host) }}
    driver_opts: 
      host: ${storage_driver_nfsopts_host}
      export: ${storage_driver_nfsopts_export}/${datavolume_name}_db
  {{-   end }}
  {{- end }}
{{- end }}

version: '2'
services:
  notebin-data:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/busybox"
{{- else }}
    image: busybox
{{- end }}
    labels:
      io.rancher.container.start_once: true
    volumes:
{{- if (.Values.datavolume_name) }}
      - ${datavolume_name}:/data
{{- else }}
      - /data
{{- end }}
    command: mkdir -p /data/notes /data/docs /data/logs
{{- if eq .Values.notebin_backend "postgres" }}
  notebin-dbdata:
{{-   if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/busybox"
{{-   else }}
    image: busybox
{{-   end }}
    labels:
      io.rancher.container.start_once: true
    volumes:
{{-   if (.Values.datavolume_name) }}
      - ${datavolume_name}_db:/var/lib/postgresql/data
{{-   else }}
      - /var/lib/postgresql/data
{{-   end }}
{{- end }}
{{- if eq .Values.notebin_backend "redis" }}
  redis:
{{-   if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${redis_image}"
{{-   else }}
    image: ${redis_image}
{{-   end }}
    stdin_open: true
    tty: true
    labels:
      io.rancher.container.pull_image: ${repull_image}
{{-   if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{-   end }}
    deploy:
      resources:
        limits:
          memory: ${storage_hard_limit}
{{- end }}
{{- if eq .Values.notebin_backend "postgres" }}
  postgres:
{{-   if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${postgres_image}"
{{-   else }}
    image: ${postgres_image}
{{-   end }}
    environment:
      POSTGRES_PASSWORD: ${db_password}
      POSTGRES_USER: postgres
      POSTGRES_DB: notebin
    stdin_open: true
    tty: true
    volumes_from:
      - notebin-dbdata
    labels:
      io.rancher.container.pull_image: ${repull_image}
      io.rancher.sidekicks: notebin-dbdata
{{-   if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{-   end }}
{{- end }}
  notebin:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${notebin_image}"
{{- else }}
    image: ${notebin_image}
{{- end }}
    labels:
      io.rancher.container.pull_image: ${repull_image}
      io.rancher.sidekicks: notebin-data
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
    volumes_from:
      - notebin-data
    environment:
      NOTEBIN_HOST: 0.0.0.0
      NOTEBIN_STORAGE_TYPE: ${notebin_backend}
      NOTEBIN_STORAGE_EXPIRE: ${notebin_max_age}
      NOTEBIN_KEY_LENGTH: ${notebin_keylength}
      NOTEBIN_MAX_LENGTH: ${notebin_maxlength}
      NOTEBIN_STATIC_MAX_AGE: ${notebin_static_maxage}
      NOTEBIN_RECOMPRESS_STATIC_ASSETS: ${notebin_recompress_static}
      NOTEBIN_LOGGING_LEVEL: ${notebin_loglevel}
      NOTEBIN_LOGGING_TYPE: ${notebin_logtype}
      NOTEBIN_LOGGING_FILENAME: "/data/logs/notebin.log"
      NOTEBIN_DOCUMENTS: "/data/docs"
{{- if eq .Values.notebin_backend "postgres" }}
      NOTEBIN_STORAGE_CONNECTION_URL: "postgres://postgres:${db_password}@postgres/notebin?sslmode=disable"
{{- end }}
{{- if eq .Values.notebin_backend "redis" }}
      NOTEBIN_STORAGE_HOST: redis
{{- end }}
{{- if eq .Values.notebin_backend "file" }}
      NOTEBIN_STORAGE_PATH: "/data/notes"
{{- end }}
{{- if (.Values.datavolume_name) }}
volumes:
  {{.Values.datavolume_name}}:
{{-   if eq .Values.storage_driver "rancher-nfs" }}
    driver: ${storage_driver}
{{-     if (.Values.storage_driver_nfsopts_host) }}
    driver_opts: 
      host: ${storage_driver_nfsopts_host}
      export: ${storage_driver_nfsopts_export}/${datavolume_name}
{{-     end }}
{{-   end }}
{{-   if eq .Values.notebin_backend "postgres" }}
  {{.Values.datavolume_name}}_db:
{{-     if eq .Values.storage_driver "rancher-nfs" }}
    driver: ${storage_driver}
{{-       if (.Values.storage_driver_nfsopts_host) }}
    driver_opts: 
      host: ${storage_driver_nfsopts_host}
      export: ${storage_driver_nfsopts_export}/${datavolume_name}_db
{{-       end }}
{{-     end }}
{{-   end }}
{{- end }}

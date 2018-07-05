version: '2'
services:
  nginx-data:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/busybox"
{{- else }}
    image: busybox
{{- end }}
    labels:
      io.rancher.container.start_once: true
    volumes:
{{- if (.Values.datavolume_name) }}
      - ${datavolume_name}:/wwwroot
{{- else }}
      - /wwwroot
{{- end }}
  nginx:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${nginx_image}"
{{- else }}
    image: ${nginx_image}
{{- end }}
    labels:
      io.rancher.sidekicks: nginx-data
      io.rancher.container.pull_image: ${repull_image}
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
    volumes_from:
      - nginx-data
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
{{- end }}

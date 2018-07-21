version: '2'
services:
  mail-data:
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
  mailserver:
{{- if (.Values.docker_registry_name) }}
    image: "analogic/poste.io"
{{- else }}
    image: "analogic/poste.io"
{{- end }}
    labels:
      io.rancher.sidekicks: mail-data
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
    volumes_from:
      - mail-data
    volumes:
      - /etc/localtime:/etc/localtime:ro
    environment:
{{- if eq .Values.disable_antivirus true }}
      DISABLE_CLAMAV: "TRUE"
{{- else }}
      DISABLE_CLAMAV: "FALSE"
{{- end }}
      HTTPS: "OFF"
{{- if (.Values.datavolume_name) }}
volumes:
  {{.Values.datavolume_name}}:
{{-   if eq .Values.storage_driver "rancher-nfs" }}
{{-     if eq .Values.storage_exists "true" }}
    external: true
{{-     end }}
    driver: ${storage_driver}
{{-     if (.Values.storage_driver_nfsopts_host) }}
    driver_opts: 
      host: ${storage_driver_nfsopts_host}
      export: ${storage_driver_nfsopts_export}/${datavolume_name}
{{-     end }}
{{-   end }}
{{- end }}

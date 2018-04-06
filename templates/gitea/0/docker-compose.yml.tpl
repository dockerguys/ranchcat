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
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
    volumes_from:
      - gitea-data

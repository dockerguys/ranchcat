version: '2'
volumes:
  bluegro:
    external: true
    driver: ${volume_driver}
services:
  alpine:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${alpine_image}"
{{- else }}
    image: ${alpine_image}
{{- end }}
    tty: true
    stdin_open: true
    volumes:
      - bluegro:/var/lib/storage
{{- if (.Values.host_affinity_label) }}
    labels:
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}

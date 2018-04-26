version: '2'
volumes:
  ${volume_name}:
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
      - ${volume_name}:/var/lib/storage
    labels:
      io.testing.os: "alpine-linux"
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}

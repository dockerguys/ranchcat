version: '2'
services:
  alpine:
    image: "${docker_registry_name}${alpine_image}"
    tty: true
    stdin_open: true
    labels:
{{- if (.Values.host_affinity_label)}}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end}}

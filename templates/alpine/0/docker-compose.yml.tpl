version: '2'
services:
  alpine:
{{- if ne .Values.docker_registry_name "" }}
    image: "${docker_registry_name}/${alpine_image}"
{{- else }}
    image: ${alpine_image}
{{- end }}
    tty: true
    stdin_open: true
    labels:
{{- if ne .Values.host_affinity_label "" }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}

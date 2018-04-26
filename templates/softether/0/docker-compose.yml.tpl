version: '2'
services:
  softether-server:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${softether_image}"
{{- else }}
    image: ${softether_image}
{{- end }}
    tty: true
    stdin_open: true
    labels:
      io.softether.role: server
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
    ports: # haproxy doesn't support udp
    - 1194:1194/udp

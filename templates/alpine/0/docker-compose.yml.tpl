version: '2'
services:
  alpine:
    image: ${alpine_image}
    tty: true
    stdin_open: true
    labels:
{{- if (.Values.host_affinity_label)}}
      # label all hosts that you prefer to run etcd with this
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end}}

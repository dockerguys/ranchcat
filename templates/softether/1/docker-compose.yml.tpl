version: '2'
services:
  softether-data:
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
  softether-server:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${softether_image}"
{{- else }}
    image: ${softether_image}
{{- end }}
    tty: true
    stdin_open: true
    labels:
      io.rancher.sidekicks: softether-data
      io.softether.role: server
    ports: # haproxy doesn't support udp
    - 1194:1194/udp
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
    volumes_from:
      - softether-data
{{- if (.Values.storage_size) }}
    storage_opt:
      size: "${storage_size}g"
{{- end }}
{{- if (.Values.docker_cpu_limit) }}
    cpus: ${docker_cpu_limit}
{{- end }}
    cpu_shares: ${docker_cpu_weight_limit}
{{- if (.Values.docker_memory_limit) }}
    mem_limit: "${docker_memory_limit}m"
{{- end }}
    memswap_limit: "${docker_memory_swap_limit}m"
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
  {{- else }}
    driver: local
  {{- end }}
{{- end }}

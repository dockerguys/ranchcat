version: '2'

# --- BEGIN SERVICES ---

services:
  # SERVICE
  # sidekick to softether-server
  # for init persist volume
  softether-data:
    # [image]
    # support private registry
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/busybox"
{{- else }}
    image: busybox
{{- end }}
    # [scheduler labels]
    labels:
      io.rancher.container.start_once: true
    # [volumes]
    # supports data volume
    volumes:
{{- if (.Values.datavolume_name) }}
      - ${datavolume_name}:/data
{{- else }}
      - /data
{{- end }}

  # SERVICE
  # vpn server
  softether-server:
    # [image]
    # support private registry
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${softether_image}"
{{- else }}
    image: ${softether_image}
{{- end }}
    # [tty/stdin]
    tty: true
    stdin_open: true
    # [host port maps]
    # direct map to ports on host
    ports: # haproxy doesn't support udp
      - 1194:1194/udp
    # [scheduler labels]
    labels:
      io.rancher.sidekicks: softether-data
      io.softether.role: server
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
    # [volumes]
    # use volumes from sidekick
    volumes_from:
      - softether-data
    # [storage limits]
{{- if (.Values.storage_size) }}
    storage_opt:
      size: "${storage_size}g"
{{- end }}
    # [cpu limits]
{{- if (.Values.docker_cpu_limit) }}
    cpus: ${docker_cpu_limit}
{{- end }}
    cpu_shares: ${docker_cpu_weight_limit}
    # [memory limits]
{{- if (.Values.docker_memory_limit) }}
    mem_limit: "${docker_memory_limit}m"
{{- end }}
    memswap_limit: "${docker_memory_swap_limit}m"

# --- END SERVICES ---

# --- BEGIN VOLUMES ---

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

# --- END VOLUMES ---

# https://rancher.com/docs/rancher/v1.6/en/cli/variable-interpolation/#templating
version: '2'

# --- BEGIN SERVICES ---

services:
  # SERVICE
  # sidekick to softether-server
  # for init persist volume that stores the server config
  softether-config:
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
      - ${datavolume_name}_config:/etc/vpnserver
{{- else }}
      - /etc/vpnserver
{{- end }}

  # SERVICE
  # sidekick to softether-server
  # for init persist volume that stores the server logs
  softether-logs:
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
      - ${datavolume_name}_logs:/var/log/vpnserver
{{- else }}
      - /var/log/vpnserver
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
    # [env]
    environment:
{{- if (.Values.softether_password) }}
      VPN_SERVER_DEFAULT_PASSWORD: ${softether_password}
{{- end }}
      VPN_SERVER_DISABLE_DDNS: ${softether_disable_ddns}
      VPN_SERVER_DISABLE_NAT_TRAVERSAL: ${softether_disable_natt}
      VPN_CLIENT_DISABLE_KEEPALIVE: ${softether_disable_client_keepalive}
      VPN_CLIENT_KEEPALIVE_HOST: ${softether_client_keepalive_host}
      VPN_CLIENT_KEEPALIVE_PROTOCOL: ${softether_client_keepalive_protocol}
      VPN_CLIENT_KEEPALIVE_INTERVAL: ${softether_client_keepalive_interval}
      VPN_CLIENT_DISABLE_UPDATE_NOTIFICATION: ${softether_disable_client_notify}
    # [host port maps]
    # direct map to ports on host
    ports: # haproxy doesn't support udp
      - 1194:1194
      - 5555:5555
    # [scheduler labels]
    labels:
      io.rancher.sidekicks: softether-config, softether-logs
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
      - softether-config
      - softether-logs
    # [storage limits]
# TODO storage-opt isn't implemented in rancher 1.6
#{{- if (.Values.storage_size) }}
#    storage_opt:
#      size: "${storage_size}g"
#{{- end }}
    # [cpu limits]
{{- if (.Values.docker_cpu_quota_limit) }}
    # TODO cpus isn't implemented in rancher 1.6, hacking it using the 
    # older `cpu-quota` instead
    #cpus: ${docker_cpu_limit}
    cpu_quota: ${docker_cpu_quota_limit}
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
  # vpn server config volume
  {{.Values.datavolume_name}}_config:
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
  # vpn server log volume
  {{.Values.datavolume_name}}_logs:
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

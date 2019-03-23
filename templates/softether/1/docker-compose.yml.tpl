# =====================================================================
# This is a rancher template for generating `docker-compose` files.
# Refer to Rancher docs on syntax:
# - https://rancher.com/docs/rancher/v1.6/en/cli/variable-interpolation/#templating
# - https://docs.docker.com/compose/compose-file/compose-file-v2/
# =====================================================================
version: '2'

# =======================
# BEGIN SERVICES
# =======================

services:
  # ************************************
  # SERVICE
  # - sidekick to softether-server
  # - init persist volume that stores the server config
  # ************************************
  softether-config:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/busybox"
{{- else }}
    image: busybox
{{- end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.rancher.container.start_once: true
    # -----------------------------------
    # Volumes
    # - supports data volumes
    # -----------------------------------
    volumes:
{{- if (.Values.datavolume_name) }}
      - ${datavolume_name}_config:/etc/vpnserver
{{- else }}
      - /etc/vpnserver
{{- end }}

  # ************************************
  # SERVICE
  # - sidekick to softether-server
  # - init persist volume that stores the server logs
  # ************************************
  softether-logs:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/busybox"
{{- else }}
    image: busybox
{{- end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.rancher.container.start_once: true
    # -----------------------------------
    # Volumes
    # - supports data volumes
    # -----------------------------------
    volumes:
{{- if (.Values.datavolume_name) }}
      - ${datavolume_name}_logs:/var/log/vpnserver
{{- else }}
      - /var/log/vpnserver
{{- end }}

  # ************************************
  # SERVICE
  # - the main application
  # ************************************
  softether-server:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${softether_image}"
{{- else }}
    image: ${softether_image}
{{- end }}
    # -----------------------------------
    # TTY/STDIN
    # -----------------------------------
    tty: true
    stdin_open: true
    # -----------------------------------
    # ENV
    # -----------------------------------
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
    # -----------------------------------
    # KERNEL CAPS
    # -----------------------------------
{{- if (.Values.softether_enable_kernel_nat) }}
    cap_add:
      - NET_ADMIN
{{- end }}
    # -----------------------------------
    # DEVICE MAPPING
    # -----------------------------------
{{- if (.Values.softether_enable_tun) }}
    devices:
      - "/dev/net/tun:/dev/net/tun"
{{- end }}
    # -----------------------------------
    # PORT MAPPING
    # - directly map to host ports
    # -----------------------------------
    ports: # haproxy doesn't support udp
      - ${softether_openvpn_udp_port}:1194/udp
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.rancher.sidekicks: softether-config, softether-logs
      io.softether.role: server
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
    # -----------------------------------
    # VOLUMES
    # - use vols from sidekick
    # -----------------------------------
    volumes_from:
      - softether-config
      - softether-logs
    # -----------------------------------
    # LIMIT CPU
    # - can't use `cpus` in rancher 1.6, hacking it by using the older `cpu-quota`
    # -----------------------------------
{{- if (.Values.docker_cpu_quota_limit) }}
    #cpus: ${docker_cpu_limit}
    cpu_quota: ${docker_cpu_quota_limit}
{{- end }}
    cpu_shares: ${docker_cpu_weight_limit}
    # -----------------------------------
    # LIMIT RAM
    # -----------------------------------
{{- if (.Values.docker_memory_limit) }}
    mem_limit: "${docker_memory_limit}m"
{{- end }}
    memswap_limit: "${docker_memory_swap_limit}m"

# =======================
# END SERVICES
# =======================

# =======================
# BEGIN VOLUMES
# =======================

{{- if (.Values.datavolume_name) }}
volumes:
  # ************************************
  # VOLUME
  # - holds vpn server configs
  # ************************************
  {{.Values.datavolume_name}}_config:
{{-   if eq .Values.storage_driver "rancher-nfs" }}
    driver: ${storage_driver}
{{-     if (.Values.storage_driver_nfsopts_host) }}
    driver_opts: 
      host: ${storage_driver_nfsopts_host}
      export: ${storage_driver_nfsopts_export}/${datavolume_name}
{{-     end }}
{{-   else }}
    driver: local
{{-     if (.Values.storage_size) }}
    driver_opts:
      size: "100m"
{{-     end }}
{{-   end }}

  # ************************************
  # VOLUME
  # - holds vpn server logs
  # ************************************
  {{.Values.datavolume_name}}_logs:
{{-   if eq .Values.storage_driver "rancher-nfs" }}
    driver: ${storage_driver}
{{-     if (.Values.storage_driver_nfsopts_host) }}
    driver_opts: 
      host: ${storage_driver_nfsopts_host}
      export: ${storage_driver_nfsopts_export}/${datavolume_name}
{{-     end }}
{{-   else }}
    driver: local
{{-     if (.Values.storage_size) }}
    driver_opts:
      size: "${storage_size}m"
{{-     end }}
{{-   end }}
{{- end }}

# =======================
# END VOLUMES
# =======================

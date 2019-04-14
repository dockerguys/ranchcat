# #####################################################################
# This is a rancher template for generating `docker-compose` files.
# Refer to Rancher docs on syntax:
# - https://rancher.com/docs/rancher/v1.6/en/cli/variable-interpolation/#templating
# - https://docs.docker.com/compose/compose-file/compose-file-v2/
# #####################################################################
version: '2'

# +++++++++++++++++++++++
# BEGIN SERVICES
# +++++++++++++++++++++++
services:
  # ************************************
  # SERVICE
  # - primary application
  # ************************************
  softether:
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
      io.softether.role: "{{ .Stack.Name }}/server"
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
    # -----------------------------------
    # VOLUMES
    # - https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes
    # - specify vol name to use the specified volume
    # - just write path to create dynamic named volume
    # -----------------------------------
    volumes:
{{- if (.Values.datavolume_name) }}
      - ${datavolume_name}_conf:/etc/vpnserver
      - ${datavolume_name}_logs:/var/www/html/config
{{- else }}
      - /etc/vpnserver
      - /var/www/html/config
{{- end }}
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
{{- if (.Values.docker_memory_swap_limit) }}
    memswap_limit: "${docker_memory_swap_limit}m"
{{- end }}

# +++++++++++++++++++++++
# END SERVICES
# +++++++++++++++++++++++

# +++++++++++++++++++++++
# BEGIN VOLUMES
# +++++++++++++++++++++++

{{- if (.Values.datavolume_name) }}
volumes:
  # ************************************
  # VOLUME
  # - holds server config
  # ************************************
  {{.Values.datavolume_name}}_conf:
{{-   if eq .Values.volume_exists "true" }}
    external: true
{{-   end }}
{{-   if eq .Values.storage_driver "rancher-nfs" }}
    driver: rancher-nfs
{{-     if eq .Values.volume_exists "false" }}
{{-       if (.Values.storage_driver_nfsopts_host) }}
    driver_opts:
      host: ${storage_driver_nfsopts_host}
      exportBase: ${storage_driver_nfsopts_export}
{{-         if eq .Values.storage_retain_volume "true" }}
      onRemove: retain
{{-         else }}
      onRemove: purge
{{-         end }}
{{-       end }}
{{-     end }}
{{-   else }}
    driver: local
{{-   end }}

  # ************************************
  # VOLUME
  # - holds vpn server logs
  # ************************************
  {{.Values.datavolume_name}}_logs:
{{-   if eq .Values.volume_exists "true" }}
    external: true
{{-   end }}
{{-   if eq .Values.storage_driver "rancher-nfs" }}
    driver: rancher-nfs
{{-     if eq .Values.volume_exists "false" }}
{{-       if (.Values.storage_driver_nfsopts_host) }}
    driver_opts:
      host: ${storage_driver_nfsopts_host}
      exportBase: ${storage_driver_nfsopts_export}
{{-         if eq .Values.storage_retain_volume "true" }}
      onRemove: retain
{{-         else }}
      onRemove: purge
{{-         end }}
{{-       end }}
{{-     end }}
{{-   else }}
    driver: local
{{-   end }}

# +++++++++++++++++++++++
# END VOLUMES
# +++++++++++++++++++++++

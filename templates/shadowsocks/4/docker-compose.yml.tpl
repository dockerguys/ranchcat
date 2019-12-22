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
  shadowsocks-server:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${shadowsocks_image}"
{{- else }}
    image: ${shadowsocks_image}
{{- end }}
    labels:
      io.shadowsocks.role: "{{ .Stack.Name }}/server"
{{- if (.Values.ss_expose_ports) }}
      # hard anti-affinity rule to prevent >1 instance per host (port mapping conflict)
      io.shadowsocks.host: dedicated
      io.rancher.scheduler.affinity:container_label_ne: io.shadowsocks.host=dedicated
{{- end }}
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
    environment:
      SS_CRYPTO: ${ss_crypto}
      SS_TIMEOUT: ${ss_timeout}
      SS_FASTOPEN: ${ss_fastopen}
      SS_REUSE_PORT: ${ss_reuse_port}
      SS_EXTERNAL_DNS: ${ss_external_dns}
      SS_MODE: ${ss_mode}
      SS_KEY: ${ss_key}
      SS_LOG_LEVEL: ${ss_log_level}
      SS_EXTERNAL_PORT: ${ss_connection_port}
      SS_PRIVATE_MAN_PORT: 43456
      SS_PUBLIC_MAN_PORT: 8080
{{- if (.Values.ss_enable_v2ray) }}
      SS_ENABLE_V2RAY: "true"
{{- else }}
      SS_ENABLE_V2RAY: "false"
{{- end }}
      V2RAY_WEBSOCKET_PATH: ${v2ray_websocket_path}
      V2RAY_TRANSPORT_PROTOCOL: ${v2ray_transport_protocol}
      V2RAY_HOSTNAME: ${v2ray_hostname}
      V2RAY_ACME_KEY: ${v2ray_acme_key}
      V2RAY_ACME_CERT: ${v2ray_acme_cert}
{{- if (.Values.ss_expose_ports) }}
    ports: # haproxy doesn't support udp
      - ${ss_connection_port}:${ss_connection_port}/tcp
      - ${ss_connection_port}:${ss_connection_port}/udp
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
    memswap_limit: "${docker_memory_limit}m"
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
    memswap_limit: "${docker_memory_limit}m"
{{- end }}

# +++++++++++++++++++++++
# END SERVICES
# +++++++++++++++++++++++

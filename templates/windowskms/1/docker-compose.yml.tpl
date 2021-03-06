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
  # - main application server
  # ************************************
  winkms:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${winkms_image}"
{{- else }}
    image: ${winkms_image}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      KMS_CLIENT_TIMEOUT: "${client_timeout}"
      KMS_RENEW_INTERVAL: "${renew_interval}w"
      KMS_RETRY_INTERVAL: "${retry_interval}h"
      KMS_SERVER_LCID: "${server_lcid}"
      KMS_SERVER_BUILD_NUMBER: "${server_build_number}"
      KMS_VERBOSE_LOG: "${verbose_logging}"
      KMS_LOG_TIMESTAMP: "${log_timestamp}"
      KMS_CLIENT_QUICK_DISCONNECT: "${quick_disconnect}"
      KMS_ENABLE_CLIENT_TIME_CHECK: "${client_time_check}"
      KMS_ENABLE_MAINTAIN_CLIENT: "${maintain_clients}"
      KMS_EMPTY_CLIENT_LIST_ON_START: "${empty_clients_onstart}"
      KMS_DISABLE_RPC_NDR64: "${disable_rpc_ndr64}"
      KMS_DISABLE_RPC_BTFN: "${disable_rpc_btfn}"
{{- if eq .Values.log_output "Console" }}
      KMS_CONSOLE_LOG: "true"
{{- else }}
      KMS_CONSOLE_LOG: "false"
{{- end }}
{{- if eq .Values.debug_mode "true" }}
      KMS_RUN_MODE: "debug"
{{- else }}
      KMS_RUN_MODE: "production"
{{- end }}
{{- if (.Values.max_clients) }}
      KMS_MAX_CLIENTS: "${max_clients}"
{{- end }}
{{- if eq .Values.product_filter "Any" }}
      KMS_ENABLE_PRODUCT_FILTERING: "false"
{{- end }}
{{- if eq .Values.product_filter "Volume License Only" }}
      KMS_ENABLE_PRODUCT_FILTERING: "true"
      KMS_ACCEPT_VL_PRODUCT_ONLY: "true"
      KMS_REFUSE_UNKNOWN_PRODUCT: "true"
{{- end }}
{{- if eq .Values.product_filter "Ignore Unknown" }}
      KMS_ENABLE_PRODUCT_FILTERING: "true"
      KMS_ACCEPT_VL_PRODUCT_ONLY: "false"
      KMS_REFUSE_UNKNOWN_PRODUCT: "true"
{{- end }}
{{- if eq .Values.product_filter "Ignore Retail" }}
      KMS_ENABLE_PRODUCT_FILTERING: "true"
      KMS_ACCEPT_VL_PRODUCT_ONLY: "false"
      KMS_REFUSE_UNKNOWN_PRODUCT: "false"
{{- end }}
{{- if eq .Values.server_epid_rand "BuiltIn" }}
      KMS_SERVER_EPID_RAND: "0"
{{- end }}
{{- if eq .Values.server_epid_rand "Random Per Instance" }}
      KMS_SERVER_EPID_RAND: "1"
{{- end }}
{{- if eq .Values.server_epid_rand "Random Per Request" }}
      KMS_SERVER_EPID_RAND: "2"
{{- end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.windowskms.role: "{{ .Stack.Name }}/server"
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
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
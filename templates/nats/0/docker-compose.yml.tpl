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
{{- if or (eq .Values.acs_enable "primary") (eq .Values.acs_enable "primary_and_replica") }}
  # ************************************
  # SERVICE
  # - primary account server
  # ************************************
  acscore:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{-   if (.Values.docker_registry_name) }}
{{-     if (.Values.nats_image_custom) }}
    image: "${docker_registry_name}/${nats_image_custom}"
{{-     else }}
    image: "${docker_registry_name}/${nats_image}"
{{-     end }}
{{-   else }}
{{-     if (.Values.nats_image_custom) }}
    image: ${nats_image_custom}
{{-     else }}
    image: ${nats_image}
{{-     end }}
{{-   end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      CM_DISABLE: "yes"
      ACS_DISABLE: "no"
      ACS_ENABLE_HTTPS: "no"
      ACS_STORE_READONLY: "false"
      ACS_STORE_SHARD: "${acs_shard_tokenstore}"
      ACS_LOG_COLOR: "false"
      ACS_LOG_PID: "false"
      ACS_PRIMARY: ""
      ACS_REPLICATE_TIMEOUT: "${acs_replicate_timeout}"
      ACS_REPLICATE_MAXSYNC: "${acs_replicate_maxsync}"
      ACS_READ_TIMEOUT: "${acs_read_timeout}"
      ACS_WRITE_TIMEOUT: "${acs_write_timeout}"
      ACS_NOTIFY_CMSERVERS: "${acs_notify_upstream}"
      ACS_NOTIFY_CONN_TIMEOUT: "${acs_notify_conn_timeout}"
      ACS_NOTIFY_RECONN_TIMEOUT: "${acs_notify_reconn_timeout}"
{{-   if eq .Values.acs_loglevel "trace" }}
      ACS_LOG_DEBUG: "true"
      ACS_LOG_TRACE: "true"
{{-   else if eq .Values.acs_loglevel "debug" }}
      ACS_LOG_DEBUG: "true"
      ACS_LOG_TRACE: "false"
{{-   else }}
      ACS_LOG_DEBUG: "false"
      ACS_LOG_TRACE: "false"
{{-   end }}
      # these envs are only used to create the default region on first run
      CM_EXTERNAL_FQDN: "${acs_notify_upstream}"
      ACS_EXTERNAL_FQDN: "${acs_primary_external_fqdn}"
      # this is not required if REGION1.jwt has already been created
      CM_DEFAULT_REGION_JWT: "${default_region_jwt}"
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.nats.role: "{{ .Stack.Name }}/acsprimary"
      io.rancher.container.hostname_override: container_name
      # https://rancher.com/docs/rancher/v1.6/en/cattle/scheduling
      io.rancher.scheduler.affinity:container_label_soft_ne: io.nats.role={{ .Stack.Name }}/acsprimary
{{-   if (.Values.host_affinity_key_label) }}
      io.rancher.scheduler.affinity:host_label: "${host_affinity_key_label}.acs.primary={{ .Stack.Name }}"
{{-   end }}
{{-   if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{-   end }}
    # -----------------------------------
    # VOLUMES
    # - https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes
    # - specify vol name to use the specified volume
    # - just write path to create dynamic named volume
    # -----------------------------------
    volumes:
      - ${datavolume_name}_tokenstore:/data/token_store
{{-   if eq .Values.acs_ncred_readonly "true" }}
      - ${datavolume_name}_ncred:/data/ncred:ro
      - ${datavolume_name}_nsc:/data/nsc:ro
{{-   else }}
      - ${datavolume_name}_ncred:/data/ncred
      - ${datavolume_name}_nsc:/data/nsc
{{-   end }}
{{-   if eq .Values.acs_mount_nsckeys "true" }}
      - ${datavolume_name}_nsckeys:/data/nsckeys
{{-   end }}
    # -----------------------------------
    # LIMIT CPU
    # - can't use `cpus` in rancher 1.6, hacking it by using the older `cpu-quota`
    # -----------------------------------
{{-   if (.Values.docker_cpu_quota_limit) }}
    #cpus: ${docker_cpu_limit}
    cpu_quota: ${docker_cpu_quota_limit}
{{-   end }}
    cpu_shares: ${docker_cpu_weight_limit}
    # -----------------------------------
    # LIMIT RAM
    # -----------------------------------
{{-   if (.Values.docker_memory_limit) }}
    mem_limit: "${docker_memory_limit}m"
{{-   end }}
{{-   if (.Values.docker_memory_swap_limit) }}
    memswap_limit: "${docker_memory_swap_limit}m"
{{-   end }}
    # -----------------------------------
    # scaling and healthcheck
    # -----------------------------------
    scale: 1
    health_check:
      response_timeout: 2000
      healthy_threshold: 2
      port: 9090
      unhealthy_threshold: 3
      initializing_timeout: 300000
      interval: 5000
      strategy: recreate
      request_line: GET "/healthz" "HTTP/1.0"
      reinitializing_timeout: 120000
{{- end }}
{{- if or (eq .Values.acs_enable "replica") (eq .Values.acs_enable "primary_and_replica") }}
  # ************************************
  # SERVICE
  # - replica account server
  # ************************************
  acsreplica:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{-   if (.Values.docker_registry_name) }}
{{-     if (.Values.nats_image_custom) }}
    image: "${docker_registry_name}/${nats_image_custom}"
{{-     else }}
    image: "${docker_registry_name}/${nats_image}"
{{-     end }}
{{-   else }}
{{-     if (.Values.nats_image_custom) }}
    image: ${nats_image_custom}
{{-     else }}
    image: ${nats_image}
{{-     end }}
{{-   end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      CM_DISABLE: "yes"
      CM_DEFAULT_REGION_JWT: "${default_region_jwt}"
      ACS_DISABLE: "no"
      ACS_ENABLE_HTTPS: "no"
      ACS_STORE_READONLY: "false"
      ACS_STORE_SHARD: "${acs_shard_tokenstore}"
      ACS_LOG_COLOR: "false"
      ACS_LOG_PID: "false"
      ACS_PRIMARY: "${acs_primary_external_fqdn}"
      ACS_REPLICATE_TIMEOUT: "${acs_replicate_timeout}"
      ACS_REPLICATE_MAXSYNC: "${acs_replicate_maxsync}"
      ACS_READ_TIMEOUT: "${acs_read_timeout}"
      ACS_WRITE_TIMEOUT: "${acs_write_timeout}"
      ACS_NOTIFY_CMSERVERS: "${acs_notify_upstream}"
      ACS_NOTIFY_CONN_TIMEOUT: "${acs_notify_conn_timeout}"
      ACS_NOTIFY_RECONN_TIMEOUT: "${acs_notify_reconn_timeout}"
{{-   if eq .Values.acs_loglevel "trace" }}
      ACS_LOG_DEBUG: "true"
      ACS_LOG_TRACE: "true"
{{-   else if eq .Values.acs_loglevel "debug" }}
      ACS_LOG_DEBUG: "true"
      ACS_LOG_TRACE: "false"
{{-   else }}
      ACS_LOG_DEBUG: "false"
      ACS_LOG_TRACE: "false"
{{-   end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.nats.role: "{{ .Stack.Name }}/acsreplica"
      io.rancher.container.hostname_override: container_name
      # https://rancher.com/docs/rancher/v1.6/en/cattle/scheduling
      io.rancher.scheduler.affinity:container_label_soft_ne: io.nats.role={{ .Stack.Name }}/acsreplica
{{-   if (.Values.host_affinity_key_label) }}
      io.rancher.scheduler.affinity:host_label: "${host_affinity_key_label}.acs.replica={{ .Stack.Name }}"
{{-   end }}
{{-   if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{-   end }}
    # -----------------------------------
    # VOLUMES
    # - https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes
    # - specify vol name to use the specified volume
    # - just write path to create dynamic named volume
    # -----------------------------------
    volumes:
      - /data/token_store
      - ${datavolume_name}_ncred:/data/ncred:ro
    # -----------------------------------
    # LIMIT CPU
    # - can't use `cpus` in rancher 1.6, hacking it by using the older `cpu-quota`
    # -----------------------------------
{{-   if (.Values.docker_cpu_quota_limit) }}
    #cpus: ${docker_cpu_limit}
    cpu_quota: ${docker_cpu_quota_limit}
{{-   end }}
    cpu_shares: ${docker_cpu_weight_limit}
    # -----------------------------------
    # LIMIT RAM
    # -----------------------------------
{{-   if (.Values.docker_memory_limit) }}
    mem_limit: "${docker_memory_limit}m"
{{-   end }}
{{-   if (.Values.docker_memory_swap_limit) }}
    memswap_limit: "${docker_memory_swap_limit}m"
{{-   end }}
    # -----------------------------------
    # scaling and healthcheck
    # -----------------------------------
    scale: 1
    health_check:
      response_timeout: 2000
      healthy_threshold: 2
      port: 9090
      unhealthy_threshold: 3
      initializing_timeout: 300000
      interval: 5000
      strategy: recreate
      request_line: GET "/healthz" "HTTP/1.0"
      reinitializing_timeout: 120000
{{- end }}
{{- if eq .Values.cm_enable "standalone" }}
  # ************************************
  # SERVICE
  # - message server
  # ************************************
  cmserver:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{-   if (.Values.docker_registry_name) }}
{{-     if (.Values.nats_image_custom) }}
    image: "${docker_registry_name}/${nats_image_custom}"
{{-     else }}
    image: "${docker_registry_name}/${nats_image}"
{{-     end }}
{{-   else }}
{{-     if (.Values.nats_image_custom) }}
    image: ${nats_image_custom}
{{-     else }}
    image: ${nats_image}
{{-     end }}
{{-   end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      ACS_DISABLE: "yes"
      CM_DISABLE: "no"
      ACS_EXTERNAL_FQDN: "${acs_external_fqdn}"
      CM_SERVER_NAME: "cmnode1"
      CM_SYSTEM_ACCOUNT_ID: ""
      CM_DEFAULT_REGION_JWT: "${default_region_jwt}"
      CM_ENABLE_EDGE_NODE: "no"
      CM_ENABLE_GATEWAY: "no"
      CM_ENABLE_CLUSTER: "no"
      CM_DEAD_CLIENT_MAX_PING: "${cm_dead_client_max_ping}"
      CM_DEAD_CLIENT_SLOW_WRITE_DEADLINE: "${cm_dead_client_slow_write_deadline}s"
      CM_PING_INTERVAL: "${cm_ping_interval}s"
      CM_MAX_CLIENT_SUBS: "${cm_max_topic_subs}"
      CM_MAX_MSG_BUFFER: "${cm_max_msg_buffer_size}Mb"
      CM_MAX_MSG_HEADER: "${cm_max_header_size}Kb"
      CM_MAX_MSG_PAYLOAD: "${cm_max_payload_size}Kb"
      CM_MAX_CONNECTIONS: "${cm_max_header_size}Kb"
      CM_DISABLE_SUBLIST_CACHE: "${cm_disable_sublist_cache}"
      CM_GRACEFUL_SHUTDOWN_TIMEOUT: "${cm_graceful_shutdown}s"
      # logging
      CM_DEBUG_LOG: "${cm_debug_log}"
{{-   if eq .Values.cm_file_log "true" }}
      CM_LOG_FILE: "yes"
{{-   else }}
      CM_LOG_FILE: "no"
{{-   end }}
      # tls
      CM_TLS_UPGRADE_TIMEOUT: ${cm_tls_upgrade_timeout}
{{-   if eq .Values.cm_tls_custom_ca "true" }}
      CM_TLS_CUSTOM_CA: "yes"
      CM_TLS_ENABLE_INSECURE: "true"
{{-   else }}
      CM_TLS_CUSTOM_CA: "no"
      CM_TLS_ENABLE_INSECURE: "false"
{{-   end }}
{{-   if eq .Values.cm_tls "yes" }}
      CM_TLS_DISABLE: "no"
{{-   else if eq .Values.cm_tls "no" }}
      CM_TLS_DISABLE: "yes"
{{-   else }}
      CM_TLS_DISABLE: "auto"
{{-   end }}
    # -----------------------------------
    # Expose ports
    # -----------------------------------
    ports: # expose client port on host directly
      - 4222:4222/tcp
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.nats.role: "{{ .Stack.Name }}/server"
      io.rancher.container.hostname_override: container_name
      # https://rancher.com/docs/rancher/v1.6/en/cattle/scheduling
      io.rancher.scheduler.affinity:container_label_ne: io.nats.role={{ .Stack.Name }}/server
{{-   if (.Values.host_affinity_key_label) }}
      io.rancher.scheduler.affinity:host_label: "${host_affinity_key_label}.cm={{ .Stack.Name }}"
{{-   end }}
{{-   if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{-   end }}
    # -----------------------------------
    # VOLUMES
    # - https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes
    # - specify vol name to use the specified volume
    # - just write path to create dynamic named volume
    # -----------------------------------
    volumes:
      - /data/cmserver
      - ${datavolume_name}_ncred:/data/ncred:ro
{{-   if ne .Values.cm_tls "no" }}
      - ${datavolume_name}_certs:/etc/certkeys:ro
{{-   end }}
    # -----------------------------------
    # LIMIT CPU
    # - can't use `cpus` in rancher 1.6, hacking it by using the older `cpu-quota`
    # -----------------------------------
{{-   if (.Values.docker_cpu_quota_limit) }}
    #cpus: ${docker_cpu_limit}
    cpu_quota: ${docker_cpu_quota_limit}
{{-   end }}
    cpu_shares: ${docker_cpu_weight_limit}
    # -----------------------------------
    # LIMIT RAM
    # -----------------------------------
{{-   if (.Values.docker_memory_limit) }}
    mem_limit: "${docker_memory_limit}m"
{{-   end }}
{{-   if (.Values.docker_memory_swap_limit) }}
    memswap_limit: "${docker_memory_swap_limit}m"
{{-   end }}
    # -----------------------------------
    # scaling and healthcheck
    # -----------------------------------
    scale: 1
    health_check:
      response_timeout: 2000
      healthy_threshold: 2
      port: 8222
      unhealthy_threshold: 3
      initializing_timeout: 300000
      interval: 5000
      strategy: recreate
      request_line: GET "/mon" "HTTP/1.1"
      reinitializing_timeout: 120000
{{- end }}
{{- if or (eq .Values.cm_enable "cluster") (eq .Values.cm_enable "cluster_and_gateway") }}
  # ************************************
  # SERVICE
  # - seed message servers
  # ************************************
  cmnode:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{-   if (.Values.docker_registry_name) }}
{{-     if (.Values.nats_image_custom) }}
    image: "${docker_registry_name}/${nats_image_custom}"
{{-     else }}
    image: "${docker_registry_name}/${nats_image}"
{{-     end }}
{{-   else }}
{{-     if (.Values.nats_image_custom) }}
    image: ${nats_image_custom}
{{-     else }}
    image: ${nats_image}
{{-     end }}
{{-   end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      ACS_DISABLE: "yes"
      CM_DISABLE: "no"
      ACS_EXTERNAL_FQDN: "${acs_external_fqdn}"
      CM_SERVER_NAME: ""
      CM_SYSTEM_ACCOUNT_ID: ""
      CM_DEFAULT_REGION_JWT: "${default_region_jwt}" 
      CM_DEAD_CLIENT_MAX_PING: "${cm_dead_client_max_ping}" 
      CM_DEAD_CLIENT_SLOW_WRITE_DEADLINE: "${cm_dead_client_slow_write_deadline}s"
      CM_PING_INTERVAL: "${cm_ping_interval}s"
      CM_MAX_CLIENT_SUBS: "${cm_max_topic_subs}"
      CM_MAX_MSG_BUFFER: "${cm_max_msg_buffer_size}Mb"
      CM_MAX_MSG_HEADER: "${cm_max_header_size}Kb"
      CM_MAX_MSG_PAYLOAD: "${cm_max_payload_size}Kb"
      CM_MAX_CONNECTIONS: "${cm_max_header_size}Kb"
      CM_DISABLE_SUBLIST_CACHE: "${cm_disable_sublist_cache}"
      CM_GRACEFUL_SHUTDOWN_TIMEOUT: "${cm_graceful_shutdown}s"
      # logging
      CM_DEBUG_LOG: "${cm_debug_log}"
{{-   if eq .Values.cm_file_log "true" }}
      CM_LOG_FILE: "yes"
{{-   else }}
      CM_LOG_FILE: "no"
{{-   end }}
      # tls
      CM_TLS_UPGRADE_TIMEOUT: ${cm_tls_upgrade_timeout}
{{-   if eq .Values.cm_tls_custom_ca "true" }}
      CM_TLS_CUSTOM_CA: "yes"
      CM_TLS_ENABLE_INSECURE: "true"
{{-   else }}
      CM_TLS_CUSTOM_CA: "no"
      CM_TLS_ENABLE_INSECURE: "false"
{{-   end }}
{{-   if eq .Values.cm_tls "yes" }}
      CM_TLS_DISABLE: "no"
{{-   else if eq .Values.cm_tls "no" }}
      CM_TLS_DISABLE: "yes"
{{-   else }}
      CM_TLS_DISABLE: "auto"
{{-   end }}
      # clustering
      CM_ENABLE_CLUSTER: "yes"
      CM_CLUSTER_NAME: "${cm_cluster_name}"
      CM_CLUSTER_CONNECT_RETRIES: "${cm_cluster_connect_retries}"
      CM_CLUSTER_SECRET: "${cm_cluster_secret}"
      CM_CLUSTER_PEER_MIN: "1"
      CM_CLUSTER_PEER_MAX: "${cm_min_cluster_scale}"
      CM_CLUSTER_PEER_NAME_PATTERN: "{{ .Stack.Name }}-cmnode-%d"
      CM_CLUSTER_ROUTES: ""
      CM_CLUSTER_NAT_LISTEN: ""
{{-   if eq .Values.cm_cluster_advertise "true" }}
      CM_CLUSTER_DISABLE_ADVERTISE: "false"
{{-   else }}
      CM_CLUSTER_DISABLE_ADVERTISE: "true"
{{-   end }}
      CM_CLUSTER_TLS_CN: "${cm_cluster_tls_cn}"
{{-   if eq .Values.cm_cluster_tls "yes" }}
      CM_CLUSTER_TLS_DISABLE: "no"
{{-   else if eq .Values.cm_cluster_tls "no" }}
      CM_CLUSTER_TLS_DISABLE: "yes"
{{-   else }}
      CM_CLUSTER_TLS_DISABLE: "auto"
{{-   end }}
{{-   if eq .Values.cm_enable "cluster_and_gateway" }}
      CM_ENABLE_GATEWAY: "yes"
      CM_GATEWAY_NAT_LISTEN: ""
      CM_GATEWAY_TLS_CN: "${cm_gateway_tls_cn}"
      CM_GATEWAY_CONNECT_RETRIES: "${cm_gateway_connect_retries}"
      CM_GATEWAY_PEERS: "${cm_gateway_peers}"
{{-     if eq .Values.cm_gateway_autodiscover "true" }}
      CM_GATEWAY_DISABLE_AUTODISCOVER: "false"
{{-     else }}
      CM_GATEWAY_DISABLE_AUTODISCOVER: "true"
{{-     end }}
{{-   end }}
    # -----------------------------------
    # Expose ports
    # -----------------------------------
    ports: # expose client and gateway ports on host directly
      - 4222:4222/tcp
{{-   if eq .Values.cm_enable "cluster_and_gateway" }}
      - 5222:5222/tcp
{{-   end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.nats.role: "{{ .Stack.Name }}/server"
      io.rancher.container.hostname_override: container_name
      # https://rancher.com/docs/rancher/v1.6/en/cattle/scheduling
      io.rancher.scheduler.affinity:container_label_ne: io.nats.role={{ .Stack.Name }}/server
{{-   if (.Values.host_affinity_key_label) }}
      io.rancher.scheduler.affinity:host_label: "${host_affinity_key_label}.cm={{ .Stack.Name }}"
{{-   end }}
{{-   if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{-   end }}
    # -----------------------------------
    # VOLUMES
    # - https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes
    # - specify vol name to use the specified volume
    # - just write path to create dynamic named volume
    # -----------------------------------
    volumes:
      - /data/cmserver
      - ${datavolume_name}_ncred:/data/ncred:ro
{{-   if ne .Values.cm_tls "no" }}
      - ${datavolume_name}_certs:/etc/certkeys:ro
{{-   else if or (ne .Values.cm_cluster_tls "no") (eq .Values.cm_enable "cluster_and_gateway") }}
      - ${datavolume_name}_certs:/etc/certkeys:ro
{{-   end }}
    # -----------------------------------
    # LIMIT CPU
    # - can't use `cpus` in rancher 1.6, hacking it by using the older `cpu-quota`
    # -----------------------------------
{{-   if (.Values.docker_cpu_quota_limit) }}
    #cpus: ${docker_cpu_limit}
    cpu_quota: ${docker_cpu_quota_limit}
{{-   end }}
    cpu_shares: ${docker_cpu_weight_limit}
    # -----------------------------------
    # LIMIT RAM
    # -----------------------------------
{{-   if (.Values.docker_memory_limit) }}
    mem_limit: "${docker_memory_limit}m"
{{-   end }}
{{-   if (.Values.docker_memory_swap_limit) }}
    memswap_limit: "${docker_memory_swap_limit}m"
{{-   end }}
    # -----------------------------------
    # scaling and healthcheck
    # -----------------------------------
    scale: ${cm_core_cluster_scale}
    health_check:
      response_timeout: 2000
      healthy_threshold: 2
      port: 8222
      unhealthy_threshold: 3
      initializing_timeout: 300000
      interval: 5000
      strategy: recreate
      request_line: GET "/mon" "HTTP/1.0"
      reinitializing_timeout: 120000
{{- end }}

# +++++++++++++++++++++++
# END SERVICES
# +++++++++++++++++++++++

# +++++++++++++++++++++++
# BEGIN VOLUMES
# +++++++++++++++++++++++

volumes:
  # ************************************
  # VOLUME
  # - holds SYS account credential and token
  # ************************************
  {{.Values.datavolume_name}}_ncred:
{{- if eq .Values.volume_exists "true" }}
    external: true
{{- end }}
{{- if eq .Values.storage_driver "rancher-nfs" }}
    driver: rancher-nfs
{{-   if eq .Values.volume_exists "false" }}
{{-     if (.Values.storage_driver_nfsopts_host) }}
    driver_opts:
      host: ${storage_driver_nfsopts_host}
      exportBase: ${storage_driver_nfsopts_export}
{{-       if eq .Values.storage_retain_volume "true" }}
      onRemove: retain
{{-       else }}
      onRemove: purge
{{-       end }}
{{-     end }}
{{-   end }}
{{- else }}
    driver: local
{{- end }}

  # ************************************
  # VOLUME
  # - holds tokens used by nsc program
  # ************************************
  {{.Values.datavolume_name}}_nsc:
{{- if eq .Values.volume_exists "true" }}
    external: true
{{- end }}
{{- if eq .Values.storage_driver "rancher-nfs" }}
    driver: rancher-nfs
{{-   if eq .Values.volume_exists "false" }}
{{-     if (.Values.storage_driver_nfsopts_host) }}
    driver_opts:
      host: ${storage_driver_nfsopts_host}
      exportBase: ${storage_driver_nfsopts_export}
{{-       if eq .Values.storage_retain_volume "true" }}
      onRemove: retain
{{-       else }}
      onRemove: purge
{{-       end }}
{{-     end }}
{{-   end }}
{{- else }}
    driver: local
{{- end }}

{{- if eq .Values.acs_mount_nsckeys "true" }}
  # ************************************
  # VOLUME
  # - holds credentials used by nsc program
  # ************************************
  {{.Values.datavolume_name}}_nsckeys:
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
{{- end }}

{{- if or (eq .Values.acs_enable "primary") (eq .Values.acs_enable "primary_and_replica") }}
  # ************************************
  # VOLUME
  # - holds uploaded tokens by primary acs only
  # ************************************
  {{.Values.datavolume_name}}_tokenstore:
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
{{- end }}

{{- if or (ne .Values.cm_tls "no") (ne .Values.cm_cluster_tls "no") (eq .Values.cm_enable "cluster_and_gateway") }}
  # ************************************
  # VOLUME
  # - holds certificates and cert keys
  # ************************************
  {{.Values.datavolume_name}}_certs:
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
{{- end }}

# +++++++++++++++++++++++
# END VOLUMES
# +++++++++++++++++++++++

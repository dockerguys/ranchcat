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
  # - coredns server
  # ************************************
  coredns:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${coredns_image}"
{{- else }}
    image: ${coredns_image}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      COREDNS_FEATURE_BRANDING: "yes"
      COREDNS_BRAND_NAME: "${coredns_brand_name}"
      COREDNS_BRAND_AUTHOR: "${coredns_brand_author}"
      COREDNS_UPSTREAM_FORWARD: "${coredns_upstream_forward}"
      COREDNS_UPSTREAM_FORWARD_EXPIRE: "${coredns_upstream_expiry}s"
      COREDNS_UPSTREAM_FORWARD_POLICY: "${coredns_upstream_policy}"
      COREDNS_PRIVATE_DOMAINS: "${coredns_private_domains}"
{{- if eq .Values.coredns_enable_metrics "true" }}
      COREDNS_ENABLE_METRICS: "yes"
{{- else }}
      COREDNS_ENABLE_METRICS: "no"
{{- end }}
{{- if eq .Values.coredns_enable_zones "true" }}
      COREDNS_ENABLE_AUTOZONE: "yes"
{{- else }}
      COREDNS_ENABLE_AUTOZONE: "no"
{{- end }}
{{- if eq .Values.coredns_console_log "true" }}
      COREDNS_LOG_FILE: "no"
{{- else }}
      COREDNS_LOG_FILE: "yes"
{{- end }}
{{- if eq .Values.coredns_ratelimit_maxquery "0" }}
      COREDNS_ENABLE_RATELIMIT: "no"
{{- else }}
      COREDNS_ENABLE_RATELIMIT: "yes"
      COREDNS_RATELIMIT_LOG_ONLY: "no"
      COREDNS_RATELIMIT_SUCCESS: "${coredns_ratelimit_maxquery}"
      COREDNS_RATELIMIT_NODATA: "${coredns_ratelimit_maxquery}"
      COREDNS_RATELIMIT_NXDOMAIN: "${coredns_ratelimit_maxquery}"
      COREDNS_RATELIMIT_REFERRAL: "${coredns_ratelimit_maxquery}"
      COREDNS_RATELIMIT_ERROR: "${coredns_ratelimit_maxquery}"
      COREDNS_RATELIMIT_REQUESTS: "${coredns_ratelimit_maxquery}"
{{- end }}
{{- if (.Values.coredns_ipindn_domain) }}
      COREDNS_ENABLE_IPINDN: "yes"
      COREDNS_IPINDN_DOMAIN: "${coredns_ipindn_domain}"
      COREDNS_IPINDN_FALLTHROUGH: "no"
{{- end }}
{{- if (.Values.coredns_internal_upstream_server) }}
      COREDNS_INTERNAL_UPSTREAM_FORWARD: "${coredns_internal_upstream_server}"
{{- end }}
      COREDNS_INTERNAL_UPSTREAM_DOMAIN: "${coredns_internal_upstream_domain}"
{{- if eq .Values.coredns_expose_udp_port "true" }}
    # -----------------------------------
    # Expose ports
    # -----------------------------------
    ports: # expose port 53/udp on host directly
      - ${coredns_port}:53/udp
{{- end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.coredns.role: "{{ .Stack.Name }}/server"
      # hard anti-affinity rule to prevent >1 instance per host (port mapping conflict)
      io.coredns.host: dedicated
      io.rancher.scheduler.affinity:container_label_ne: io.coredns.host=dedicated
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
      - ${datavolume_name}_zones:/var/lib/coredns/zones:ro
      - ${datavolume_name}_static:/var/lib/coredns/static:ro
{{- else }}
      - /var/lib/coredns/zones:ro
      - /var/lib/coredns/static:ro
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
{{- if (.Values.docker_memory_limit) }}
    # -----------------------------------
    # LIMIT RAM
    # -----------------------------------
    mem_limit: "${docker_memory_limit}m"
    memswap_limit: "${docker_memory_limit}m"
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
  # - holds zone files
  # ************************************
  {{.Values.datavolume_name}}_zones:
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
  # - holds static hosts
  # ************************************
  {{.Values.datavolume_name}}_static:
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

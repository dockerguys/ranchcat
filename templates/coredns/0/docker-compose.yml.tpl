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
      COREDNS_FEATURE_BRANDING: true
      COREDNS_ENABLE_RANCHER_INTEGRATION: true
      COREDNS_BRAND_NAME: ${coredns_brand_name}
      COREDNS_BRAND_AUTHOR: ${coredns_brand_author}
      COREDNS_UPSTREAM_FORWARD: ${coredns_upstream_forward}
      COREDNS_PRIVATE_DOMAINS: ${coredns_private_domains}
      COREDNS_ENABLE_METRICS: ${coredns_enable_metrics}
    # -----------------------------------
    # Expose ports
    # -----------------------------------
    ports: # haproxy doesn't support udp
      - 5353:5353/tcp
      - 5353:5353/udp
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

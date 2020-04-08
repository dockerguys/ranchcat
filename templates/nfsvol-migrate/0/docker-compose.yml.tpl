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
  # - alpine image
  # ************************************
  nfsmigrator:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${migrate_image}"
{{- else }}
    image: ${migrate_image}
{{- end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.role.nfsmigrate: "{{ .Stack.Name }}/migrator"
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
    # -----------------------------------
    # Misc behavior
    # -----------------------------------
    tty: true
    stdin_open: true
    # -----------------------------------
    # VOLUMES
    # - https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes
    # - specify vol name to use the specified volume
    # - just write path to create dynamic named volume
    # -----------------------------------
    volumes:
      - ${volume1_name}:/srcvol/${volume1_name}:ro
      - remote1_mountvol:/destvol/${volume1_name}
{{- if (.Values.volume2_name) }}
      - ${volume2_name}:/srcvol/${volume2_name}:ro
      - remote2_mountvol:/destvol/${volume2_name}
{{- end }}
{{- if (.Values.volume3_name) }}
      - ${volume3_name}:/srcvol/${volume3_name}:ro
      - remote3_mountvol:/destvol/${volume3_name}
{{- end }}
{{- if (.Values.volume4_name) }}
      - ${volume4_name}:/srcvol/${volume4_name}:ro
      - remote4_mountvol:/destvol/${volume4_name}
{{- end }}
{{- if (.Values.volume5_name) }}
      - ${volume5_name}:/srcvol/${volume5_name}:ro
      - remote5_mountvol:/destvol/${volume5_name}
{{- end }}
{{- if (.Values.volume6_name) }}
      - ${volume6_name}:/srcvol/${volume6_name}:ro
      - remote6_mountvol:/destvol/${volume6_name}
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
# - stores the static files to serve
# - https://docs.docker.com/compose/compose-file/compose-file-v2/#volume-configuration-reference
# +++++++++++++++++++++++

volumes:
  # ************************************
  # VOLUME
  # ************************************
  {{.Values.volume1_name}}:
    external: true
    driver: ${storage_driver}

  # ************************************
  # VOLUME
  # ************************************
  remote1_mountvol:
    driver: rancher-nfs
    driver_opts:
      host: ${remote_nfs_host}
      export: ${remote_nfs_export_base}/${volume1_name}

{{- if (.Values.volume2_name) }}
  # ************************************
  # VOLUME
  # ************************************
  {{.Values.volume2_name}}:
    external: true
    driver: ${storage_driver}

  # ************************************
  # VOLUME
  # ************************************
  remote2_mountvol:
    driver: rancher-nfs
    driver_opts:
      host: ${remote_nfs_host}
      export: ${remote_nfs_export_base}/${volume2_name}
{{- end }}

{{- if (.Values.volume3_name) }}
  # ************************************
  # VOLUME
  # ************************************
  {{.Values.volume3_name}}:
    external: true
    driver: ${storage_driver}

  # ************************************
  # VOLUME
  # ************************************
  remote3_mountvol:
    driver: rancher-nfs
    driver_opts:
      host: ${remote_nfs_host}
      export: ${remote_nfs_export_base}/${volume3_name}
{{- end }}

{{- if (.Values.volume4_name) }}
  # ************************************
  # VOLUME
  # ************************************
  {{.Values.volume4_name}}:
    external: true
    driver: ${storage_driver}

  # ************************************
  # VOLUME
  # ************************************
  remote4_mountvol:
    driver: rancher-nfs
    driver_opts:
      host: ${remote_nfs_host}
      export: ${remote_nfs_export_base}/${volume4_name}
{{- end }}

{{- if (.Values.volume5_name) }}
  # ************************************
  # VOLUME
  # ************************************
  {{.Values.volume5_name}}:
    external: true
    driver: ${storage_driver}

  # ************************************
  # VOLUME
  # ************************************
  remote5_mountvol:
    driver: rancher-nfs
    driver_opts:
      host: ${remote_nfs_host}
      export: ${remote_nfs_export_base}/${volume5_name}
{{- end }}

{{- if (.Values.volume6_name) }}
  # ************************************
  # VOLUME
  # ************************************
  {{.Values.volume6_name}}:
    external: true
    driver: ${storage_driver}

  # ************************************
  # VOLUME
  # ************************************
  remote6_mountvol:
    driver: rancher-nfs
    driver_opts:
      host: ${remote_nfs_host}
      export: ${remote_nfs_export_base}/${volume6_name}
{{- end }}

# +++++++++++++++++++++++
# END VOLUMES
# +++++++++++++++++++++++

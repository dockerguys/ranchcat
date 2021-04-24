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
  alpine:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${alpine_image}"
{{- else }}
    image: ${alpine_image}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
{{- if eq .Values.alpine_sync_disk "true" }}
      SYSTEM_SYNC_DISKS: "yes"
{{- else }}
      SYSTEM_SYNC_DISKS: "no"
{{- end }}
{{- if eq .Values.alpine_log_file "true" }}
      SYSTEM_LOG_FILE: "all"
{{- end }}
{{- if eq .Values.alpine_ro_root "true" }}
      SYSTEM_READ_ONLY_ROOT: "yes"
{{- else }}
      SYSTEM_READ_ONLY_ROOT: "no"
{{- end }}
{{- if (.Values.alpine_log_opts) }}
      SYSTEM_LOG_OPTIONS: "${alpine_log_opts}"
{{- end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.testing.os: "alpine-linux"
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
{{- if (.Values.datavolume1_name) }}
    # -----------------------------------
    # VOLUMES
    # - https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes
    # - specify vol name to use the specified volume
    # - just write path to create dynamic named volume
    # -----------------------------------
    volumes:
{{-   if eq .Values.mount_ro "true" }}
      - ${datavolume1_name}:${volume_mountpoint}/${datavolume1_name}:ro
{{-   else }}
      - ${datavolume1_name}:${volume_mountpoint}/${datavolume1_name}
{{-   end }}
{{-   if (.Values.datavolume2_name) }}
{{-     if eq .Values.mount_ro "true" }}
      - ${datavolume2_name}:${volume_mountpoint}/${datavolume2_name}:ro
{{-     else }}
      - ${datavolume2_name}:${volume_mountpoint}/${datavolume2_name}
{{-     end }}
{{-   end }}
{{-   if (.Values.datavolume3_name) }}
{{-     if eq .Values.mount_ro "true" }}
      - ${datavolume3_name}:${volume_mountpoint}/${datavolume3_name}:ro
{{-     else }}
      - ${datavolume3_name}:${volume_mountpoint}/${datavolume3_name}
{{-     end }}
{{-   end }}
{{-   if (.Values.datavolume4_name) }}
{{-     if eq .Values.mount_ro "true" }}
      - ${datavolume4_name}:${volume_mountpoint}/${datavolume4_name}:ro
{{-     else }}
      - ${datavolume4_name}:${volume_mountpoint}/${datavolume4_name}
{{-     end }}
{{-   end }}
{{-   if (.Values.datavolume5_name) }}
{{-     if eq .Values.mount_ro "true" }}
      - ${datavolume5_name}:${volume_mountpoint}/${datavolume5_name}:ro
{{-     else }}
      - ${datavolume5_name}:${volume_mountpoint}/${datavolume5_name}
{{-     end }}
{{-   end }}
{{-   if (.Values.datavolume6_name) }}
{{-     if eq .Values.mount_ro "true" }}
      - ${datavolume6_name}:${volume_mountpoint}/${datavolume6_name}:ro
{{-     else }}
      - ${datavolume6_name}:${volume_mountpoint}/${datavolume6_name}
{{-     end }}
{{-   end }}
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

{{- if (.Values.datavolume1_name) }}
# +++++++++++++++++++++++
# BEGIN VOLUMES
# +++++++++++++++++++++++
volumes:
  # ************************************
  # VOLUME
  # - first vol
  # ************************************
  {{.Values.datavolume1_name}}:
    external: true
    driver: ${storage_driver}

{{- if (.Values.datavolume2_name) }}
  # ************************************
  # VOLUME
  # - vol2
  # ************************************
  {{.Values.datavolume2_name}}:
    external: true
    driver: ${storage_driver}
{{- end }}

{{- if (.Values.datavolume3_name) }}
  # ************************************
  # VOLUME
  # - vol3
  # ************************************
  {{.Values.datavolume3_name}}:
    external: true
    driver: ${storage_driver}
{{- end }}

{{- if (.Values.datavolume4_name) }}
  # ************************************
  # VOLUME
  # - vol4
  # ************************************
  {{.Values.datavolume4_name}}:
    external: true
    driver: ${storage_driver}
{{- end }}

{{- if (.Values.datavolume5_name) }}
  # ************************************
  # VOLUME
  # - vol5
  # ************************************
  {{.Values.datavolume5_name}}:
    external: true
    driver: ${storage_driver}
{{- end }}

{{- if (.Values.datavolume6_name) }}
  # ************************************
  # VOLUME
  # - vol6
  # ************************************
  {{.Values.datavolume6_name}}:
    external: true
    driver: ${storage_driver}
{{- end }}

# +++++++++++++++++++++++
# END VOLUMES
# +++++++++++++++++++++++
{{- end }}

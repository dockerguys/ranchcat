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
  # - openssh server
  # ************************************
  openssh:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
{{-   if (.Values.openssh_image_custom) }}
    image: "${docker_registry_name}/${openssh_image_custom}"
{{-   else }}
    image: "${docker_registry_name}/${openssh_image}"
{{-   end }}
{{- else }}
{{-   if (.Values.v2ray_image_custom) }}
    image: ${openssh_image_custom}
{{-   else }}
    image: ${openssh_image}
{{-   end }}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      SSH_GROUP_NAME: ${ssh_group}
      SSH_GROUP_GID: ${ssh_gid}
      SSH_SYSTEM_USER: ${ssh_system_user}
      SSH_USER_NAME: ${ssh_user}
      SSH_USER_UID: ${ssh_uid}
      SSH_USER_PASSWORD_HASHED: ${ssh_hash_password}
{{- if (.Values.ssh_user_display_name) }}
      SSH_USER_DISPLAY_NAME: "${ssh_user_display_name}"
{{- end }}
{{- if (.Values.ssh_password) }}
      SSH_USER_PASSWORD: "${ssh_password}"
{{- end }}
{{- if (.Values.ssh_key) }}
      SSH_USER_SSHKEY: "${ssh_key}"
{{- end }}
      SSH_ROOT_LOGON: ${ssh_root_logon}
      SSH_ENABLE_PASSWORD_AUTH: ${ssh_password_auth}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.openssh.role: "{{ .Stack.Name }}/server"
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
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
    memswap_limit: "${docker_memory_limit}m"
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

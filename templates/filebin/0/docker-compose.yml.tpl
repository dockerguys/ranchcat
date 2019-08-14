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
  # - main database server
  # ************************************
  filebin:
    # -----------------------------------
    # Image
    # - support private registry
    # -----------------------------------
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${filebin_image}"
{{- else }}
    image: ${filebin_image}
{{- end }}
    # -----------------------------------
    # ENV
    # -----------------------------------
    environment:
      FILEBIN_RATE_LIMIT: ${rate_limit}
      FILEBIN_PROVIDER: ${storage_provider}
{{- if eq .Values.storage_provider "s3" }}
      FILEBIN_S3_ENDPOINT: ${s3_endpoint}
      FILEBIN_S3_REGION: ${s3_region}
      FILEBIN_AWS_ACCESS_KEY: ${s3_aws_access_key}
      FILEBIN_AWS_SECRET_KEY: ${s3_aws_secret_key}
      FILEBIN_S3_BUCKET: ${s3_bucket}
      FILEBIN_S3_NO_MULTIPART: ${s3_no_multipart}
      FILEBIN_S3_PATH_STYLE: ${s3_path_style}
{{- end }}
{{- if eq .Values.storage_provider "gdrive" }}
      FILEBIN_GDRIVE_CLIENT_JSON_FILE_PATH: ${gdrive_client_json_file}
      FILEBIN_GDRIVE_LOCAL_CONFIG_PATH: ${gdrive_local_config_path}
      FILEBIN_GDRIVE_CHUNK_SIZE: ${gdrive_chunk_size}
{{- end }}
{{- if eq .Values.enable_profiler "true" }}
      FILEBIN_ENABLE_PROFILER: true
{{- end }}
{{- if eq .Values.console_log "true" }}
      FILEBIN_CONSOLE_LOG: true
{{- end }}
{{- if (.Values.http_auth_user) }}
      FILEBIN_BASIC_AUTH_USER: ${http_auth_user}
{{- end }}
{{- if (.Values.http_auth_password) }}
      FILEBIN_BASIC_AUTH_PASSWORD: ${http_auth_password}
{{- end }}
{{- if (.Values.ip_whitelist) }}
      FILEBIN_IP_WHITELIST: ${ip_whitelist}
{{- end }}
{{- if (.Values.ip_blacklist) }}
      FILEBIN_IP_BLACKLIST: ${ip_blacklist}
{{- end }}
{{- if (.Values.filebin_extargs) }}
      FILEBIN_EXT_ARGS: ${filebin_extargs}
{{- end }}
    # -----------------------------------
    # Scheduler labels
    # -----------------------------------
    labels:
      io.filebin.role: "{{ .Stack.Name }}/server"
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
      - ${datavolume_name}_filebin:/storage
{{- else }}
{{-   if (.Values.host_database_mountpoint) }}
      - ${host_database_mountpoint}:/storage
{{-   else }}
      - /storage
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


# +++++++++++++++++++++++
# BEGIN VOLUMES
# - stores database files
# - https://docs.docker.com/compose/compose-file/compose-file-v2/#volume-configuration-reference
# +++++++++++++++++++++++

{{- if (.Values.datavolume_name) }}
volumes:
  # ************************************
  # VOLUME
  # - holds the database
  # ************************************
  {{.Values.datavolume_name}}_filebin:
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

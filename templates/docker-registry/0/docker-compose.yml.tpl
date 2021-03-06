version: '2'
services:
  registry-data:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/busybox"
{{- else }}
    image: busybox
{{- end }}
    labels:
      io.rancher.container.start_once: true
    volumes:
      - /var/lib/registry
      - /certs
    command:
      - /bin/sh
      - -c
      - |
        echo '-----BEGIN CERTIFICATE-----' > /certs/registry_trust_chain.pem
        echo '${oauth_cert}' >> /certs/registry_trust_chain.pem
        echo '-----END CERTIFICATE-----' >> /certs/registry_trust_chain.pem
  registry:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${registry_image}"
{{- else }}
    image: ${registry_image}
{{- end }}
    labels:
      io.rancher.sidekicks: registry-data
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}
{{- if eq .Values.repull_image "always" }}
      io.rancher.container.pull_image: always
{{- end }}
    volumes_from:
      - registry-data
    environment:
      REGISTRY_LOG_LEVEL: warn
      REGISTRY_LOG_ACCESSLOG_DISABLED: false
      REGISTRY_STORAGE_DELETE_ENABLED: true
      REGISTRY_HTTP_SECRET: ${registry_shared_secret}
      REGISTRY_AUTH: token
      REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE: /certs/registry_trust_chain.pem
      REGISTRY_AUTH_TOKEN_REALM: ${oauth_token_realm_url}
      REGISTRY_AUTH_TOKEN_SERVICE: ${oauth_token_service_name}
      REGISTRY_AUTH_TOKEN_ISSUER: ${oauth_token_issuer_url}
    tty: true
    stdin_open: true

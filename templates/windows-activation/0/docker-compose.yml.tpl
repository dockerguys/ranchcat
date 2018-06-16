version: '2'
services:
  winkms:
{{- if (.Values.docker_registry_name) }}
    image: "${docker_registry_name}/${winkms_image}"
{{- else }}
    image: ${winkms_image}
{{- end }}
    labels:
	    io.rancher.container.pull_image: ${repull_image}
{{- if (.Values.host_affinity_label) }}
      io.rancher.scheduler.affinity:host_label: ${host_affinity_label}
{{- end }}

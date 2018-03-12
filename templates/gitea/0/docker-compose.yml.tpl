version: '2'
services:
  gitea-data:
    image: busybox
    labels:
      io.rancher.container.start_once: true
    volumes:
      - /data
  gitea:
    image: ${gitea_image}
    external_links:
      - ${db_service}:db
    labels:
      io.rancher.sidekicks: gitea-data
    volumes_from:
      - gitea-data

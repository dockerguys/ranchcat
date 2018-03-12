version: '2'
services:
  gogs-data:
    image: busybox
    labels:
      io.rancher.container.start_once: true
    volumes:
      - /data
  gogs:
    image: ${gogs_image}
    labels:
      io.rancher.sidekicks: mysql-data
    volumes_from:
      - gogs-data

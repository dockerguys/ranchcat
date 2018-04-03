version: '2'
services:
 redis:
    image: redis:3
    labels:
     io.rancher.container.pull_image: always
    environment:
     BIND_ADDRESS: ${BIND_ADDRESS}
     COMPOSE_PROJECT_NAME: ${COMPOSE_PROJECT_NAME}
     DEBUG: ${DEBUG}
     DOMAIN: ${DOMAIN}
     ENABLE_CERTBOT: False
     EXPOSE_ADMIN: ${EXPOSE_ADMIN}
     FETCHMAIL_DELAY: ${FETCHMAIL_DELAY}
     FRONTEND: none
     HOSTNAME: ${HOSTNAME}
     MESSAGE_SIZE_LIMIT: ${MESSAGE_SIZE_LIMIT}
     POSTMASTER: ${POSTMASTER}
     RELAYHOST: ${RELAYHOST}
     RELAYNETS: ${RELAYNETS}
     ROOT: ${ROOT}
     SECRET_KEY: ${SECRET_KEY}
     VERSION: ${VERSION}
     WEBMAIL: none
     WEBDAV: none
    restart: always
    volumes:
      - "${ROOT}/redis:/data"
 imap:
    image: mailu/dovecot:${VERSION}
    labels:
     io.rancher.container.pull_image: always
    environment:
     FETCHMAIL_KEEP: ${FETCHMAIL_KEEP}
     BIND_ADDRESS: ${BIND_ADDRESS}
     COMPOSE_PROJECT_NAME: ${COMPOSE_PROJECT_NAME}
     DEBUG: ${DEBUG}
     DOMAIN: ${DOMAIN}
     ENABLE_CERTBOT: False
     EXPOSE_ADMIN: ${EXPOSE_ADMIN}
     FETCHMAIL_DELAY: ${FETCHMAIL_DELAY}
     FRONTEND: none
     HOSTNAME: ${HOSTNAME}
     MESSAGE_SIZE_LIMIT: ${MESSAGE_SIZE_LIMIT}
     POSTMASTER: ${POSTMASTER}
     RELAYHOST: ${RELAYHOST}
     RELAYNETS: ${RELAYNETS}
     ROOT: ${ROOT}
     SECRET_KEY: ${SECRET_KEY}
     VERSION: ${VERSION}
     WEBMAIL: none
     WEBDAV: none
    restart: always
    volumes:
      - "${ROOT}/data:/data"
      - "${ROOT}/mail:/mail"
      - "${ROOT}/overrides:/overrides"
 smtp:
    image: mailu/postfix:${VERSION}
    restart: always
    labels:
     io.rancher.container.pull_image: always
    environment:
     FETCHMAIL_KEEP: ${FETCHMAIL_KEEP}
     BIND_ADDRESS: ${BIND_ADDRESS}
     COMPOSE_PROJECT_NAME: ${COMPOSE_PROJECT_NAME}
     DEBUG: ${DEBUG}
     DOMAIN: ${DOMAIN}
     ENABLE_CERTBOT: False
     EXPOSE_ADMIN: ${EXPOSE_ADMIN}
     FETCHMAIL_DELAY: ${FETCHMAIL_DELAY}
     FRONTEND: none
     HOSTNAME: ${HOSTNAME}
     MESSAGE_SIZE_LIMIT: ${MESSAGE_SIZE_LIMIT}
     POSTMASTER: ${POSTMASTER}
     RELAYHOST: ${RELAYHOST}
     RELAYNETS: ${RELAYNETS}
     ROOT: ${ROOT}
     SECRET_KEY: ${SECRET_KEY}
     VERSION: ${VERSION}
     WEBMAIL: none
     WEBDAV: none
    volumes:
      - "${ROOT}/data:/data"
      - "${ROOT}/overrides:/overrides"
 milter:
    image: mailu/rmilter:${VERSION}
    labels:
     io.rancher.container.pull_image: always
    restart: always
    environment:
     FETCHMAIL_KEEP: ${FETCHMAIL_KEEP}
     BIND_ADDRESS: ${BIND_ADDRESS}
     COMPOSE_PROJECT_NAME: ${COMPOSE_PROJECT_NAME}
     DEBUG: ${DEBUG}
     DOMAIN: ${DOMAIN}
     ENABLE_CERTBOT: False
     EXPOSE_ADMIN: ${EXPOSE_ADMIN}
     FETCHMAIL_DELAY: ${FETCHMAIL_DELAY}
     FRONTEND: none
     HOSTNAME: ${HOSTNAME}
     MESSAGE_SIZE_LIMIT: ${MESSAGE_SIZE_LIMIT}
     POSTMASTER: ${POSTMASTER}
     RELAYHOST: ${RELAYHOST}
     RELAYNETS: ${RELAYNETS}
     ROOT: ${ROOT}
     SECRET_KEY: ${SECRET_KEY}
     VERSION: ${VERSION}
     WEBMAIL: none
     WEBDAV: none
    volumes:
      - "${ROOT}/filter:/data"
      - "${ROOT}/dkim:/dkim"
      - "${ROOT}/overrides:/overrides"
 antispam:
    image: mailu/rspamd:${VERSION}
    restart: always
    labels:
     io.rancher.container.pull_image: always
    environment:
     FETCHMAIL_KEEP: ${FETCHMAIL_KEEP}
     BIND_ADDRESS: ${BIND_ADDRESS}
     COMPOSE_PROJECT_NAME: ${COMPOSE_PROJECT_NAME}
     DEBUG: ${DEBUG}
     DOMAIN: ${DOMAIN}
     ENABLE_CERTBOT: False
     EXPOSE_ADMIN: ${EXPOSE_ADMIN}
     FETCHMAIL_DELAY: ${FETCHMAIL_DELAY}
     FRONTEND: none
     HOSTNAME: ${HOSTNAME}
     MESSAGE_SIZE_LIMIT: ${MESSAGE_SIZE_LIMIT}
     POSTMASTER: ${POSTMASTER}
     RELAYHOST: ${RELAYHOST}
     RELAYNETS: ${RELAYNETS}
     ROOT: ${ROOT}
     SECRET_KEY: ${SECRET_KEY}
     VERSION: ${VERSION}
     WEBMAIL: none
     WEBDAV: none
    volumes:
      - "${ROOT}/filter:/var/lib/rspamd"
 antivirus:
    image: mailu/clamav:${VERSION}
    restart: always
    labels:
     io.rancher.container.pull_image: always
    environment:
     FETCHMAIL_KEEP: ${FETCHMAIL_KEEP}
     BIND_ADDRESS: ${BIND_ADDRESS}
     COMPOSE_PROJECT_NAME: ${COMPOSE_PROJECT_NAME}
     DEBUG: ${DEBUG}
     DOMAIN: ${DOMAIN}
     ENABLE_CERTBOT: False
     EXPOSE_ADMIN: ${EXPOSE_ADMIN}
     FETCHMAIL_DELAY: ${FETCHMAIL_DELAY}
     FRONTEND: ${FRONTEND}
     HOSTNAME: ${HOSTNAME}
     MESSAGE_SIZE_LIMIT: ${MESSAGE_SIZE_LIMIT}
     POSTMASTER: ${POSTMASTER}
     RELAYHOST: ${RELAYHOST}
     RELAYNETS: ${RELAYNETS}
     ROOT: ${ROOT}
     SECRET_KEY: ${SECRET_KEY}
     VERSION: ${VERSION}
     WEBMAIL: none
     WEBDAV: none
    volumes:
      - "${ROOT}/filter:/data"
 admin:
    image: mailu/admin:${VERSION}
    restart: always
    labels:
     io.rancher.container.pull_image: always
    environment:
     FETCHMAIL_KEEP: ${FETCHMAIL_KEEP}
     BIND_ADDRESS: ${BIND_ADDRESS}
     COMPOSE_PROJECT_NAME: ${COMPOSE_PROJECT_NAME}
     DEBUG: ${DEBUG}
     DOMAIN: ${DOMAIN}
     ENABLE_CERTBOT: False
     EXPOSE_ADMIN: ${EXPOSE_ADMIN}
     FETCHMAIL_DELAY: ${FETCHMAIL_DELAY}
     FRONTEND: ${FRONTEND}
     HOSTNAME: ${HOSTNAME}
     MESSAGE_SIZE_LIMIT: ${MESSAGE_SIZE_LIMIT}
     POSTMASTER: ${POSTMASTER}
     RELAYHOST: ${RELAYHOST}
     RELAYNETS: ${RELAYNETS}
     ROOT: ${ROOT}
     SECRET_KEY: ${SECRET_KEY}
     VERSION: ${VERSION}
     WEBMAIL: none
     WEBDAV: none
    volumes:
      - "${ROOT}/data:/data"
      - "${ROOT}/dkim:/dkim"
      - /var/run/docker.sock:/var/run/docker.sock:ro
 fetchmail:
    image: mailu/fetchmail:${VERSION}
    restart: always
    labels:
     io.rancher.container.pull_image: always
    environment:
     FETCHMAIL_KEEP: ${FETCHMAIL_KEEP}
     BIND_ADDRESS: ${BIND_ADDRESS}
     COMPOSE_PROJECT_NAME: ${COMPOSE_PROJECT_NAME}
     DEBUG: ${DEBUG}
     DOMAIN: ${DOMAIN}
     ENABLE_CERTBOT: False
     EXPOSE_ADMIN: ${EXPOSE_ADMIN}
     FETCHMAIL_DELAY: ${FETCHMAIL_DELAY}
     FRONTEND: none
     HOSTNAME: ${HOSTNAME}
     MESSAGE_SIZE_LIMIT: ${MESSAGE_SIZE_LIMIT}
     POSTMASTER: ${POSTMASTER}
     RELAYHOST: ${RELAYHOST}
     RELAYNETS: ${RELAYNETS}
     ROOT: ${ROOT}
     SECRET_KEY: ${SECRET_KEY}
     VERSION: ${VERSION}
     WEBMAIL: none
     WEBDAV: none
    volumes:
      - "${ROOT}/data:/data"

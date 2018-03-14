version: '2'
services:
  shadowsocks-server:
    image: ${shadowsocks_image}
    tty: true
    stdin_open: true
    labels:
      # label all hosts that you prefer to run shadowsocks server with this
      io.rancher.scheduler.affinity:host_label: io.fabric.connectivity.obfus=ssobfus
    environment:
      SS_CRYPTO: ${ss_crypto}
      SS_TIMEOUT: ${ss_timeout}
      SS_FASTOPEN: ${ss_fastopen}
      SS_REUSE_PORT: ${ss_reuse_port}
      SS_EXTERNAL_DNS: ${ss_external_dns}
      SS_MODE: ${ss_mode}
      SS_KEY: ${ss_key}
      KCPTUN_CRYPTO: ${kcptun_crypto}
      KCPTUN_MODE: ${kcptun_mode}
      KCPTUN_MTU: ${kcptun_mtu}
      KCPTUN_SNDWND: ${kcptun_sndwnd}
      KCPTUN_RCVWND: ${kcptun_rcvwnd}
      KCPTUN_NOCOMP: ${kcptun_nocomp}
      KCPTUN_KEY: ${kcptun_key}
    ports: # haproxy doesn't support udp
    - 53000:53000/tcp
    - 53000:53000/udp
    - 34567:34567/udp

Shadowsocks Server
==================
Active traffic obfuscation protocol using SOCKS5 proxy. You will need a compatible client.

Services
--------
Includes the following services:
- Shadowsocks server (with KCPTUN support)

What's not included:
- Shadowsocks web administration

Usage
-----
1. Make sure port 53000 and 34567 are not used. We cannot use HAProxy here because it does not support UDP.
2. Download a compatible client and point traffic directly to the host IP and port 53000 (or 34567 for KCPTUN)

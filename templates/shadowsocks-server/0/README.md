Shadowsocks Server
==================

What is Shadowsocks
-------------------
Active traffic obfuscation protocol using SOCKS5 proxy. You will need a compatible client.


Services
--------
Includes the following services:
- Shadowsocks server (with KCPTUN support)

What's not included:
- Load balancer
- Shadowsocks web administration

Usage
-----
1. Update your load balancer to point 443 to 8080 (UI/https) of the Keycloak service.
2. Download a compatible client and point traffic to 53000 (or 34567 for KCPTUN)

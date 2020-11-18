OpenSSH Server
============
OpenSSH is the premier connectivity tool for remote login with the SSH protocol. It encrypts all traffic to eliminate 
eavesdropping, connection hijacking, and other attacks. In addition, OpenSSH provides a large suite of secure tunneling 
capabilities, several authentication methods, and sophisticated configuration options.

Services
--------
Includes the following services:
- OpenSSH server

Usage
-----
1. User/group will be created on first launch. Subsequent restarts will skip checks so long as user/group exists.
2. Adjust load balancer to proxy to port 22 on OpenSSH server via TCP.
3. Download a compatible SSH client to connect.

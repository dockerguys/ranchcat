V2Ray Server
============
V2Ray is a network communication obfuscation server. You need a compatible client.

Services
--------
Includes the following services:
- V2Ray core server

What's not included:
- V2Ray web administration

Usage
-----
1. Make sure port 53000 and 34567 are not used. We cannot use HAProxy here because it does not support UDP.
2. Download a compatible client and point traffic directly to the host IP and port 53000 (or 34567 for KCPTUN)

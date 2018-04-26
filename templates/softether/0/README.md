SoftEther VPN
=============
All-in-one VPN solution featuring various protocols. You need a compatible administration tool to manage the server.

Services
--------
Includes the following services:
- Softether VPN

What's not included:
- Softether web administration

Usage
-----
1. Make sure ports 1194, 500 and 4500 are not used. We cannot use HAProxy here because it does not support UDP.
2. Update your load balancer to point the following ports to the softether service: 443, 992 and 5555
3. Download a compatible management client to perform administration tasks.

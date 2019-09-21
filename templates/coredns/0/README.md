CoreDNS
=======
CoreDNS is a DNS server that chains plugins.

Services
--------
Includes the following services:
- CoreDNS server

Usage
-----
1. Make sure port 5353 is not used. We cannot use HAProxy here because it does not support UDP.

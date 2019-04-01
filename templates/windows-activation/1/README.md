Windows KMS
===========
This is a service for activating licensed Windows products. Do not expose the service publically.

Services
--------
Includes the following services:
- Windows KMS server

What's not included:
- Load balancer

Usage
-----
1. Start this stack
2. Update your load balancer to point 1688 to 1688 (tcp) of the winkms service.

Docker Registry
===============
A private docker registry where you can push images. The registry is protected by OAuth2 authentication service.

Services
--------
Includes the following services:
- Docker registry

What's not included:
- Load balancer
- Authentication service

Usage
-----
1. Create your client on the authencation service.
2. Update your load balancer to point 5000 to the registry service.

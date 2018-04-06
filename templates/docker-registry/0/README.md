Docker Registry
===============
A self-hosted docker registry where you can private images live safely. 

This implementation protects the registry using OAuth2 authentication.

Services
--------
Includes the following services:
- Docker registry

What's not included:
- Load balancer
- LetsEncrypt stack
- Authentication stack (Keycloak)

Usage
-----
1. Create a new realm on Keycloak or use an existing realm (all users in the realm will have full access to the registry)
   - Clients > Create > (Client ID: docker-registry | Client Protocol : docker-v2) > Save
   - Answers to some questions below are available in `Clients > docker-registry > Installation > Variable Override`
   - OAuth certificate is in `Realm > Keys > Certificate`. **DO NOT** add 'BEGIN CERTIFICATE' or 'END CERTIFICATE', they will be added automatically.
2. Update your load balancer to point your docker (sub)domain (port 443/HTTPS) to port 5000 of the registry service (e.g. Public | HTTPS | mydocker.lizoc.com | 443 | registry | 5000).
3. Make sure your domain nameserver points your docker (sub)domain to this rancher infrastructure.
4. Test things work on a linux machine with docker installed:

```
# docker login -u admin -p MySecRetPass mydocker.lizoc.com
Login Succeeded

# docker pull mydocker.lizoc.com/busybox
Using default tag: latest
Error response from daemon: manifest for mydocker.lizoc.com/busybox:latest not found

# docker pull busybox
# docker tag busybox:latest mydocker.lizoc.com/busybox:latest
# docker push mydocker.lizoc.com/busybox:latest
# docker rmi busybox
# docker pull mydocker.lizoc.com/busybox
```

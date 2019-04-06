Keycloak
========
A complete self-hosted single sign-on (SSO) solution.

Keycloak requires a minimum of 512MB memory and 1G of disk space for production deployment scenarios.


Services
--------
Includes the following services:
- Keycloak server

What's not included:
- Load balancer
- Database server (MySQL/Postgres)

Usage
-----
1. Create your database first (user: keycloakapp, db keycloak - utf8_general_ci). We use MySQL here.
2. Update your load balancer to point 443 to 8080 (UI/https) of the Keycloak service.
3. Go to the web UI and perform setup.

Caveats
-------
Set `-Djboss.as.management.blocking.timeout=600` or even 1200 to prevent timeout errors on low-end servers. Keycloak may timeout and 
reinitialize before it can prepare the database.


For Developers
--------------
First, enable debug mode to turn off optimizations.

After service is running, go into the container via web console and run the following:

```bash
apk add openssh
ssh-keygen -t ed25519 -b 4096 -f /etc/ssh/ssh_host_ed25519_key -N ""
ssh-keygen -t ecdsa -b 256 -f /etc/ssh/ssh_host_ecdsa_key -N ""
ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ""
ssh-keygen -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N ""
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/g' /etc/ssh/sshd_config
$(which sshd)
ps -a | grep sshd
```

Then configure your load balancer to forward your favorite port to port 22 (TCP) of the keycloak server container.

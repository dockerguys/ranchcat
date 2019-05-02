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
First, enable debug mode to turn off optimizations. This will enable Keycloak to hot-load your theme changes without restarting itself.

Then enable volumes. The keycloak service will mount two volumes:
- `{datavolume_name}_data` -> /opt/jboss/keycloak/standalone/data
- `{datavolume_name}_theme` -> /opt/jboss/keycloak/themes

The `theme` volume is what we are interested in, since Keycloak will look for themes in this path only. Make changes to the theme files 
by sharing this theme volume with another container that has editing functionality (see below).

Some important things to note:
- make sure everything in the theme directory is chowned by `jboss:root` (or `1000:root`).
- directories should have chmod 775, files should be 664.
- do not touch the following stock theme directories on the theme volume if they exist: base, keycloak, keycloak-preview

Whenever keycloak service restarts:
- Permissions will be automatically re-enforced
- The stock theme directories are overriden by default contents

### Basic SSH server

This is a very basic SSH server setup, which you can use to get access to keycloak theme files:

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

Then configure your load balancer to forward your favorite port to port 22 (TCP) of the SSH server container.

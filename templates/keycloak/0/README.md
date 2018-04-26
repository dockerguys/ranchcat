Keycloak
========
A complete self-hosted single sign-on (SSO) solution.

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

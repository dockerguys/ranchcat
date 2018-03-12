Gitea
=====

What is Gitea
------------
Lightweight GitHub clone. GitHub and GitLab hardware requirements are high (e.g. 4GB ram). Gogs and Gitea are clones that 
are very lightweight, but not suitable for large scale usage.

Gogs has a problem with MariaDB 10.1. Gitea seems to be more functional.


Services
--------
Includes the following services:
- Gitea server
- Gitea server data (sidekick to the server)

What's not included:
- Load balancer
- MySQL server

Usage
-----
1. Create your database first (user: gitweb, db gitea - utf8_general_ci). We use MySQL here.
2. Update your load balancer to point 443 to 3000 (UI/https) and 2222 to 22 (SSH/tcp) of the Gitea service.
3. Go to the web UI and perform setup. Make sure the host name is the actual public domain name.

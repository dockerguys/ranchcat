Gitea
=====
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
- Federated identity

Usage
-----
1. Create your database first (user: gitweb, db gitea - utf8_general_ci). We use MySQL here.
2. Update your load balancer to point 443 to 3000 (UI/https) and 2222 to 22 (SSH/tcp) of the Gitea service.
3. If you didn't enable install lock, just go to the web UI and perform setup. Otherwise, once the container has finished initializing, restart it again 
to create the initial admin user.
4. For OAuth2 based users, you need to setup the password for the user, otherwise that user cannot logon.
5. You can create a special organization called `system`, who needs to create a repo called `theme`. This repo is symlinked to Gitea customization directories. Restart the Gitea server for setup to complete.

Gitea Customization Repo
------------------------
The customization repo lives in `system/theme`. Symlinks will be created as follows:

- /src/public --> /data/gitea/public
- /src/templates --> /data/gitea/templates
- /src/options --> /data/gitea/options

Symlinks will be rebuilt as needed every time you push to the repo.

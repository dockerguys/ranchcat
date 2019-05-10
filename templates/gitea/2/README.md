Gitea
=====
Lightweight GitHub clone. GitHub and GitLab hardware requirements are high (e.g. 4GB ram). Gogs and Gitea are clones that 
are very lightweight, but not suitable for large scale usage.

Gogs has a problem with MariaDB 10.1. Gitea seems to be more functional.


Services
--------
Includes the following services:
- Gitea server
- Redis caching (optional)

What's not included:
- Load balancer
- MySQL server
- Federated identity


Usage
-----
1. Create your database first (user: gitapp, db name: gitea - utf8_general_ci). We use MySQL here.
2. Update your load balancer to point 443 to 3000 (UI/https) and 2222 to 22 (SSH/tcp) of the Gitea service:
   - Service rule: `io.githost.role={name_of_this_stack}/server`
3. To persist your data, create a volume called `{name_of_this_stack}_data`. This volume will be mounted to `/data` of the git server container.
4. The setup process is triggered if `/data/setup_complete.flag` file cannot be found. Setup will try to initialize the database and create the default admin user. You can force skip the database initialization step by setting "Skip Database Setup" to `false`.
5. For OAuth2 based users, you need to setup the password for the user, otherwise that user cannot logon.
6. Enable redis below for faster performance. You can use `redis-cli monitor` in the redis container to verify that things are working correctly.
7. You can create a special organization called `system`, who needs to create a repo called `theme`. This repo is symlinked to Gitea customization directories. You need to restart the Gitea server container manually after creating the `system/theme` repo. Read more about the `system/theme` repo below.


Gitea Customization Repo
------------------------
The customization repo lives in `system/theme`. Symlinks will be created as follows:

- /src/public --> /data/gitea/public
- /src/templates --> /data/gitea/templates
- /src/options --> /data/gitea/options

Symlinks will be rebuilt as needed every time you push to the repo.

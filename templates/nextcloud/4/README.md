NextCloud
========
Not just a dropbox replacement! Your web apps, anywhere!

Services
--------
Includes the following services:
- NextCloud server (Nginx included)
- Redis (use `redis-cli monitor` to verify its working)

What's not included:
- Load balancer
- Database server (MySQL/Postgres)
- Nextant (for search)

Usage
-----
1. Create your database first (user: nextcloudapp, db nextcloud - utf8mb4_general_ci). We use MySQL here.
2. Update your load balancer to point 80/443 to 80 of the NextCloud service.
3. Go to the web UI and perform setup.

Migration Gotchas
-----------------
If you are migrating from a previous instance, there are a couple of important things to mind:
1. The `Install from Scratch` routine is triggered if `/var/www/html/version.php` wasn't found
2. The following folders are mounted volumes inside `/var/www/html`: `config`, `custom_apps`, `themes`, and `data`
3. If these mounted volumes contains data, they will be untouched by the installation procedure.
4. The `config` folder will contain the database server connection credentials. Therefore, you need to ensure that the database 
password is the same as the previous instance for things to work.

Upgrade Gotchas
---------------
Reinitializing an existing database will cause a mysterious "occ:maintenance" error, resulting in a bootloop. You need to 
set "DATABASE_ALREADY_EXISTS" to "true" in order to upgrade successfully.

Integration with Keycloak
-------------------------
A <a href="https://github.com/dockerguys/ranchcat/blob/master/templates/nextcloud/4/howto-integrate-nc-keycloak.md" target="_blank">detailed walkthrough</a> is available on integrating NextCloud to Keycloak for single sign-on.

NextCloud
========
Dropbox replacement and web apps anywhere!

Services
--------
Includes the following services:
- NextCloud server (Nginx included)

What's not included:
- Load balancer
- Database server (MySQL/Postgres)
- Redis
- Nextant (for search)

Usage
-----
1. Create your database first (user: nextcloudapp, db nextcloud - utf8_general_ci). We use MySQL here.
2. Update your load balancer to point 80/443 to 8080 (UI/https) of the NextCloud service.
3. Go to the web UI and perform setup.

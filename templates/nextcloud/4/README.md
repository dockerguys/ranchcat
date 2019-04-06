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
1. Create your database first (user: nextcloudapp, db nextcloud - utf8mb4_bin). We use MySQL here.
2. Update your load balancer to point 80/443 to 80 of the NextCloud service.
3. Go to the web UI and perform setup.

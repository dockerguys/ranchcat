Wordpress
========
WordPress is open source software you can use to create a beautiful website, blog, or app.

Services
--------
Includes the following services:
- Wordpress server (Nginx included)

What's not included:
- Load balancer
- Database server (MySQL/Postgres)

Usage
-----
1. Create your database first (user: wordpress, db wordpress - utf8). We use MySQL here.
2. Update your load balancer to point 80/443 to 80 of the NextCloud service.
3. Go to the web UI and perform setup.


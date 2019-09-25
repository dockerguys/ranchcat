Polr
=====
A modern, powerful, and robust URL shortener

Services
--------
Includes the following services:
- Polr server

What's not included:
- Load balancer
- MySQL server

Usage
-----
1. Create your database first (user: polrapp, db polr - utf8_general_ci). We use MySQL here.
2. Update your load balancer to point 443/80 to 80 of the Polr service.

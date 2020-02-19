OSTicket
========
A widely-used open source support ticket system. It seamlessly integrates inquiries created via email, phone and web-based forms into a simple easy-to-use multi-user web interface. Manage, organize and archive all your support requests and responses in one place while providing your customers with accountability and responsiveness they deserve.

Services
--------
Includes the following services:
- OSTicket server (Nginx included)

What's not included:
- Load balancer
- Database server (MySQL/Postgres)

Usage
-----
1. Create your database first (user: osticketapp, db osticket - utf8_general_ci). We use MySQL here.
2. Update your load balancer to point 80/443 to 80 of the OSTicket service.
3. Go to the web UI and perform setup.

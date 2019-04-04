Webserver
=========
Host static content with this stack.

Services
--------
Includes the following services:
- NginX web server

What's not included:
- Load balancer
- NextCloud

Usage
-----
1. Start this stack
2. Update your load balancer to point 80/443 to 80 of the nginx service.

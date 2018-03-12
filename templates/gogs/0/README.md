Gogs
=======

What is Gogs
------------
GitHub clone.

Services
--------
Includes the following services:
- Gogs server
- Gogs server data (sidekick to the server)

What's not included:
- Load balancer
- MySQL server

Usage
-----
1. Create your database first. MySQL recommended.
2. Update your load balancer to point to port 3000 (UI) and 22 (SSH) of the Gogs service.
3. Go to the web UI and perform setup.

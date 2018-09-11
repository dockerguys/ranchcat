Piwik
=====
A self-hosted solution to analyze your web traffic.

Services
--------
Includes the following services:
- Piwik server (Nginx embedded)

What's not included:
- Load balancer
- Database server (MySQL/Postgres)

Usage
-----
1. Create your database first (user: piwikapp, db piwik - utf8_general_ci). We use MySQL here.
2. Update your load balancer to point 443 to 80 (UI/http) of the Piwik service.
3. Go to the web UI and perform setup.

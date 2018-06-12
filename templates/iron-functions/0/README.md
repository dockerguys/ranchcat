IronFunctions
========
Serverless microservices web API platform for the agile developer. If you can docker it, we can run it!

Services
--------
Includes the following services:
- IronFunctions worker
- IronFunctions web portal
- Postgres database
- Redis database

What's not included:
- Load balancer

Usage
-----
1. Run this.
2. Update your load balancer to point 443 to 8080 (UI/https) of the functions-ui service.
3. Update your load balancer to point 443 to 4000 (UI/https) of the functions-worker service.
4. Go to the web UI and perform setup.

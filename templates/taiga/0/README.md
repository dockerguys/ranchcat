Taiga.IO
=========
Taiga is the project management platform for agile teams who want a beautiful tool to make work truly enjoyable.

Services
--------
Includes the following services:
- Frontend
- Backend
- Events server
- PostgresSQL
- Redis
- RabbitMQ
- Internal loadbalancer

Usage
-----
1. Update your external load balancer 443 to port 80 of the internal loadbalancer. 
2. Django backend is disabled by default. Enable it by editing the internal loadbalancer:
- `/admin` port 80 -> `taiga` port 80
3. Default credentials are `admin`:`1213123`.


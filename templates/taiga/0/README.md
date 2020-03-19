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
1. Update your external load balancer 443 to port 80 of the internal loadbalancer (`io.taiga.role=<stack_name>/lbs`). 
2. Django backend is disabled by default. Enable it by editing the internal loadbalancer:
- `/admin` port 80 -> `taiga` port 80
3. Default credentials are `admin`:`1213123`.

Caveats
-------
PostgresSQL server is using a local volume. This means data will be lost if the server migrates to another host. You should use host affinity to pin it to a static host.

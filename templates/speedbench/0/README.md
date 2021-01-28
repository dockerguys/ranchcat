Speedbench
==========
Measuring internet connection quality can be hard. Speedbench uses the NDT protocol to benchmark your internet connectivity.

This edition implements HTTP testing only. You need a loadbalancer to terminate SSL connection.

Services
--------
Includes the following services:
- Speedbench server

Usage
-----
1. Adjust load balancer HTTPS/443 to port 8080 HTTP of the containers.

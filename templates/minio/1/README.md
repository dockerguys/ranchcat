MinIO
=====
MinIO's high-performance, software-defined object storage suite enables customers to build cloud-native data infrastructure for machine learning, analytics and 
application data workloads.

Some possible configurations:

1. 1 instance 1 volume: great for trying things out
2. 1 instance multi volume: makes sense if you got multiple physical disks. Format them and mount to host on `<HostBasePath>{n}` first!
3. multi instance 1 volume each: distributed high-availability; whether a file is accessible when an instance goes down depends on its parity level.
4. multi instance multi volume: combines the best of (2) and (3)

You got a choice of using container volumes or actual directories on host, but the former doesn't make much sense for multi-volume.

Especially when dealing with physical disks, you must ensure that the container(s) run on the hosts with the actual disks. The scheduler will take care of this 
after you have labeled these hosts per "Host Affinity Label" option.

You can deploy this stack multiple times with the same storage configuration, but different "Tenant Name" value. This allows you to achieve multi-tenancy using 
the same hosts and disks.


Services
--------
Includes the following services:
- MinIO storage server(s)

What's not included:
- Load balancer


Usage
-----
1. Update your load balancer to point HTTPS/443 to port 9000 of the MinIO storage service.
2. Access by web GUI or API.
3. Create a custom user:

```
cat /root/.mc/config.json
mc admin user add local foo
mc admin group add local admins foo
mc admin policy set local readwrite group=admins
mc admin group info local admins
```
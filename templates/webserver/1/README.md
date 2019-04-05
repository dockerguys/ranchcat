Webserver
=========
Host static content with this stack.

Services
--------
Includes the following services:
- Nginx web server

What's not included:
- Load balancer

Usage
-----
1. Start this stack
2. Update your load balancer to point 80/443 to 80 of the nginx service.

Advanced Usage
--------------
You can mount the volumes used by this container on another stack (like NextCloud) that can modify the files. The webserver 
will then be able to serve the modified files.


Storage Options
===============
This stack will require 2 volumes to be provisioned:

- `{volume base name}_www` maps to `/usr/html` inside Nginx
- `{volume base name}_conf` maps to `/etc/nginx/conf.d` inside Nginx

If you do not specify "Volume Base Name" below:

- the volumes will be created dynamically on the host machine
- the value of `{volume base name}` will be generated based on your stack name
- the volumes are host-scoped, meaning only containers on the same host machine can access them
- volumes will be removed when you delete this stack

To make your volumes accessible across multiple host machines and persist beyond this stack's lifetime, you can either manually 
create the volumes (recommended) or let this stack create them.

Manually Create Volumes
-----------------------
To manually create the volumes:

- Make sure the infrastructure stack `nfs` is already running
- Navigate to `Infrastructure > Storage > Add Volume`
- Create the volume(s) required above. `{volume base name}` can be anything you want.
- Add the following driver options for each volume created:
  - host: name of the nfs server
  - exportBase: /storage/nfsvol
  - onRemove: retain

Then, create this stack with the following options:
- Volume Base Name: must be same as `{volume base name}`
- Volume Exists: true
- Volume Storage Driver: rancher-nfs

**Do not modify the other NFS related options.**

You can also let this stack create the volumes automatically:

Automatically Create Volumes
----------------------------
You need to fill in the following options:
- Volume Base Name: this sets `{volume base name}`
- Volume Exists: false
- Volume Storage Driver: rancher-nfs
- NFS Driver Host: name of nfs server
- NFS Driver Volume Path: /storage/nfsvol
- Retain NFS Volume: true (or false if you want to automatically remove the volumes when this stack is deleted)

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
2. Update your load balancer to point 80/443 to 80 of `io.webserver.role={stack_name}/server`.

Advanced Usage
--------------
This image offers a variety of services on different ports. You can create multiple rules on your load balancer to forward to these ports:

1. **Port 8008**: HTTP to HTTPS redirection service. Anyone who visits HTTP/80 gets redirected to HTTPS/443 version of the same URL.

2. **Port 8042**: Basic web API services. Out-of-box includes `/generate_204` and `/ip`.

3. **Port 591**: CDN hosting service. CORs is allowed and cache max-age is set to a long time (so client browsers will cache the content).

4. **Port 8080**: Subsite service. Visitors are served files from `/usr/html/sites/www/{domain}/html`, so you can show different content based on the domain accessed. Also designed for HTML5 push-state, meaning that if you visit `www.mydomain.com/foobar`, the server will search inside `/usr/html/sites/www/www.mydomain.com/html` for `/foobar/index.html`, and if not found, `/index.html`. But if the URL has a file extension like `www.mydomain.com/foobar.js`, it'll just search for `/foobar.js` and 404 when not found.

5. **Port 8811**: Root domain redirection service. A second level domain (e.g. example.com) will be redirected to its `www` name (i.e. www.example.com).

Modifying Content
-----------------
This image serves static web content, meaning that it serves whatever is on its disk as-is without modification. You can mount the volumes used by this container on another stack (like NextCloud) that can modify the files. The webserver will then be able to serve the dynamically modified files immediately.


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

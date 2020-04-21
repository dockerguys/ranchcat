CoreDNS
=======
CoreDNS is a DNS server that chains plugins.


Services
--------
Includes the following services:
- CoreDNS server


Usage
-----
1. Unless you change the default `DNS Port`, make sure port 53/udp is not used on the host deployed. We cannot use HAProxy here because it does not support UDP. Only 1 instance of CoreDNS container can run per host.
2. Domains set by `Private Domains` will never be forwarded to the upstream server. Delimit multiple domains by space.
3. Optionally, set `Internal Upstream DNS` as the upstream DNS server that resolves internal domains. The domain set by `Internal Upstream Domain` will be resolved 
by this DNS server only.
4. Set `Brand Name` and `Brand Author` to customize the answer returned by a special domain name in the CH class.

```
dig @<dns_server_ip> CH TXT version.bind
dig @<dns_server_ip> CH TXT version.server
dig @<dns_server_ip> CH TXT authors.bind
dig @<dns_server_ip> CH TXT hostname.bind
dig @<dns_server_ip> CH TXT id.server
```

5. All requests hosts defined by Rancher load balancer are automatically polled every 30 seconds and served by this DNS server. Hosts defined by Rancher load balancer are served statically, i.e. it is never resolved by internal upstream DNS nor upstream DNS.
6. If the loadbalancer servers `.internal|.lan|.local` domains, the host running it must have a label `io.lan.ip=<ip>`. All other domain extensions will use the host's agent ip.


Caveats
-------
Ubuntu hosts listens on `172.0.0.53:53` by default with dnsmasq, which may cause deployment to fail. You need to modify 
`system-resolved` to use the DNS servers specified by DHCP directly:

```
sed -i 's/#DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf
ln -sfr /run/systemd/resolve/resolv.conf /etc/resolv.conf
systemctl restart systemd-resolved
```

You can add the hosts running CoreDNS to the "domain overrides" section of an upstream unbound server, but "forwarding mode" needs to be enabled on unbound for things to work.

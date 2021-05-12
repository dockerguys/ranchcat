NATS
=====
NATS is a connective technology that powers modern distributed systems.

Some possible configurations:

1. Standalone: 1 channel message server only. Great for trying things out.
2. Cluster: deploys 2 or more channel message servers.
3. Hyper-Cluster: same as cluster but with connection to other clusters.

Services
--------
Includes the following services:
- NATS server
- Account server

What's not included:
- Load balancer

Usage
-----
1. Update your load balancer to point HTTPS/443 to port 9090 of the accounting server.
2. Access by using the `nsc` app.

Init Region One
---------------
`REGION1` is the default namespace that is required for the setup to function. The namespace token can be specified 
either in the `[ncred]/REGION1.jwt` (640,root:cmsgs) file or via the option `Region One Token`. The former is 
recommended in production.

In order for ACS to manage accounts, it needs to have credentials to the `SYS` operator account of `REGION1`. These 
files are expected at `[ncred]/SYS.jwt` (640,cmaccount:root) and `[ncred]/creds/sys.creds` (600,cmaccount:root).

Recommended permissions for `[ncred]` and `[ncred]/creds` is `750,cmaccount:root`.

It is possible to automate `REGION1` initialization by launching a stack with the following configuration:

1. Provision the `[ncred]` and `[nsc]` shared volumes
2. Set `Enable ACS` to `primary` and `Message Channel Server` to `none`
3. Specify `Primary ACS FQDN` and `ACS Managed Nodes`
4. Make sure `R/O Ncred Volume` is `false`.

This will populate the `[ncred]` volume with the required files. You can then proceed to update the stack with the 
actual configuration, setting `R/O Ncred Volume` to `true`.

TLS Encryption
--------------
ACS does not support TLS/HTTPS. You should deploy a SSL-terminating loadbalancer in front.

To enable TLS for message channel servers, you need to provision the `[certs]` volume beforehand.

Traffic between client and message channel server require the following files:
- `[certs]/cmserver/cert.pem`
- `[certs]/cmserver/privkey.pem`
- `[certs]/cmserver/ca.pem` (only if enabling custom CA)

If not using a custom CA, `cert.pem` must be signed by a public CA.

Intra-cluster can also be TLS protected. Inter-hypercluster traffic must be TLS protected.

Certificates for intra-cluster traffic are expected at:
- `[certs]/cmcluster/cert.pem`
- `[certs]/cmcluster/privkey.pem`
- `[certs]/cmcluster/ca.pem`

Certificates used to identify and authenticate this cluster in the hypercluster 
are expected at:
- `[certs]/cmgateway/cert.pem`
- `[certs]/cmgateway/privkey.pem`
- `[certs]/cmgateway/ca.pem`

Certificates for each peer in the hypercluster is expected at:
- `[certs]/cmgwpeers/<peer_name>/cert.pem`
- `[certs]/cmgwpeers/<peer_name>/ca.pem`

Intra-cluster and inter-hypercluster TLS certs must be of the following specs:
- curve preference: X25519
- cipher suites: TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384, 
  TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305

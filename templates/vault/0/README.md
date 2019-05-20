Vault
=====
Security solution for your containers.


Services
--------
Includes the following services:
- Vault

What's not included:
- Load balancer

Usage
-----
1. Update your load balancer to point 80 to 8200 (UI/http).
2. Visit your security domain at /ui. You probably want to start by [creating a CA](https://learn.hashicorp.com/vault/secrets-management/sm-pki-engine#web-ui-5).
3. You may want to load balance 443 (HTTPS) to Vault too, but don't remove port 80. Things like CRL cannot be done over HTTPS.

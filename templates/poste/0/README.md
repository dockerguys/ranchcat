Poste.IO
=========
A email server designed for optimal resource usage and advanced features.

Services
--------
Includes the following services:
- Mail server
- Mail server data (sidekick to the server)

What's not included:
- Load balancer

Usage
-----
1. Update your load balancer to point to **mailserver**: 

|----------|----------|------|-------------|
| L/B Port | Protocol | Port | Description |
|----------|----------|------|-------------|
| 25       | TCP      | 25   | SMTP        |
| 443      | HTTPS    | 80   | Web admin   |
| 110      | POP3     | 110  | POP3        |
| 143      | TLS      | 143  | IMAP        |
| 587      | TCP      | 143  | MSA         |
|----------|----------|------|-------------|

2. Go to the web UI and perform setup.
25	SMTP - mostly processing incoming mails
80	HTTP - redirect to https (see options) and authentication for Let's encrypt service
110	POP3 - standard protocol for accessing mailbox, STARTTLS is required before client auth
143	IMAP - standard protocol for accessing mailbox, STARTTLS is required before client auth
443	HTTPS - access to administration or webmail client
587	MSA - SMTP port used primarily for email clients after STARTTLS and auth
993	IMAPS - alternative port for IMAP encrypted since connection
995	POP3S - encrypted POP3 since connections

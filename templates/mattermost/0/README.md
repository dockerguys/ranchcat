Mattermost
==========
Mattermost is an open source, self-hosted Slack-alternative.

Services
--------
Includes the following services:
- Mattermost server
- Mattermost server data (sidekick to the server)

What's not included:
- Load balancer
- MySQL server

Usage
-----
1. Create your database first. MySQL recommended.
2. Update your load balancer to point 80/443 to port 80 of the Mattermost service.
3. Go to the web UI and perform setup.

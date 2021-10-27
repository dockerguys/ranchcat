Gitea
=====
Lightweight GitHub clone. GitHub and GitLab hardware requirements are high (e.g. 4GB ram). Gitea is a lightweight clone that runs as a single instance only.


Services
--------
Includes the following services:
- Gitea server
- Redis caching (optional)

What's not included:
- Load balancer (required)
- MySQL server
- ElasticSearch
- Federated identity


Usage
-----
1. Create your database first (user: gitapp, db name: gitea - utf8_general_ci). We use MySQL here.
2. Update your load balancer to point 443 to 3000 (UI/https) of the Gitea service:
   - Service rule: `io.githost.role={name_of_this_stack}/server`
3. To persist your data, create a volume called `{name_of_this_stack}_data`. This volume will be mounted to `/data` of the git server container.
4. The setup process is triggered if `/data/gitea/setup_complete.flag` file cannot be found. Setup will try to initialize the database and create the default admin user. You can force skip the database initialization step by setting "Skip Database Setup" to `false`.
5. For OAuth2 based users, you need to setup the password for the user, otherwise that user cannot logon.
6. Enable redis below for faster performance. You can use `redis-cli monitor` in the redis container to verify that things are working correctly.


Gitea Customization
-------------------
Customize your Gitea instance with `/data/branding/{public|templates|options}`. Make sure there is global read access.

You can add custom emojis by creating tightly cropped pngs in `public/emoji/img/{reaction|emoji}_{name}.png`. Then add `{name}` to "Reaction Emojis" or "Custom Emojis" fields.


Keycloak Integration
--------------------
If Keycloak is hosted in the same system, you may need to make Gitea resolve your OpenID authentication domain using the load balancers internal IP.

To do that, set "OpenID Domain Override" to your authentication domain (e.g. auth.example.com). Set "OpenID IP Override" to the internal IPs of your load balancers (e.g. 172.22.30.40 172.22.30.40).

1. Go to "Admin Panel > Authentications > Add new source". Authentication name = [my-keycloak-gitea]; OAuth2 provider = openid connect; client id = keycloak-gitea; client secret = [copy from keycloak]; autodiscovery url = https://[keycloak.mydomain]/auth/realms/[my-realm]/.well-known/openid-configuration
2. Don't enable yet.
3. Go to Keycloak:
- (select or create realm 'my-realm') and enter 'my-realm'
- clients > create > client id = keycloak-gitea; protocol = openid-connect > save
clients > keycloak-gitea > enabled; access type = confidential; standard flow; direct access grant; valid redirect urls = https://<gitea.mydomain>/*; web origins=+;
- credentials > authenticator = client id & secret; (copy secret to gitea 'client secret')
- mappers > (remove from list or add using 'add builtin' so that list only contains) family name, locale, given name, email, username, email verified
- scope > full scope allowed
4. enable in Gitea

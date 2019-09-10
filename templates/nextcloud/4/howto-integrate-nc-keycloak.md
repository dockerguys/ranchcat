Keycloak Integration with NextCloud
===================================
This is a walkthrough on how to make NextCloud authenticate access using Keycloak. NextCloud users are provisioned automatically 
after authenticated using Keycloak.

This walkthrough is tested on:
- Keycloak 7.0.0
- Nextcloud 16.0.4
- (Nextcloud module) SSO & SAML authentication 2.4.0

All systems are running in Docker. Container images are based on Alpine Linux 3.10.


Requisites
----------
For this section:
- `<host_name>` means the host/domain name of your NextCloud instance, for example `files.mydomain.com`
- `<signin_host>` means the host/domain name of your Keycloak instance, for example `signin.mydomain.com`
- `<your_realm>` means a realm created in Keycloak, for example `mydomain.com`

You need to first create a certificate for NextCloud SAML:

```bash
# use . for all questions (means empty value), 
# except for Common Name, which should be <host_name>
openssl req  -nodes -new -x509  -keyout private.key -out public.crt
cat public.crt
cat private.key
```

Then get the RSA certificate for your realm in Keycloak:

`(select your realm from dropdown)`

`realm settings > keys > active > rs256 > certificate`

You need to add `-----BEGIN CERTIFICATE-----` to the top on a newline, and 
`-----END CERTIFICATE-----` to the bottom, also on a separate line.


Download SSO Module
-------------------
Now login to NextCloud as the default administrator.

NextCloud 16 does not come with SSO installed by default. You need to download and enable it first:

`(navbar avatar icon) > apps > integration > sso & saml authentication > (download and enable)`


Configure SSO
-------------
Navigate to SSO settings:

`(navbar avatar icon) > settings > sso & saml authentication`

**IMPORTANT**: don't close your browser, or you can get locked out! If all fails, there is direct login:

`http://<host_name>/login?direct=1`

Now for a working configuration:

```
Global settings:
[ ] Only allow authentication if an account exists on some other backend. (e.g. LDAP)
[x] Use SAML auth for the Nextcloud desktop clients (requires user re-authentication)
[ ] Allow the use of multiple user back-ends (e.g. LDAP)

(+ Add identity provider)

General 
() username
(display:) My Signin

Service Provider Data
[Unspecified]
(paste public.crt data, include -----BEGIN CERTIFICATE----- etc...)
(paste private.key data, include -----BEGIN PRIVATE KEY----- etc...)

Identity Provider Data
https://<signin_host>/auth/realms/<your_realm>
https://<signin_host>/auth/realms/<your_realm>/protocol/saml
https://<signin_host>/auth/realms/<your_realm>/protocol/saml
(paste Keycloak RSA certificate)

Attribute mapping
(Attribute to map the display name to) firstName
(Attribute to map email to) email
(Attribute to map quota to) nc_quota
(Attribute to map user groups to)
(Attribute to map user home to)

Security settings
 Signatures and encryption offered
 [ ] Indicate that the nameID...
 [x] Indicates whether the <samlp:AuthnRequest> message... 
 [x] Indicates whether the <samlpLlogoutRequest> message...
 [x] Indicates whether the <samlpLlogoutResponse> message...
 [ ] Whether the metadata should be signed

 Signatures and encryption required
 [x] Indicates that a requirement for the <samlp:Response>...
 [x] Indicates that a requirement for the <samlp:Assertion> elements received by this SP to be signed...
 [ ] Indicates that a requirement for the <samlp:Assertion> elements received by this SP to be encrypted.
 [ ] Indicates that a requirement for the NameID element...
 [ ] Indicates that a requirement for the NameID received...
 [ ] Indicates if the SP will validate all received XML.

 General
 [ ] ADFS URL-Encodes SAML data as lowercase...
```

Click on `Download metadata XML` button to export the configuration.

Keycloak Configuration
----------------------
Very importantly, you need to first set your realm `role_list` for single role attribute!!!

```
client scopes > role_list > mappers > role_list > [check] Single Role Attribute
```

Then create your SAML client under `clients > create > import file`. 

You need to make some modifications. Full working configuration below:

```
client id: http://<host_name>/apps/user_saml/saml/metadata
name: NextCloud
description: Nextcloud service
client protocol: saml
enabled: (check)
consent required: (uncheck)
login theme: (your preferred theme)
client protocol: saml
include authnstatement: (check)
include onetimeuse condition: (uncheck)
sign documents: (check)
optimize redirect...: (uncheck)
sign assertions: (check)
signature algorithm: rsa_sha256
saml signature key name: KEY_ID
canonicalization method: exclusive
encrypt assertions: (uncheck)
client signature required: (check)
force post binding: (check)
front channel logout: (check)
force name id format: (uncheck)
name id format: username
root url: 
valid redirect uris: https://<signin_host>/*
  http://<signin_host>/*
  https://<host_name>/*
base url:
master saml processing url: https://<signin_host>/auth/realms/<your_realm>
idp initiated sso url name:
idp initiated sso relay state:

fine grain saml endpoint configuration
  assertion consumer service post binding url: https://<host_name>/apps/user_saml/saml/acs
  assertion consumer service redirect binding url:
  logout service post binding url: https://<host_name>/apps/user_saml/saml/sls
  logout service redirect binding url: http://<host_name>/apps/user_saml/saml/sls
```

Click `Save` to commit your changes.

You also need to map keycloak properties to SAML. Go to `Mappers` tab and `create` each of the following:

```
name: firstName
mapper type: user property
property: firstName
friendly name:
saml attribute name: firstName
saml attribute nameFormat: basic
```

```
name: email
mapper type: user property
property: email
friendly name:
saml attribute name: email
saml attribute nameFormat: basic
```

```
name: username
mapper type: user property
property: username
friendly name:
saml attribute name: username
saml attribute nameFormat: basic
```

```
name: nc_quota
mapper type: user attribute
property: nc_quota
friendly name:
saml attribute name: nc_quota
saml attribute nameFormat: basic
aggregate attribute values: off
```


Set Quota for Users
-------------------
You should add the `nc_quota` key to the `attributes` tab of all users. A better way would be to edit the `attributes` tab 
of **Groups**, and make sure all users are members of at least 1 group:

```
key: nc_quota
value: 1 GB
(click on add)
```

Save your changes by clicking `Save`.


Testing It Out
--------------
Open a private tab on your browser and visit `http://<host_name>`. You should get redirected to Keycloak.

Sign in and you should get automatic redirection back to NextCloud as the Keycloak user.

Check that your username, display name, email and quota works. Logout should work too.




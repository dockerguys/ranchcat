MariaDB
=======
MariaDB is a drop-in replacement for MySQL, the world's most popular open source database. With its proven performance, reliability and ease-of-use, MySQL has become the leading database choice for web-based applications, covering the entire range from personal projects and websites, via e-commerce and information services, all the way to high profile web properties including Facebook, Twitter, YouTube, Yahoo! and many more.

For more information and related downloads for MySQL Server and other MariaDB products, please visit [www.mariadb.org](https://mariadb.org).


Services
--------
Includes the following services:
- MySQL Server
- Web administration

You can configure your load balancer like this to get the admin portal working:
- admin.(your_domain).com -> 443 -> /dbedit -> io.mysqldb.role=mysql/webadmin -> 80

Usage
-----
The root password will be automatically generated and displayed in the startup log if not set. You are recommended to set the root password in this form. 

Caveats
-------
MariaDB 10.3 uses `falloc`, which proves problematic when used with Alpine OS and/or NFS shares. You need to create local volumes for this image.



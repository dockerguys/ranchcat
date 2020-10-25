MariaDB
=======
MariaDB is a drop-in replacement for MySQL, the world's most popular open source database. With its proven performance, reliability and ease-of-use, MySQL has become the leading database choice for web-based applications, covering the entire range from personal projects and websites, via e-commerce and information services, all the way to high profile web properties including Facebook, Twitter, YouTube, Yahoo! and many more.

For more information and related downloads for MySQL Server and other MariaDB products, please visit [www.mariadb.org](https://mariadb.org).

The root password will be automatically generated and displayed in the startup log if not set. You are recommended to set the root password in this form. 


Services
--------
Includes the following services:
- MySQL Server
- Web administration

You can configure your load balancer like this to get the admin portal working:
- admin.(your_domain).com -> 443 -> /dbedit -> io.mysqldb.role=mysql/webadmin -> 80


Notes
-----
The database can be stored in either a host-mapped path or **local** volume (i.e. volume storage driver options are ignored for the database volume).

This image takes periodic backups to the backup volume. A dedicated local backup account is automatically created on first run. It uses a custom CLI to take periodic backup of the database.

---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/ubuntu-apache/
redirect_from:
  - /theme-setup/
last_modified_at: 2024-09-16
last_modified_by: Mohammad_Asif
toc: true
title: Installing Faveo Helpdesk on Ubuntu With Apache Webserver
---


<img alt="Ubuntu" src="https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Logo-ubuntu_cof-orange-hex.svg/120px-Logo-ubuntu_cof-orange-hex.svg.png" width="120" height="120" />

Faveo can run on [Ubuntu 20.04 (Focal Fosa), Ubuntu 22.04 (Jammy Jellyfish), Ubuntu 24.04 (Noble Numbat)](http://releases.ubuntu.com/22.04/).

This document is meant for Faveo Freelancer, Paid and Enterprise Versions.

- [<strong>Installation steps :</strong>](#installation-steps-)
    - [<strong>1. Apache Installation</strong>](#1-apache-installation)
    - [<strong>2. Install some Utility packages</strong>](#2-install-some-utility-packages)
    - [<strong>3. Upload Faveo</strong>](#3-upload-faveo)
    - [<strong>4. Setup the database</strong>](#4-setup-the-database)
    - [<strong>5. Configure Apache webserver</strong>](#5-configure-apache-webserver)
    - [<strong>6. Configure cron job</strong>](#6-configure-cron-job)
    - [<strong>7. Redis Installation</strong>](#7-redis-installation)
    - [<strong>8. SSL Installation</strong>](#8-ssl-installation)
    - [<strong>9. Install Faveo</strong>](#9-install-faveo)
    - [<strong>10. Faveo Backup</strong>](#10-faveo-backup)
    - [<strong>11. Webserver Hardening</strong>](#11-webserver-hardening)
    - [<strong>12. Final step</strong>](#12-final-step)

> **NOTE** :
> Ubuntu 22.04 is the recommended version, Ubuntu 20.04 does not support oAuth integration.



<a id="installation-steps-" name="installation-steps-"></a>

# <strong>Installation steps :</strong>

Faveo depends on the following:

-   **Apache** (with mod_rewrite enabled) 
-   **PHP 8.2+** with the following extensions: curl, dom, gd, json, mbstring, openssl, pdo_mysql, tokenizer, zip
-   **MySQL 8.0+** or **MariaDB 10.6+**
-   **SSL** ,Trusted CA Signed or Self-Signed SSL


<a id="1-apache-installation" name="1-apache-installation"></a>

### <strong>1. Apache Installation</strong>

Run the following commands as sudoers or Login as root user by typing the command below

```sh
sudo su
```

<b>1.a. Update your package list</b>

```sh
apt update && apt upgrade -y
```

<b>1.b. Apache</b>
Apache should come pre-installed with your server. If it's not, install it with:

```sh
apt-get install -y software-properties-common
sudo add-apt-repository ppa:ondrej/apache2
sudo apt update
apt install apache2
systemctl start apache2
systemctl enable apache2
```
<a id="2-install-some-utility-packages" name="2-install-some-utility-packages"></a>

### <strong>2. Install some Utility packages</strong>

```sh
apt install -y git wget curl unzip nano zip
```

<b>2.a. PHP 8.2+</b>

First add this PPA repository:

```sh
add-apt-repository ppa:ondrej/php
```

Then install php 8.2 with these extensions:

```sh
apt update
apt install -y php8.2 libapache2-mod-php8.2 php8.2-mysql \
    php8.2-cli php8.2-common php8.2-fpm php8.2-soap php8.2-gd \
    php8.2-opcache  php8.2-mbstring php8.2-zip \
    php8.2-bcmath php8.2-intl php8.2-xml php8.2-curl  \
    php8.2-imap php8.2-ldap php8.2-gmp php8.2-redis php8.2-memcached
```
After installing PHP 8.2, run the commands below to open PHP default config file.

```sh
nano /etc/php/8.2/fpm/php.ini
```

Then make the changes on the following lines below in the file and save. The value below are great settings to apply in your environment.

```
file_uploads = On
allow_url_fopen = On
short_open_tag = On
memory_limit = 256M
cgi.fix_pathinfo = 0
upload_max_filesize = 100M
post_max_size = 100M
max_execution_time = 360
```

<b>2.b. Setting Up ionCube</b>
```sh
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz 
tar xvfz ioncube_loaders_lin_x86-64.tar.gz 
```
Make the note of path and directory from the below first command.

Copy ion cube loader to Directory. Replace your *yourpath* below with actual path that was shown with the first command below.

```sh
php -i | grep extension_dir
cp ioncube/ioncube_loader_lin_8.2.so /usr/lib/php/'replaceyourpath'
sed -i '2 a zend_extension = "/usr/lib/php/'replaceyourpath'/ioncube_loader_lin_8.2.so"' /etc/php/8.2/apache2/php.ini
sed -i '2 a zend_extension = "/usr/lib/php/'replaceyourpath'/ioncube_loader_lin_8.2.so"' /etc/php/8.2/cli/php.ini
sed -i '2 a zend_extension = "/usr/lib/php/'replaceyourpath'/ioncube_loader_lin_8.2.so"' /etc/php/8.2/fpm/php.ini

systemctl restart apache2 
```

<b>2.c.  Install MySQL/MariaDB</b>

The official Faveo installation uses Mysql/MariaDB as the database system and **this is the only official system we support**. While Laravel technically supports PostgreSQL and SQLite, we can't guarantee that it will work fine with Faveo as we've never tested it. Feel free to read [Laravel's documentation](https://laravel.com/docs/database#configuration) on that topic if you feel adventurous.

You can install either MySQL or MariaDB. We have given options for both MySQL and MariaDB below.

<b>2.c.1. MySQL 8.0</b>

Install Mysql 8.0. Note that this only installs the package, but does not setup Mysql. This is done later in the instructions:

 <b> For Ubuntu 20.04, 22.04, 24.04 </b>

```sh 
sudo apt update
sudo apt install mysql-server 
sudo systemctl start mysql
sudo systemctl enable mysql
```


Secure your MySql installation by executing the below command. Set Password for mysql root user, remove anonymous users, disallow remote root login, remove the test databases and finally reload the privilege tables.
```sh
mysql_secure_installation 
```

<b>2.c.2.MariaDB 10.6</b>

Install MariaDB 10.6. Note that this only installs the package, but does not setup Mysql. This is done later in the instructions:

 <b> For Ubuntu 20.04</b>

```sh 
curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
sudo bash mariadb_repo_setup --mariadb-server-version=10.6

sudo apt update
sudo apt install mariadb-server mariadb-client
sudo systemctl start mariadb
sudo systemctl enable mariadb
```

<b> For Ubuntu 22.04</b>

```sh 
sudo apt update
sudo apt install mariadb-server mariadb-client -y
sudo systemctl start mariadb
sudo systemctl enable mariadb
```
> NOTE: Ubuntu 24.04 doesn't officially support MariaDb 10.6, so only MySQL 8.0 can be installed for Ubuntu 22.04

Secure your MySql installation by executing the below command. Set Password for mysql root user, remove anonymous users, disallow remote root login, remove the test databases and finally reload the privilege tables.
```sh
mysql_secure_installation 
```

<b>2.d. Install wkhtmltopdf</b>


Wkhtmltopdf is an open source simple and much effective command-line shell utility that enables user to convert any given HTML (Web Page) to PDF document or an image (jpg, png, etc). 

It uses WebKit rendering layout engine to convert HTML pages to PDF document without losing the quality of the pages. Its is really very useful and trustworthy solution for creating and storing snapshots of web pages in real-time.

**For Ubuntu 20.04**

```sh
apt-get -y install wkhtmltopdf
```
**For Ubuntu 22.04**

```
apt install libfontenc1 xfonts-75dpi xfonts-base xfonts-encodings xfonts-utils
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
dpkg -i wkhtmltox_0.12.6.1-3.jammy_amd64.deb
```

<b>2.e. Install Meilisearch</b>

MeiliSearch is an open-source search engine developed in Rust that delivers flexible search and indexing capabilities. It adeptly handles typos, supports full-text search, synonyms, and comes packed with various features, making it an ideal choice for elevating search functionalities in Faveo.

[Meilisearch installation documentation](/docs/installation/providers/enterprise/meilisearch)


<a id="3-upload-faveo" name="3-upload-faveo"></a>

### <strong>3. Upload Faveo</strong>


Please download Faveo Helpdesk from [https://billing.faveohelpdesk.com](https://billing.faveohelpdesk.com) and upload it to below directory

```sh
mkdir -p /var/www/faveo/
cd /var/www/faveo/
```
<b>Extracting the Faveo-Codebase zip file</b>

```sh
unzip "Filename.zip" -d /var/www/faveo
```

 Give proper permissions to the project directory by running:

```sh
chown -R www-data:www-data /var/www/faveo
cd /var/www/faveo/
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;
```
<a id="4-setup-the-database" name="4-setup-the-database"></a>

### <strong>4. Setup the database</strong>

Log in with the root account to configure the database.

```sh
mysql -u root -p
```

Create a database called 'faveo'.

```sql
CREATE DATABASE faveo;
```

Create a user called 'faveo' and its password 'strongpassword'.

```sql
CREATE USER 'faveo'@'localhost' IDENTIFIED BY 'strongpassword';
```

We have to authorize the new user on the faveo db so that he is allowed to change the database.

```sql
GRANT ALL ON faveo.* TO 'faveo'@'localhost';
```

And finally we apply the changes and exit the database.

```sql
FLUSH PRIVILEGES;
exit
```

> **NOTE** :
> Please refrain from making direct MySQL/MariaDB modifications. Contact our support team for assistance.

<a id="5-configure-apache-webserver" name="5-configure-apache-webserver"></a>

### <strong>5. Configure Apache webserver</strong>

 **5.a.** <b>Configure a new faveo site in apache by doing:</b>

Pick a editor of your choice copy the following and replace '--DOMAINNAME--' with the Domainname mapped to your Server's IP or you can just comment the 'ServerName' directive if Faveo is the only website served by your server.
```sh
nano /etc/apache2/sites-available/faveo.conf
```

```apache
<VirtualHost *:80>
    ServerName --DOMAINNAME-- 
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/faveo/public

    <Directory /var/www/faveo/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/faveo-error.log
    CustomLog ${APACHE_LOG_DIR}/faveo-access.log combined
# Uncomment the below lines and replace the Server-IP and Domainame to configure IP to Domainname rewrite rule
#    RewriteEngine on
#    RewriteCond %{HTTP_HOST} ^--Server-IP--
#    RewriteRule (.*) http://--Domainname--
</VirtualHost>
```

**5.b.** <b>Enable the rewrite module and disable default site of the Apache webserver:</b>

```sh
a2enmod rewrite
a2dissite 000-default.conf
a2ensite faveo.conf
# Enable php8.2 fpm, and restart apache
a2enmod proxy_fcgi setenvif
a2enconf php8.2-fpm
```
 **5.c.** <b>Apply the new `.conf` file and restart Apache and PHP-FPM. You can do that by running:</b>

```sh
service php8.2-fpm restart
service apache2 restart
```

<a id="6-configure-cron-job" name="6-configure-cron-job"></a>

### <strong>6. Configure cron job</strong>

Faveo requires some background processes to continuously run. 
Basically those crons are needed to receive emails
To do this, setup a cron that runs every minute that triggers the following command `php artisan schedule:run`.Verify your php ececutable location and replace it accordingly in the below command.

[comment]: <Create a new `/etc/cron.d/faveo` file with:>

```sh
(sudo -u www-data crontab -l 2>/dev/null; echo "* * * * * /usr/bin/php /var/www/faveo/artisan schedule:run 2>&1") | sudo -u www-data crontab -
```

<a id="7-redis-installation" name="7-redis-installation"></a>

### <strong>7. Redis Installation</strong>

Redis is an open-source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.

This will improve system performance and is highly recommended.

[Redis installation documentation](/docs/installation/providers/enterprise/ubuntu-redis)

<a id="8-ssl-installation" name="8-ssl-installation"></a>

### <strong>8. SSL Installation</strong>

Secure Sockets Layer (SSL) is a standard security technology for establishing an encrypted link between a server and a client. Let's Encrypt is a free, automated, and open certificate authority.

Faveo Requires HTTPS so the SSL is a must to work with the latest versions of faveo, so for the internal network and if there is no domain for free you can use the Self-Signed-SSL.

[Let’s Encrypt SSL installation documentation](/docs/installation/providers/enterprise/ubuntu-apache-ssl)

[Paid SSL Certificate Documentation](/docs/installation/providers/enterprise/paid-ssl-ubuntu/ )

[Self Signed SSL Certificate Documentation](/docs/installation/providers/enterprise/self-signed-ssl-ubuntu/)

<a id="9-install-faveo" name="9-install-faveo"></a>

### <strong>9. Install Faveo</strong>

At this point if the domainname is propagated properly with your server's IP you can open Faveo in browser just by entering your domainname.
You can also check the Propagation update by Visiting this site www.whatsmydns.net.

Now you can install Faveo via [GUI](/docs/installation/installer/gui) Wizard or [CLI](/docs/installation/installer/cli)


<a id="10-faveo-backup" name="10-faveo-backup"></a>

### <strong>10. Faveo Backup</strong>


At this stage, Faveo has been installed, it is time to setup the backup for Faveo File System and Database. [Follow this article](/docs/helper/backup) to setup Faveo backup.

<a id="11-webserver-hardening" name="11-webserver-hardening"></a>

### <strong>11. Webserver Hardening</strong>

Once the installation is complete, it is recommended to harden the webserver to enhance security. Follow our guide to apply best practices such as disabling unnecessary modules, enforcing security headers, and restricting access permissions.

[Apache Hardening](/docs/helpers/server-hardening/apache-hardening)


<a id="12-final-step" name="12-final-step"></a>

### <strong>12. Final step</strong>

The final step is to have fun with your newly created instance, which should be up and running to `http://localhost` or the domain you have configured Faveo with.

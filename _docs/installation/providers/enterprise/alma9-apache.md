---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/alma9-apache/
redirect_from:
  - /theme-setup/
last_modified_at: 2024-11-22
last_modified_by: Mohammad_Asif
toc: true
title: Installing Faveo Helpdesk on Alma Linux with Apache Webserver
---

<img alt="Alma Linux Logo" src="https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/AlmaLinux_Icon_Logo.svg/1024px-AlmaLinux_Icon_Logo.svg.png?20211201021832" width="150"  />

Faveo can run on [Alma Linux](https://almalinux.org/).

This document is meant for Faveo Freelancer, Paid and Enterprise Versions.

- [<strong>Installation steps :</strong>](#installation-steps-)
    - [<strong> 1. Update your Packages and install some utility tools</strong>](#-1-update-your-packages-and-install-some-utility-tools)
    - [<strong>2. Upload Faveo</strong>](#2-upload-faveo)
    - [<strong>3. Setup the database</strong>](#3-setup-the-database)
    - [<strong>4. Configure Apache webserver</strong>](#4-configure-apache-webserver)
    - [<strong>5. Configure cron job</strong>](#5-configure-cron-job)
    - [<strong>6. Redis Installation</strong>](#6-redis-installation)
    - [<strong>7. SSL Installation</strong>](#7-ssl-installation)
    - [<strong>8. Install Faveo</strong>](8-install-faveo)
    - [<strong>9. Faveo Backup</strong>](#9-faveo-backup)
    - [<strong>10. Final step</strong>](#10-final-step)

<a id="installation-steps-" name="installation-steps-"></a>

# <strong>Installation steps :</strong>

Faveo depends on the following:

-   **Apache** (with mod_rewrite enabled) 
-   **PHP 8.4+** with the following extensions: curl, dom, gd, json, mbstring, openssl, pdo_mysql, tokenizer, zip
-   **MySQL 8.0+** or **MariaDB 10.6+**
-   **SSL** ,Trusted CA Signed or Self-Signed SSL


<a id="-1-update-your-packages-and-install-some-utility-tools" name="-1-update-your-packages-and-install-some-utility-tools"></a>

### <strong> 1. Update your Packages and install some utility tools</strong>

Login as root user by typing the command below

```sh
sudo su
```
```sh
yum update -y && yum install unzip wget nano yum-utils curl openssl zip git tar -y
```

<b> 1.a. Install php-8.4 Packages </b>

### Alma 8 

```sh
sudo dnf upgrade --refresh -y
```

```sh
sudo dnf install \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-8.noarch.rpm
```

```sh
sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm -y

```
---

### Alma 9 

```sh
sudo dnf upgrade --refresh -y
```
```
sudo dnf install \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm
```

```
sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
```

--- 
Use the dnf module list command to see the options available for php

```sh
dnf module list php
```
Enable PHP 8.4 with the following command.
```sh
sudo dnf module enable php:remi-8.4 -y
```
Now install php 8.4 and the required extensions.
```sh
sudo dnf install php -y
yum -y install php-cli php-common php-fpm php-gd php-mbstring php-pecl-mcrypt php-mysqlnd php-odbc php-pdo php-xml  php-opcache php-imap php-bcmath php-ldap php-pecl-zip php-soap php-redis php-process php-posix
```
<b> 1.b. Install and run Apache</b>
Install and Enable Apache Server

```sh
yum install -y httpd
systemctl start httpd
systemctl enable httpd
```

<b> 1.c. Setting Up ionCube</b>
```sh
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar xfz ioncube_loaders_lin_x86-64.tar.gz
```
Copy ioncube loader to PHP modules Directory.

```sh
php -i | grep extension_dir
cp ioncube/ioncube_loader_lin_8.4.so /usr/lib64/php/modules 
sed -i '2 a zend_extension = "/usr/lib64/php/modules/ioncube_loader_lin_8.4.so"' /etc/php.ini
sed -i "s/max_execution_time = .*/max_execution_time = 300/" /etc/php.ini
```

<b> 1.d. Install and run Mysql/MariaDB</b>

The official Faveo installation uses Mysql/MariaDB as the database system and **this is the only official system we support**. While Laravel technically supports PostgreSQL and SQLite, we can't guarantee that it will work fine with Faveo as we've never tested it. Feel free to read [Laravel's documentation](https://laravel.com/docs/database#configuration) on that topic if you feel adventurous.

Note: Currently Faveo supports MySQL 8.0 and MariaDB-10.6.

Installby running the following commands.

### MariadDB-10.6 

```sh
curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
sudo bash mariadb_repo_setup --mariadb-server-version=10.6
sudo dnf install boost-program-options -y
sudo yum install MariaDB-server MariaDB-client MariaDB-backup
sudo systemctl enable --now mariadb
sudo systemctl start --now mariadb
```

### MySQL 8.0

```sh
yum update
dnf install mysql mysql-server

systemctl enable --now mysqld
systemctl start mysqld
```
Secure your MySql installation by executing the below command. Set Password for mysql root user, remove anonymous users, disallow remote root login, remove the test databases and finally reload the privilege tables.

```sh
mariadb-secure-installation  
```


<b>1.e. Install wkhtmltopdf</b>


Wkhtmltopdf is an open source simple and much effective command-line shell utility that enables user to convert any given HTML (Web Page) to PDF document or an image (jpg, png, etc). 

It uses WebKit rendering layout engine to convert HTML pages to PDF document without losing the quality of the pages. Its is really very useful and trustworthy solution for creating and storing snapshots of web pages in real-time.

```sh
yum install -y xorg-x11-fonts-75dpi xorg-x11-fonts-Type1 libpng libjpeg openssl icu libX11 libXext libXrender xorg-x11-fonts-Type1 xorg-x11-fonts-75dpi
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox-0.12.6.1-2.almalinux9.x86_64.rpm
sudo dnf install ./wkhtmltox-0.12.6.1-2.almalinux9.x86_64.rpm -y
```

<b>1.f. Install Meilisearch</b>

MeiliSearch is an open-source search engine developed in Rust that delivers flexible search and indexing capabilities. It adeptly handles typos, supports full-text search, synonyms, and comes packed with various features, making it an ideal choice for elevating search functionalities in Faveo.

[Meilisearch installation documentation](/docs/installation/providers/enterprise/meilisearch)

<a id="2-upload-faveo" name="2-upload-faveo"></a>

### <strong>2. Upload Faveo</strong> 

Please download Faveo Helpdesk from [https://billing.faveohelpdesk.com](https://billing.faveohelpdesk.com) and upload it to below directory

```sh
mkdir -p /var/www/faveo/
cd /var/www/faveo/
```
<b>Extracting the Faveo-Codebase zip file</b>

```sh
unzip "Filename.zip" -d /var/www/faveo
```

<a id="3-setup-the-database" name="3-setup-the-database"></a>

### <strong>3. Setup the database</strong>

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

<a id="4-configure-apache-webserver" name="4-configure-apache-webserver"></a>

### <strong>4. Configure Apache webserver</strong>

**4.a.** <b>Give proper permissions to the project directory by running:</b>

```sh
chown -R apache:apache /var/www/faveo
cd /var/www/faveo
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;
```
By default SELINUX will be Enforcing run the follwing comand to switch it to Permissive mode and restart the machine once in order to take effect.
```sh
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
reboot -f
```

**4.b.** <b>Enable the rewrite module of the Apache webserver:</b>

Check whether the Module exists in Apache modules directory.

```sh
ls /etc/httpd/modules | grep mod_rewrite
```
Check if the module is loaded
```sh
grep -i LoadModule /etc/httpd/conf/httpd.conf | grep rewrite
```
If the output af the above command is blank then add the below line in **/etc/httpd/conf/httpd.conf** i.e,

```
nano /etc/httpd/conf/httpd.conf
```

Add the below Line at the end of the file

```sh
LoadModule rewrite_module modules/mod_rewrite.so
```


Also disable Directory Browsing on Apache, change Options Indexes FollowSymLinks to Options -Indexes +FollowSymLinks & AllowOverride value from none to All under <Directory /var/www/> section.

```sh
<Directory "/var/www">
    Options -Indexes +FollowSymLinks
    AllowOverride All 
    # Allow open access:
    Require all granted
</Directory>
```


**4.c.** <b>Configure a new faveo site in apache by doing:</b>

Pick a editor of your choice copy the following and replace '--DOMAINNAME--' with the Domain name mapped to your Server's IP or you can just comment the 'ServerName' directive if Faveo is the only website served by your server.
```sh
nano /etc/httpd/conf.d/faveo.conf
```

```apache

<VirtualHost *:80> 
ServerName --DOMAINNAME-- 
ServerAdmin webmaster@localhost 
DocumentRoot /var/www/faveo/public 
<Directory /var/www/faveo> 
AllowOverride All 
</Directory> 
ErrorLog /var/log/httpd/faveo-error.log 
CustomLog /var/log/httpd/faveo-access.log combined
</VirtualHost>
```

**4.d.** Apply the new `.conf` file and restart Apache. You can do that by running:

```sh
systemctl restart httpd.service
```


<a id="5-configure-cron-job" name="5-configure-cron-job"></a>

### <strong>5. Configure cron job</strong>

Faveo requires some background processes to continuously run. 
Basically those crons are needed to receive emails
To do this, setup a cron that runs every minute that triggers the following command `php artisan schedule:run`. Verify your php ececutable location and replace it accordingly in the below command.

[comment]: <Create a new `/etc/cron.d/faveo` file with:>

```sh
(sudo -u apache crontab -l 2>/dev/null; echo "* * * * * /usr/bin/php /var/www/faveo/artisan schedule:run 2>&1") | sudo -u apache crontab -
```

<a id="6-redis-installation" name="6-redis-installation"></a>

### <strong>6. Redis Installation</strong>

Redis is an open-source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.

This will improve system performance and is highly recommended.

[Redis installation documentation](/docs/installation/providers/enterprise/alma-redis)

<a id="7-ssl-installation" name="7-ssl-installation"></a>

### <strong>7. SSL Installation</strong>

Secure Sockets Layer (SSL) is a standard security technology for establishing an encrypted link between a server and a client. Let's Encrypt is a free, automated, and open certificate authority.

Faveo Requires HTTPS so the SSL is a must to work with the latest versions of faveo, so for the internal network and if there is no domain for free you can use the Self-Signed-SSL.

[Let’s Encrypt SSL installation documentation](/docs/installation/providers/enterprise/alma-apache-ssl)

[Paid SSL Certificate Documentation](/docs/installation/providers/enterprise/paid-ssl-alma/)

[Self Signed SSL Certificate Documentation](/docs/installation/providers/enterprise/self-signed-ssl-alma/)

<a id="8-install-faveo" name="8-install-faveo"></a>

### <strong>8. Install Faveo</strong>

At this point if the domainname is propagated properly with your server's IP you can open Faveo in browser just by entering your domainname.
You can also check the Propagation update by Visiting this site www.whatsmydns.net.

Now you can install Faveo via [GUI](/docs/installation/installer/gui) Wizard or [CLI](/docs/installation/installer/cli).

<a id="9-faveo-backup" name="9-faveo-backup"></a>

### <strong>9. Faveo Backup</strong>


At this stage, Faveo has been installed, it is time to setup the backup for Faveo File System and Database. [Follow this article](/docs/helper/backup) to setup Faveo backup.

<a id="10-final-step" name="10-final-step"></a>

### <strong>10. Final step</strong>

The final step is to have fun with your newly created instance, which should be up and running to `http://localhost` or the domain you have configured Faveo with.



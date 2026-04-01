---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/rocky9-nginx/
redirect_from:
  - /theme-setup/
last_modified_at: 2024-01-12
last_modified_by: Mohammad_Asif
toc: true
title: Installing Faveo Helpdesk on Rocky OS With Nginx Webserver
---

<img alt="Rocky OS Logo" src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Rocky_Linux_wordmark.svg/800px-Rocky_Linux_wordmark.svg.png" width="200"  />

Faveo can run on [Rocky](https://rockylinux.org/download/).

This document is meant for Faveo Freelancer, Paid and Enterprise Versions.

- [<strong>Installation steps :</strong>](#installation-steps-)
    - [<strong> 1. Update your Packages and install some utility tools</strong>](#-1-update-your-packages-and-install-some-utility-tools)
    - [<strong>2. Upload Faveo</strong>](#2-upload-faveo)
    - [<strong>3. Setup the database</strong>](#3-setup-the-database)
    - [<strong>4. Configure Nginx webserver </strong>](#4-configure-nginx-webserver-)
    - [<strong>5. Configure cron job</strong>](#5-configure-cron-job)
    - [<strong>6. Redis Installation</strong>](#6-redis-installation)
    - [<strong>7. SSL Installation</strong>](#7-ssl-installation)
    - [<strong>8. Install Faveo</strong>](#8-install-faveo)
    - [<strong>9. Faveo Backup</strong>](#9-faveo-backup)
    - [<strong>10. Final step</strong>](#10-final-step)

<a id="installation-steps-" name="installation-steps-"></a>

# <strong>Installation steps :</strong>

Faveo depends on the following:

-   **Web Server**  Nginx/Apache 
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

### Rocky 8
```sh
sudo dnf -y install epel-release
sudo dnf config-manager --set-enabled powertools

sudo dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
sudo dnf -y makecache
sudo dnf -y repolist
```

Use the dnf module list command to see the options available for php

```sh
sudo dnf module list php
sudo dnf -y module reset php
```
Enable PHP 8.4 with the following command.
```sh
sudo dnf module install php:remi-8.4
```
Now install php 8.4 and the required extensions.
```sh
sudo dnf install php -y
yum -y install php-cli php-common php-fpm php-gd php-mbstring php-pecl-mcrypt php-mysqlnd php-odbc php-pdo php-xml  php-opcache php-imap php-bcmath php-ldap php-pecl-zip php-soap php-redis
```

### Rocky 9

```sh
sudo dnf upgrade --refresh -y
sudo dnf config-manager --set-enabled crb
sudo dnf install \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm
    
sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
```
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


<b> 1.b. Install and run Nginx </b>

Use the below steps to install and start Nginx

```sh
yum install -y nginx
systemctl start nginx
systemctl enable nginx
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

<a id="4-configure-nginx-webserver-" name="4-configure-nginx-webserver-"></a>

###  <strong>4. Configure Nginx webserver </strong>

**4.a.** <b>Give proper permissions to the project directory by running:</b>

```sh
chown -R nginx:nginx /var/www/faveo
cd /var/www/faveo
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;
```
By default SELINUX will be in Enforcing mode run the follwing command to switch it to Permissive mode and restart the machine once in order to take effect.
```sh
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
reboot -f
```
**4.b.** <b>Edit nginx.conf file and replace the default server block code with the following</b>

```sh
nano /etc/nginx/nginx.conf
```
Replace the default server block code with the following. 
Also relpace --YOUR DOMAIN NAME-- with your Domain name.

```
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        server_name  --YOUR DOMAIN NAME--;
        root         /var/www/faveo/public/;
        index index.php index.html index.htm;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

#This is for user friendly URL 
	location ~ \.php$ {
	    try_files $uri =404;
	    fastcgi_pass 127.0.0.1:9000;
	    fastcgi_index index.php;
	    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
	    include fastcgi_params;
	}

	location / {
		try_files $uri $uri/ /index.php?$query_string;
	}

	location ~* \.html$ {
	    expires -1;
	}

	location ~* \.(css|gif|jpe?g|png)$ {
	    expires 1M;
	    add_header Pragma public;
	    add_header Cache-Control "public, must-revalidate, proxy-revalidate";
	}

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }

	gzip on;
	gzip_http_version 1.1;
	gzip_vary on;
	gzip_comp_level 6;
	gzip_proxied any;
	gzip_types application/atom+xml
           application/javascript
           application/json
           application/vnd.ms-fontobject
           application/x-font-ttf
           application/x-web-app-manifest+json
           application/xhtml+xml
           application/xml
           font/opentype
           image/svg+xml
           image/x-icon
           text/css
           #text/html -- text/html is gzipped by default by nginx
           text/plain
           text/xml;
	gzip_buffers 16 8k;
	gzip_disable "MSIE [1-6]\.(?!.*SV1)";

}
```

**4.c.** <b>Edit config file for PHP FPM using vim editor</b>

```sh
nano /etc/php-fpm.d/www.conf
```
You have to replace these lines.

```
user = apache   (to)   user = nginx
group = apache  (to)   group = nginx

listen.owner = nobody   (to)    listen.owner = nginx
listen.group = nobody   (to)    listen.group = nginx
```

Restart PHP-FPM and NGINX
```sh
systemctl start php-fpm.service
systemctl enable php-fpm.service
systemctl restart nginx
```
<a id="5-configure-cron-job" name="5-configure-cron-job"></a>

### <strong>5. Configure cron job</strong>

Faveo requires some background processes to continuously run. 
Basically those crons are needed to receive emails
To do this, setup a cron that runs every minute that triggers the following command `php artisan schedule:run`.

[comment]: <Create a new `/etc/cron.d/faveo` file with:>

```sh
(sudo -u nginx crontab -l 2>/dev/null; echo "* * * * * /usr/bin/php /var/www/faveo/artisan schedule:run 2>&1") | sudo -u nginx crontab -
```

<a id="6-redis-installation" name="6-redis-installation"></a>

### <strong>6. Redis Installation</strong>
Redis is an open-source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.

This is an optional step and will improve system performance and is highly recommended.

[Redis installation documentation](/docs/installation/providers/enterprise/rocky-redis)

<a id="7-ssl-installation" name="7-ssl-installation"></a>

### <strong>7. SSL Installation</strong>

Secure Sockets Layer (SSL) is a standard security technology for establishing an encrypted link between a server and a client. Let's Encrypt is a free, automated, and open certificate authority.

This will improve system security and is highly recommended.

[Let’s Encrypt SSL installation documentation](/docs/installation/providers/enterprise/rocky-nginx-ssl)

[Paid SSL Certificate Documentation](/docs/installation/providers/enterprise/paid-ssl-rocky-nginx/)

[Self Signed SSL Certificate Documentation](/docs/installation/providers/enterprise/self-signed-ssl-rocky-nginx/)

<a id="8-install-faveo" name="8-install-faveo"></a>

### <strong>8. Install Faveo</strong>
At this point if the domainname is propagated properly with your server’s IP you can open Faveo in browser just by entering your domainname. You can also check the Propagation update by Visiting this site www.whatsmydns.net.

Now you can install Faveo via [GUI](/docs/installation/installer/gui) Wizard or [CLI](/docs/installation/installer/cli)

<a id="9-faveo-backup" name="9-faveo-backup"></a>

### <strong>9. Faveo Backup</strong>


At this stage, Faveo has been installed, it is time to setup the backup for Faveo File System and Database. [Follow this article](/docs/helper/backup) to setup Faveo backup.


<a id="10-final-step" name="10-final-step"></a>

### <strong>10. Final step</strong>

The final step is to have fun with your newly created instance, which should be up and running to `http://localhost` or the domain you have configured Faveo with.

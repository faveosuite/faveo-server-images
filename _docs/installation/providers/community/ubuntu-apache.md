---
layout: single
type: docs
permalink: /docs/installation/providers/community/ubuntu-apache/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-04-09
last_modified_by: Mohammad_Asif
toc: true
title: Installing Faveo Helpdesk Community Edition on Ubuntu With Apache Webserver
---


<img alt="Ubuntu" src="https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Logo-ubuntu_cof-orange-hex.svg/120px-Logo-ubuntu_cof-orange-hex.svg.png" width="120" height="120" />

Faveo can run on [Ubuntu 22.04 (Jammy Jellyfish), Ubuntu 24.04 (Noble Numbat)](http://releases.ubuntu.com/22.04/).

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
    - [<strong>11. Final step</strong>](#11-final-step)



<a id="installation-steps-" name="installation-steps-"></a>

# <strong>Installation steps :</strong>

Faveo depends on the following:

-   **Apache** (with mod_rewrite enabled) 
-   **PHP 8.1+** with the following extensions: curl, dom, gd, json, mbstring, openssl, pdo_mysql, tokenizer, zip
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

<b>2.a. PHP 8.1+</b>

First add this PPA repository:

```sh
add-apt-repository ppa:ondrej/php
```

Then install php 8.1 with these extensions:

```sh
apt update
apt install -y php8.1 libapache2-mod-php8.1 php8.1-mysql \
    php8.1-cli php8.1-common php8.1-fpm php8.1-soap php8.1-gd \
    php8.1-opcache  php8.1-mbstring php8.1-zip \
    php8.1-bcmath php8.1-intl php8.1-xml php8.1-curl  \
    php8.1-imap php8.1-ldap php8.1-gmp php8.1-redis
```
After installing PHP 8.1, run the commands below to open PHP default config file.

```sh
nano /etc/php/8.1/fpm/php.ini
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
cp ioncube/ioncube_loader_lin_8.1.so /usr/lib/php/'replaceyourpath'
sed -i '2 a zend_extension = "/usr/lib/php/'replaceyourpath'/ioncube_loader_lin_8.1.so"' /etc/php/8.1/apache2/php.ini
sed -i '2 a zend_extension = "/usr/lib/php/'replaceyourpath'/ioncube_loader_lin_8.1.so"' /etc/php/8.1/cli/php.ini
sed -i '2 a zend_extension = "/usr/lib/php/'replaceyourpath'/ioncube_loader_lin_8.1.so"' /etc/php/8.1/fpm/php.ini

systemctl restart apache2 
```

<b>2.c.  Install MySQL/MariaDB</b>

The official Faveo installation uses Mysql/MariaDB as the database system and **this is the only official system we support**. While Laravel technically supports PostgreSQL and SQLite, we can't guarantee that it will work fine with Faveo as we've never tested it. Feel free to read [Laravel's documentation](https://laravel.com/docs/database#configuration) on that topic if you feel adventurous.

You can install either MySQL or MariaDB. We have given options for both MySQL and MariaDB below.

<b>2.c.1. MySQL 8.0</b>

Install Mysql 8.0. Note that this only installs the package, but does not setup Mysql. This is done later in the instructions:

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


```
apt install libfontenc1 xfonts-75dpi xfonts-base xfonts-encodings xfonts-utils
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
dpkg -i wkhtmltox_0.12.6.1-3.jammy_amd64.deb
```

Once the softwares above are installed:


<a id="3-upload-faveo" name="3-upload-faveo"></a>

### <strong>3. Upload Faveo</strong>

You may install Faveo by simply cloning the repository. In order for this to work with Apache, you need to clone the repository in a specific folder:

```sh
mkdir -p /var/www/
cd /var/www/
git clone https://github.com/ladybirdweb/faveo-helpdesk.git faveo
```
You should check out a tagged version of Faveo since `master` branch may not always be stable. Find the latest official version on the [release page](https://github.com/ladybirdweb/faveo-helpdesk/releases)

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
# Enable php8.1 fpm, and restart apache
a2enmod proxy_fcgi setenvif
a2enconf php8.1-fpm
```
 **5.c.** <b>Apply the new `.conf` file and restart Apache and PHP-FPM. You can do that by running:</b>

```sh
service php8.1-fpm restart
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

[Self Signed SSL Certificate Documentation](/docs/installation/providers/enterprise/self-signed-ssl-ubuntu/)

<a id="9-install-faveo" name="9-install-faveo"></a>

### <strong>9. Install Faveo</strong>

At this point if the domainname is propagated properly with your server's IP you can open Faveo in browser just by entering your domainname.
You can also check the Propagation update by Visiting this site www.whatsmydns.net.

Now you can install Faveo via [GUI](/docs/installation/installer/gui) Wizard or [CLI](/docs/installation/installer/cli)


<a id="10-faveo-backup" name="10-faveo-backup"></a>

### <strong>10. Faveo Backup</strong>


At this stage, Faveo has been installed, it is time to setup the backup for Faveo File System and Database. [Follow this article](/docs/helper/backup) to setup Faveo backup.

<a id="11-final-step" name="11-final-step"></a>

### <strong>11. Final step</strong>

The final step is to have fun with your newly created instance, which should be up and running to `http://localhost` or the domain you have configured Faveo with.

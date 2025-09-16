---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/debian-apache/
redirect_from:
  - /theme-setup/
last_modified_at: 2024-09-16
last_modified_by: Mohammad_Asif
toc: true
title: Installing Faveo Helpdesk on Debian With Apache Webserver
---

<img alt="debian" src="https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Debian-OpenLogo.svg/109px-Debian-OpenLogo.svg.png" width="96" height="127" />

Faveo can run on Debian 11 (Bullseye), Debian 12 (Bookworm).

This document is meant for Faveo Freelancer, Paid and Enterprise Versions.

- [<strong>Installation steps :</strong>](#installation-steps-)
    - [<strong>1. Update the packages</strong>](#1-update-the-packages)
    - [<strong>2. Upload Faveo</strong>](#2-upload-faveo)
    - [<strong>3. Setup the database</strong>](#3-setup-the-database)
    - [<strong>4. Configure Apache webserver</strong>](#4-configure-apache-webserver)
    - [<strong>5. Configure cron job</strong>](#5-configure-cron-job)
    - [<strong>6. Redis Installation</strong>](#6-redis-installation)
    - [<strong>7. SSL Installation</strong>](#7-ssl-installation)
    - [<strong>8. Install Faveo</strong>](#8-install-faveo)
    - [<strong>9. Faveo Backup</strong>](#9-faveo-backup)
    - [<strong>10. Webserver Hardening</strong>](#10-webserver-hardening)
    - [<strong>11. Final step</strong>](#11-final-step)


<a id="installation-steps-" name="installation-steps-"></a>

# <strong>Installation steps :</strong>


-   **Apache** (with mod_rewrite enabled) 
-   **PHP 8.2+** with the following extensions: curl, dom, gd, json, mbstring, openssl, pdo_mysql, tokenizer, zip
-   **MySQL 8.0+** or **MariaDB 10.6+**
-   **SSL** ,Trusted CA Signed or Self-Signed SSL
  


<a id="1-update-the-packages" name="1-update-the-packages"></a>

### <strong>1. Update the packages</strong>
Run the following commands as sudoers or Login as root user by typing the command below

```sh
sudo su
```

```sh
apt update
```

<b>1.a. Install some Utility packages</b>

```sh
apt install -y git wget curl unzip nano zip
```
<b>1.b. Apache should come pre-installed with your server. If it's not, install it with:</b>

```sh
apt install -y apache2
systemctl start apache2
systemctl enable apache2
```

<b>1.c. PHP 8.2+</b>

Note: In Debian upon installing PHP packages apache2 will be automatically installed and started.

Before we install PHP 8.2, it’s important to make sure your system is up to date by running the following apt commands.

```sh
sudo apt update
sudo apt install apt-transport-https lsb-release ca-certificates
```

Add the Ondřej Surý PHP repository.

```sh
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
```
Now Install PHP 8.2 and extensions.
```sh
sudo apt update
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

Then make the changes on the following lines below in the file and save. The value below are great settings to apply in your environments.

```
file_uploads = On
allow_url_fopen = On
short_open_tag = On
memory_limit = 256M
cgi.fix_pathinfo = 0
upload_max_filesize = 100M
max_execution_time = 360
```

<b>1.d. Setting Up ionCube</b>
```sh
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz 
tar xvfz ioncube_loaders_lin_x86-64.tar.gz 
```
Make the note of path and directory from the above command.

Copy ioncube loader to Directory. Replace your *yourpath* below with actual path that was shown with the first command below.

```sh
php -i | grep extension_dir
cp ioncube/ioncube_loader_lin_8.2.so /usr/lib/php/'replaceyourpath'
sed -i '2 a zend_extension = "/usr/lib/php/'replaceyourpath'/ioncube_loader_lin_8.2.so"' /etc/php/8.2/apache2/php.ini
sed -i '2 a zend_extension = "/usr/lib/php/'replaceyourpath'/ioncube_loader_lin_8.2.so"' /etc/php/8.2/cli/php.ini
sed -i '2 a zend_extension = "/usr/lib/php/'replaceyourpath'/ioncube_loader_lin_8.2.so"' /etc/php/8.2/fpm/php.ini
systemctl restart apache2 
```

<b>1.e. Install MySQL/MariaDB</b>

The official Faveo installation uses Mysql/MariaDB as the database system and **this is the only official system we support**. While Laravel technically supports PostgreSQL and SQLite, we can't guarantee that it will work fine with Faveo as we've never tested it. Feel free to read [Laravel's documentation](https://laravel.com/docs/database#configuration) on that topic if you feel adventurous.

You can install either MySQL or MariaDB. We have given options for both MySQL and MariaDB below.

<b>1.e.1. MySQL</b>

Install Mysql 8.0. Note that this only installs the package, but does not setup Mysql. This is done later in the instructions:


<b> For Debian 11, 12</b>

```sh
sudo apt update
wget https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb
sudo dpkg -i mysql-apt-config*
```
A pop-up window displays after you run the above command. Select MySQL Server & Cluster with the Arrow key and hit Enter.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/Debian-images/mysql-debian-3.png" alt="" style=" width:400px ; height:250px ">

In this instance, MySQL-8.0 is the version of the server that was available. Select MySQL-8.0 and click  Enter.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/Debian-images/mysql-debian-1.png" alt="" style=" width:400px ; height:250px ">

Now, click OK on your screen to finish the configuration.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/Debian-images/mysql-debian-2.png" alt="" style=" width:400px ; height:250px ">

```
sudo apt update
sudo apt install mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql
```

Secure your MySql installation by executing the below command. Set Password for mysql root user by providing a strong password combination of Uppercase, Lowercase, alphanumeric and special symbols, remove anonymous users, disallow remote root login, remove the test databases and finally reload the privilege tables.
```
sudo mysql_secure_installation 
```

<b>1.e.2. MariaDB 10.6</b>

Install MariaDB 10.6. Note that this only installs the package, but does not setup Mysql. This is done later in the instructions:

> **NOTE** :
> Debian 12 does not currently support MariaDB version 10.6.

<b> For Debian 11</b>

```
sudo apt update
sudo apt-get install curl software-properties-common dirmngr
curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
sudo bash mariadb_repo_setup --mariadb-server-version=10.6
sudo apt-get update
sudo apt-get install mariadb-server mariadb-client
sudo systemctl start mariadb
sudo systemctl enable mariadb
```
Secure your MySql installation by executing the below command. Set Password for mysql root user by providing a strong password combination of Uppercase, Lowercase, alphanumeric and special symbols, remove anonymous users, disallow remote root login, remove the test databases and finally reload the privilege tables.
```
sudo mysql_secure_installation 
```

<b>1.f. Install wkhtmltopdf</b>


Wkhtmltopdf is an open source simple and much effective command-line shell utility that enables user to convert any given HTML (Web Page) to PDF document or an image (jpg, png, etc). 

It uses WebKit rendering layout engine to convert HTML pages to PDF document without losing the quality of the pages. Its is really very useful and trustworthy solution for creating and storing snapshots of web pages in real-time.

**For Debian 11**

```sh
apt-get -y install wkhtmltopdf
```
**For Debian 12**

```sh
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb
sudo apt install ./wkhtmltox*bookworm_amd64.deb
```


<b>1.g. Install Meilisearch</b>

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

First make the database a bit more secure.

```sh
mysql_secure_installation
```

Next log in with the root account to configure the database.

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

We have to authorize the new user on the `faveo` db so that he is allowed to change the database.

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

<b>4.a. Give proper permissions to the project directory by running:</b>

```sh
sudo chown -R www-data:www-data /var/www/faveo
cd /var/www/faveo/
sudo find . -type f -exec chmod 644 {} \;
sudo find . -type d -exec chmod 755 {} \;
```

<b>4.b. Enable the rewrite module of the Apache webserver:</b>

```sh
a2enmod rewrite
```

<b>4.c. Configure a new Faveo site in apache by doing:</b>

Pick a editor of your choice copy the following and replace '--DOMAINNAME--' with the Domainname mapped to your Server's IP or you can just comment the 'ServerName' directive if Faveo is the only website served by your server.

```sh
nano /etc/apache2/sites-available/faveo.conf
```

```html
<VirtualHost *:80>
    ServerName --DOMAINNAME--

    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/faveo/public

    <Directory /var/www/faveo/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

<b>4.d. Apply the new `.conf` file and restart Apache and PHP-FPM. You can do that by running:</b>

```sh
a2dissite 000-default.conf
a2ensite faveo.conf
systemctl restart apache2
systemctl restart php8.2-fpm
```

<a id="5-configure-cron-job" name="5-configure-cron-job"></a>

### <strong>5. Configure cron job</strong>

Faveo requires some background processes to continuously run. 
Basically those crons are needed to receive emails
To do this, setup a cron that runs every minute that triggers the following command `php artisan schedule:run`.

[comment]: <Create a new `/etc/cron.d/faveo` file with:>

```sh
(sudo -u www-data crontab -l 2>/dev/null; echo "* * * * * /usr/bin/php /var/www/faveo/artisan schedule:run 2>&1") | sudo -u www-data crontab -
```

<a id="6-redis-installation" name="6-redis-installation"></a>

### <strong>6. Redis Installation</strong>

Redis is an open-source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.

This will improve system performance and is highly recommended.

[Redis installation documentation](/docs/installation/providers/enterprise/debian-redis)

<a id="7-ssl-installation" name="7-ssl-installation"></a>

### <strong>7. SSL Installation</strong>

Secure Sockets Layer (SSL) is a standard security technology for establishing an encrypted link between a server and a client. Let's Encrypt is a free, automated, and open certificate authority.

Faveo Requires HTTPS so the SSL is a must to work with the latest versions of faveo, so for the internal network and if there is no domain for free you can use the Self-Signed-SSL.

[Let’s Encrypt SSL installation documentation](/docs/installation/providers/enterprise/debian-apache-ssl)

[Paid SSL certificate Documentation](/docs/installation/providers/enterprise/paid-ssl-debian/ )

[Self Signed SSL certificate Documentation](/docs/installation/providers/enterprise/self-signed-ssl-debian/)

<a id="8-install-faveo" name="8-install-faveo"></a>

### <strong>8. Install Faveo</strong>

At this point if the domainname is propagated properly with your server’s IP you can open Faveo in browser just by entering your domainname. You can also check the Propagation update by Visiting this site www.whatsmydns.net.

Now you can install Faveo via [GUI](/docs/installation/installer/gui) Wizard or [CLI](/docs/installation/installer/cli)

<a id="9-faveo-backup" name="9-faveo-backup"></a>

### <strong>9. Faveo Backup</strong>


At this stage, Faveo has been installed, it is time to setup the backup for Faveo File System and Database. [Follow this article](/docs/helper/backup) to setup Faveo backup.


<a id="10-webserver-hardening" name="1-webserver-hardening"></a>

### <strong>10. Webserver Hardening</strong>

Once the installation is complete, it is recommended to harden the webserver to enhance security. Follow our guide to apply best practices such as disabling unnecessary modules, enforcing security headers, and restricting access permissions.

[Apache Hardening](/docs/helpers/server-hardening/apache-hardening)


<a id="11-final-step" name="11-final-step"></a>

### <strong>11. Final step</strong>

The final step is to have fun with your newly created instance, which should be up and running to `http://localhost` or the domain you have configured Faveo with.

---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/centos8s-nginx/
redirect_from:
  - /theme-setup/
last_modified_at: 2020-06-09
toc: true
---

# Installing Faveo Helpdesk Freelancer, paid and Enterprise on Cent OS 8 Stream <!-- omit in toc -->


<img alt="Centos-8-stream" src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Centos-logo-light.svg/300px-Centos-logo-light.svg.png" width="200"  />

Faveo can run on [CentOS-8-Stream](https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Centos-logo-light.svg/300px-Centos-logo-light.svg.png).

- [<strong>Installation steps :</strong>](#installation-steps-)
    - [<strong> 1. LAMP Installation</strong>](#-1-lamp-installation)
    - [<strong> 2. Update your Packages and install some utility tools</strong>](#-2-update-your-packages-and-install-some-utility-tools)
    - [<strong>3. Upload Faveo</strong>](#3-upload-faveo)
    - [<strong>4. Setup the database</strong>](#4-setup-the-database)
    - [<strong>5. Configure Nginx webserver </strong>](#5-configure-nginx-webserver-)
    - [<strong>6. Configure cron job</strong>](#6-configure-cron-job)
    - [<strong>7. Redis Installation</strong>](#7-redis-installation)
    - [<strong>8. SSL Installation</strong>](#8-ssl-installation)
    - [<strong>9. Install Faveo</strong>](#9-install-faveo)
    - [<strong>10. Final step</strong>](#10-final-step)

<a id="installation-steps-" name="installation-steps-"></a>

# <strong>Installation steps :</strong> 

Faveo depends on the following:

-   **Nginx** 
-   **PHP 8.1+** with the following extensions: curl, dom, gd, json, mbstring, openssl, pdo_mysql, tokenizer, zip
-   **MySQL 8.0+** or **MariaDB 10.6+**
-   **SSL** ,Trusted CA Signed or Slef-Signed SSL

<a id="-1-lamp-installation" name="-1-lamp-installation"></a>

### <strong> 1. LAMP Installation</strong>

Follow the [instructions here](https://github.com/teddysun/lamp)
If you follow this step, no need to install Apache, PHP, MySQL separetely as listed below

<a id="-2-update-your-packages-and-install-some-utility-tools" name="-2-update-your-packages-and-install-some-utility-tools"></a>

### <strong> 2. Update your Packages and install some utility tools</strong>

Login as root user by typing the command below

```sh
sudo su
```
```sh
yum update -y && yum install unzip wget nano yum-utils curl openssl zip git -y
```

<b> 2.a. Install php-8.1 Packages </b>


```sh
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
yum install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm

dnf module install php:remi-8.1 -y
yum -y install php php-cli php-common php-fpm php-gd php-mbstring php-pecl-mcrypt php-mysqlnd php-odbc php-pdo php-xml  php-opcache php-imap php-bcmath php-ldap php-pecl-zip php-soap php-redis
```
<b> 2.b. Install and run Nginx </b>

Use the below steps to install and start Nginx

```sh
yum install -y nginx
systemctl start nginx
systemctl enable nginx
```

<b> 2.c. Setting Up ionCube</b>

```sh
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar xfz ioncube_loaders_lin_x86-64.tar.gz
```
Copy ioncube loader to Directory.

```sh
php -i | grep extension_dir
cp ioncube/ioncube_loader_lin_8.1.so /usr/lib64/php/modules 
sed -i '2 a zend_extension = "/usr/lib64/php/modules/ioncube_loader_lin_8.1.so"' /etc/php.ini
sed -i "s/max_execution_time = .*/max_execution_time = 300/" /etc/php.ini
```

<b> 2.d. Install and run Mysql/MariaDB</b>

The official Faveo installation uses Mysql as the database system and **this is the only official system we support**. While Laravel technically supports PostgreSQL and SQLite, we can't guarantee that it will work fine with Faveo as we've never tested it. Feel free to read [Laravel's documentation](https://laravel.com/docs/database#configuration) on that topic if you feel adventurous.

Note: Currently Faveo supports only Mysql-8.0 and MariaDB-10.6.
Note: The below steps only installs the package, but does not setup the database required by Faveo. This is done later in the instructions.

In CentOS-8-Stream mariadb-server-10.6 is available from the default Repo's.So instead of downloading and adding other Repos you could simply install MariadDB-10.6 by running the following commands.

```sh
curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
sudo bash mariadb_repo_setup --mariadb-server-version=10.6
sudo dnf install boost-program-options -y
sudo dnf module reset mariadb -y
sudo yum install MariaDB-server MariaDB-client MariaDB-backup
sudo systemctl enable --now mariadb
sudo systemctl start --now mariadb
```

Secure your MySql installation by executing the below command. Set Password for mysql root user, remove anonymous users, disallow remote root login, remove the test databases and finally reload the privilege tables.

```sh
mysql_secure_installation 
```

**phpMyAdmin(Optional):** 
Install phpMyAdmin. This is optional step. phpMyAdmin gives a GUI to access and work with Database

```sh
yum install phpmyadmin
```

Once the softwares above are installed:


<a id="3-upload-faveo" name="3-upload-faveo"></a>

### <strong>3. Upload Faveo</strong>

Please download Faveo Helpdesk from [https://store.faveohelpdesk.com](https://store.faveohelpdesk.com) and upload it to below directory

```sh
mkdir -p /var/www/faveo
cd /var/www/faveo
```
**3.a** <b>Extracting the Faveo-Codebase zip file</b>

```sh
unzip "Filename.zip" -d /var/www/faveo
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


<a id="5-configure-nginx-webserver-" name="5-configure-nginx-webserver-"></a>

###  <strong>5. Configure Nginx webserver </strong>

**5.a.** Give proper permissions to the project directory by running:

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
**5.b.** Edit nginx.conf file and replace the default server block code with the following/

```sh
nano /etc/nginx/nginx.conf
```
Replace the default server block code with the following and you can also replace example.com with your Domain name.

```nginx
server {
    listen   80;
    server_name  example.com www.example.com;

# note that these lines are originally from the "location /" block
root   /var/www/faveo/public;
index index.php index.html index.htm;


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

**5.c.** Edit config file for PHP FPM using nano editor

```sh
nano /etc/php-fpm.d/www.conf
```
You have to replace these lines.

```
user = nginx

group = nginx

listen.owner = nobody (to) listen.owner = nginx

listen.group = nobody (to) listen.group = nginx

Uncomment listen = 127.0.0.1:9000 by removing (;) 
In CentOS-8-Stream-OS 8 you will find listen = /run/php-fpm/www.sock replace it (to) listen = 127.0.0.1:9000.

```

Restart PHP-FPM and NGINX
```sh
systemctl start php-fpm.service
systemctl enable php-fpm.service
systemctl restart nginx
```
<a id="6-configure-cron-job" name="6-configure-cron-job"></a>

### <strong>6. Configure cron job</strong>

Faveo requires some background processes to continuously run. 
Basically those crons are needed to receive emails
To do this, setup a cron that runs every minute that triggers the following command `php artisan schedule:run`.

Create a new `/etc/cron.d/faveo` file with:

```sh
echo "* * * * * nginx /bin/php /var/www/faveo/artisan schedule:run 2>&1" | sudo tee /etc/cron.d/faveo
```

<a id="7-redis-installation" name="7-redis-installation"></a>

### <strong>7. Redis Installation</strong>

Redis is an open-source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.

This is an optional step and will improve system performance and is highly recommended.

[Redis installation documentation](/docs/installation/providers/enterprise/centos8s-redis)

<a id="8-ssl-installation" name="8-ssl-installation"></a>

### <strong>8. SSL Installation</strong>

Secure Sockets Layer (SSL) is a standard security technology for establishing an encrypted link between a server and a client. Let's Encrypt is a free, automated, and open certificate authority.

This is an optional step and will improve system security and is highly recommended.

[Let’s Encrypt SSL installation documentation](/docs/installation/providers/enterprise/centos8s-nginx-ssl)

<a id="9-install-faveo" name="9-install-faveo"></a>

### <strong>9. Install Faveo</strong>

At this point if the domainname is propagated properly with your server’s IP you can open Faveo in browser just by entering your domainname. You can also check the Propagation update by Visiting this site www.whatsmydns.net.

Now you can install Faveo via [GUI](/docs/installation/installer/gui) Wizard or [CLI](/docs/installation/installer/cli)

<a id="10-final-step" name="10-final-step"></a>

### <strong>10. Final step</strong>

The final step is to have fun with your newly created instance, which should be up and running to `http://localhost` or the domain you have configured Faveo with.

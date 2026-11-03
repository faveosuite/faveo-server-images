---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/centos-apache/
redirect_from:
  - /theme-setup/
last_modified_at: 2022-05-07
toc: true
---
# Installing Faveo Helpdesk Freelancer, Paid and Enterprise on CentOS 7  with Apache<!-- omit in toc -->

<img alt="CentOS Logo" src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Centos-logo-light.svg/300px-Centos-logo-light.svg.png" width="200"  />

Faveo can run on [CentOS 7 ](https://www.centos.org/download/).


- [<strong>Installation steps:</strong>](#installation-steps)
    - [<strong>1. LAMP Installation</strong>](#1-lamp-installation)
    - [<strong>2. Update your Packages and install some utility tools</strong>](#2-update-your-packages-and-install-some-utility-tools)
    - [<strong>3. Upload Faveo</strong>](#3-upload-faveo)
    - [<strong>4.Setup the database</strong>](#4setup-the-database)
    - [<strong>5. Configure Apache webserver</strong>](#5-configure-apache-webserver)
    - [<strong>6.Configure cron job</strong>](#6configure-cron-job)
    - [<strong>7.Redis Installation</strong>](#7redis-installation)
    - [<strong>8.SSL Installation</strong>](#8ssl-installation)
    - [<strong>9.Install Faveo</strong>](#9install-faveo)
    - [<strong>10.Final step</strong>](#10final-step)

<a id="installation-steps" name="installation-steps"></a>

# <strong>Installation steps:</strong>

Faveo depends on the following:

-   **Apache** (with mod_rewrite enabled) 
-   **PHP 8.1+** with the following extensions: curl, dom, gd, json, mbstring, openssl, pdo_mysql, tokenizer, zip
-   **MariaDB 10.6+**
-   **SSL** ,Trusted CA Signed or Slef-Signed SSL
<a id="1-lamp-installation" name="1-lamp-installation"></a>

### <strong>1. LAMP Installation</strong>

Follow the [instructions here](https://github.com/teddysun/lamp)
If you follow this step, no need to install Apache, PHP, MariaDB separetely as listed below

<a id="2-update-your-packages-and-install-some-utility-tools" name="2-update-your-packages-and-install-some-utility-tools"></a>

### <strong>2. Update your Packages and install some utility tools</strong>

Login as root user by typing the command below

```sh
sudo su
```
```sh
yum update -y && yum install unzip wget nano yum-utils curl openssl zip git -y
```

<b>2.a Install php-8.1 Packages </b>
```sh
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm 
yum install -y https://mirror.webtatic.com/yum/el7/webtatic-release.rpm 
yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm 

yum-config-manager --enable remi-php81
yum -y install php php-cli php-common php-fpm php-gd php-mbstring php-pecl-mcrypt php-mysqlnd php-odbc php-pdo php-xml  php-opcache php-imap php-bcmath php-ldap php-pecl-zip php-soap php-redis
```

<b>2.b Install and run Apache</b>
Install and Enable Apache Server

```sh
yum install -y httpd
systemctl start httpd
systemctl enable httpd
```

<b>2.c Setting Up ionCube</b>
```sh
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar xfz ioncube_loaders_lin_x86-64.tar.gz
```
Copy ioncube loader to PHP modules Directory.

```sh
php -i | grep extension_dir
cp ioncube/ioncube_loader_lin_8.1.so /usr/lib64/php/modules 
sed -i '2 a zend_extension = "/usr/lib64/php/modules/ioncube_loader_lin_8.1.so"' /etc/php.ini
sed -i "s/max_execution_time = .*/max_execution_time = 300/" /etc/php.ini
```

<b> 2.d Install and run MariaDB</b>

The official Faveo installation uses MariaDB as the database system and **this is the only official system we support**. While Laravel technically supports PostgreSQL and SQLite, we can't guarantee that it will work fine with Faveo as we've never tested it. Feel free to read [Laravel's documentation](https://laravel.com/docs/database#configuration) on that topic if you feel adventurous.

Note: Currently Faveo supports only  MariaDB-10.6.

Create a new repo file /etc/yum.repos.d/mariadb.repo and add the below code changing the base url according to the operating system version and architecture.
```sh
nano /etc/yum.repos.d/mariadb.repo
```
```
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.6/centos73-amd64/
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
```
Note: The below steps only installs the package, but does not setup the database required by Faveo. This is done later in the instructions.

```sh
yum install MariaDB-server MariaDB-client
systemctl enable mysql.service
systemctl start mysql.service
```
Secure your MySql installation by executing the below command. Set Password for mysql root user by providing a strong password combination of Uppercase, Lowercase, alphanumeric and special symbols, remove anonymous users, disallow remote root login, remove the test databases and finally reload the privilege tables.

```sh
mariadb-secure-installation 
```

**phpMyAdmin(Optional):** Install phpMyAdmin. This is optional step. phpMyAdmin gives a GUI to access and work with Database

```sh
yum install -y phpmyadmin
```
At this point run the belove command to clear the yum cache.
```sh
yum clean all
```

Once the softwares above are installed:


<a id="3-upload-faveo" name="3-upload-faveo"></a>

### <strong>3. Upload Faveo</strong>
Please download Faveo Helpdesk from [https://store.faveohelpdesk.com](https://store.faveohelpdesk.com) and upload it to below directory

```sh
mkdir -p /var/www/faveo/
cd /var/www/faveo/
```
<b> 3.a Extracting the Faveo-Codebase zip file </b>

```sh
unzip "Filename.zip" -d /var/www/faveo
```

<a id="4setup-the-database" name="4setup-the-database"></a>

### <strong>4.Setup the database</strong>

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

<a id="5-configure-apache-webserver" name="5-configure-apache-webserver"></a>

### <strong>5. Configure Apache webserver</strong>

**a.** <b>Give proper permissions to the project directory by running:</b>

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

**b.** <b>Enable the rewrite module of the Apache webserver:</b>

Check whether the Module exists in Apache modules directory.

```sh
ls /etc/httpd/modules | grep mod_rewrite
```
Check if the module is loaded
```sh
grep -i LoadModule /etc/httpd/conf/httpd.conf | grep rewrite
```
If the output af the above command is blank then add the below line in /etc/httpd/conf/httpd.conf

```sh
LoadModule rewrite_module modules/mod_rewrite.so
```

Finally disable Directory Browsing on Apache, edit the httpd.conf and change Options Indexes FollowSymLinks to Options -Indexes +FollowSymLinks & AllowOverride value from none to All under <Directory /var/www/> section.

```sh
<Directory "/var/www">
    Options -Indexes +FollowSymLinks
    AllowOverride All 
    # Allow open access:
    Require all granted
</Directory>
```


**c.** <b>Configure a new faveo site in apache by doing:</b>

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

**d.** Apply the new `.conf` file and restart Apache. You can do that by running:

```sh
systemctl restart httpd.service
```


<a id="3-gui-faveo-installer" name="3-gui-faveo-installer"></a>


<a id="6configure-cron-job" name="6configure-cron-job"></a>

### <strong>6.Configure cron job</strong>

Faveo requires some background processes to continuously run. 
Basically those crons are needed to receive emails
To do this, setup a cron that runs every minute that triggers the following command `php artisan schedule:run`. Verify your php ececutable location and replace it accordingly in the below command.

Create a new `/etc/cron.d/faveo` file with:

```sh
echo "* * * * * apache /bin/php /var/www/faveo/artisan schedule:run 2>&1" | sudo tee /etc/cron.d/faveo
```


<a id="7redis-installation" name="7redis-installation"></a>

### <strong>7.Redis Installation</strong>

Redis is an open-source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.

This is an optional step and will improve system performance and is highly recommended.

[Redis installation documentation](/docs/installation/providers/enterprise/centos-redis)

<a id="8ssl-installation" name="8ssl-installation"></a>

### <strong>8.SSL Installation</strong>

Secure Sockets Layer (SSL) is a standard security technology for establishing an encrypted link between a server and a client. Let's Encrypt is a free, automated, and open certificate authority.

Faveo Requires HTTPS so the SSL is a must to work with the latest versions of faveo, so for the internal network and if there is no domain for free you can use the Self-Signed-SSL.

[Let’s Encrypt SSL installation documentation](/docs/installation/providers/enterprise/centos-apache-ssl)

[Self Signed SSL Certificate documentation](/docs/installation/providers/enterprise/self-signed-ssl-centos/)

<a id="9install-faveo" name="9install-faveo"></a>

### <strong>9.Install Faveo</strong>

At this point if the domainname is propagated properly with your server's IP you can open Faveo in browser just by entering your domainname.
You can also check the Propagation update by Visiting this site www.whatsmydns.net.

Now you can install Faveo via [GUI](/docs/installation/installer/gui) Wizard or [CLI](/docs/installation/installer/cli).

<a id="10final-step" name="10final-step"></a>

### <strong>10.Final step</strong>

The final step is to have fun with your newly created instance, which should be up and running to `http://localhost` or the domain you have configured Faveo with.

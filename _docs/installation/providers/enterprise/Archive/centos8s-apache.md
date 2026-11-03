---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/centos8s-apache/
redirect_from:
  - /theme-setup/
last_modified_at: 2020-06-09
toc: true
---
# Installing Faveo Helpdesk Freelancer, Paid and Enterprise on CentOS-8-Stream <!-- omit in toc -->

<img alt="CentOS-8-Stream OS Logo" src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Centos-logo-light.svg/300px-Centos-logo-light.svg.png" width="200"  />

Faveo can run on [CentOS-8-Stream ](https://www.centos.org/download/).

- [<strong>Installation steps:</strong>](#installation-steps)
    - [<strong>1.LAMP Stack Installation</strong>](#1lamp-installation)
    - [<strong>2.Update your Packages and install some utility tools</strong>](#2update-your-packages-and-install-some-utility-tools)
    - [<strong>3.Upload Faveo</strong>](#3upload-faveo)
    - [<strong>4.Setup the database</strong>](#4setup-the-database)
    - [<strong>5.Configure Apache webserver</strong>](#5configure-apache-webserver)
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
-   **MySQL 8.0+** or **MariaDB 10.6+**
-   **SSL** ,Trusted CA Signed or Slef-Signed SSL

<a id="1lamp-installation" name="1lamp-installation"></a>

### <strong>1.LAMP Stack Installation</strong>

Follow the [instructions here](https://github.com/teddysun/lamp)
If you follow this step, no need to install Apache, PHP, MySQL separetely as listed below

<a id="2update-your-packages-and-install-some-utility-tools" name="2update-your-packages-and-install-some-utility-tools"></a>

### <strong>2.Update your Packages and install some utility tools</strong>

Login as root user by typing the command below

```sh
sudo su
```
```sh
yum update -y && yum install unzip wget nano yum-utils curl openssl zip git -y
```

<strong>2.a.Install php-8.1 Packages </strong>



```sh
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
yum install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm

dnf module install php:remi-8.1 -y
yum -y install php php-cli php-common php-fpm php-gd php-mbstring php-pecl-mcrypt php-mysqlnd php-odbc php-pdo php-xml  php-opcache php-imap php-bcmath php-ldap php-pecl-zip php-soap php-redis
```
<strong>2.b.Install and run Apache</strong>
Install and Enable Apache Server

```sh
yum install -y httpd
systemctl start httpd
systemctl enable httpd
```



<strong>2.c.Setting Up ionCube</strong>
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

<strong>2.d.Install and run Mysql/MariaDB </strong>

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

**phpMyAdmin(Optional):** Install phpMyAdmin. This is optional step. phpMyAdmin gives a GUI to access and work with Database

```sh
yum install -y phpmyadmin
```
At this point run the belove command to clear the yum cache.
```sh
yum clean all
```


Once the softwares above are installed:


<a id="3upload-faveo" name="3upload-faveo"></a>

### <strong>3.Upload Faveo</strong>

Please download Faveo Helpdesk from [https://store.faveohelpdesk.com](https://store.faveohelpdesk.com) and upload it to below directory

```sh
mkdir -p /var/www/faveo/
cd /var/www/faveo/
```
**3.a.**<b>Extracting the Faveo-Codebase zip file</b>

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

<a id="5configure-apache-webserver" name="5configure-apache-webserver"></a>

### <strong>5.Configure Apache webserver</strong>

**5.a.** <b>Give proper permissions to the project directory by running:</b>

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

**5.b.** <b>Enable the rewrite module of the Apache webserver:</b>

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

**5.c.** <b>Configure a new faveo site in apache by doing:</b>

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

**5.d.** Apply the new `.conf` file and restart Apache. You can do that by running:

```sh
systemctl restart httpd.service
```

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

[Redis installation documentation](/docs/installation/providers/enterprise/centos8s-redis)

<a id="8ssl-installation" name="8ssl-installation"></a>

### <strong>8.SSL Installation</strong>

Secure Sockets Layer (SSL) is a standard security technology for establishing an encrypted link between a server and a client. Let's Encrypt is a free, automated, and open certificate authority.

Faveo Requires HTTPS so the SSL is a must to work with the latest versions of faveo, so for the internal network and if there is no domain for free you can use the Self-Signed-SSL.

[Let’s Encrypt SSL installation documentation](/docs/installation/providers/enterprise/centos8s-apache-ssl)

[Self Signed SSL Certificate documentation](/docs/installation/providers/enterprise/self-signed-ssl-centos/)

<a id="9install-faveo" name="9install-faveo"></a>

### <strong>9.Install Faveo</strong>

At this point if the domainname is propagated properly with your server's IP you can open Faveo in browser just by entering your domainname.
You can also check the Propagation update by Visiting this site www.whatsmydns.net.

Now you can install Faveo via [GUI](/docs/installation/installer/gui) Wizard or [CLI](/docs/installation/installer/cli).

<a id="10final-step" name="10final-step"></a>

###  <strong>10.Final step</strong>
The final step is to have fun with your newly created instance, which should be up and running to `http://localhost` or the domain you have configured Faveo with.

---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/php84-upgrade/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-02-05
last_modified_by: Mohammad_Asif
toc: true
title: Upgrade From PHP 8.2.x to PHP 8.4.x for Faveo
---

#  <!-- omit in toc -->

<img alt="PHP" src="https://media.daily.dev/image/upload/s--necFnRUa--/f_auto/v1716104784/posts/ou00RvLB7" width="200" />

---

This document will guide you to upgrade PHP version for Faveo Helpdesk from PHP 8.2.x to PHP 8.4.x on Ubuntu, Debian, Alma, Rocky, RHEL,Windows Server and on Shared Hosting (cPanel).



## Introduction

Faveo Helpdesk is now powered by <a href="https://laravel.com/docs/12.x" target="_blank" rel="noopener">Laravel 12</a> with full <a href="https://www.php.net/releases/8.4/en.php" target="_blank" rel="noopener">PHP 8.4</a> support. To make the most of the latest features, kindly update your PHP version by following the instructions below.


<strong>Choose your server OS: </strong>

  - [<strong>1. Ubuntu and Debian</strong>](#1ubuntu&debian)
   - [<strong>2. Alma, Rocky and RHEL</strong>](#2alma-rocky-and-rhel)
   - [<strong>3. Widows Servers</strong>](#3windows-servers)
   - [<strong>4. cPanel</strong>](#4cpanel)


Before proceeding further check your current PHP version. To find out which version of PHP you are currently using, run this in the Terminal or Windows command prompt. 

```sh
php -v
```

If you are running PHP 8.2.x, you can continue with this guide to upgrade to PHP 8.4.x

<a id="1ubuntu&debian" name="1ubuntu&debian"></a>

### <strong>1. Ubuntu and Debian</strong>



Type the following command to remove the existing PHP version.

```sh
sudo apt-get purge php8.2*
```
Press y and ENTER when prompted.

After uninstalling packages, it’s advised to run these two commands.
```sh
sudo apt-get autoclean
```
```sh
sudo apt-get autoremove
```

The PHP 8.4 binary packages are only available in the <a href="https://launchpad.net/~ondrej/+archive/ubuntu/php" target="_blank" rel="noopener">Ondřej Surý PPA repository</a>. This was already added while installing PHP 8.2, so we don't need to add it again.

### Install PHP 8.4

Update the repository cache by running the below command

```sh
sudo apt-get update
```

Install PHP 8.4 along with the necessary extensions required by Faveo Helpdesk.

```sh

apt install -y php8.4 libapache2-mod-php8.4 php8.4-mysql \
    php8.4-cli php8.4-common php8.4-fpm php8.4-soap php8.4-gd \
    php8.4-opcache  php8.4-mbstring php8.4-zip \
    php8.4-bcmath php8.4-intl php8.4-xml php8.4-curl  \
    php8.4-imap php8.4-ldap php8.4-gmp php8.4-redis \
    php8.4-memcached
```
Press Y and ENTER if prompted.

### Install and configure Ioncube 8.4 extension

Download the latest IonCube Loader.

```sh
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz 
```

```sh
tar -xvf ioncube_loaders_lin_x86-64.tar.gz
```

Copy the ioncube_loader_lin_8.4.so to PHP Extension directory.

```sh
cp ioncube/ioncube_loader_lin_8.4.so /usr/lib/php/20240924
```

### Update the PHP Configuration files

#### For Apache
```sh
sed -i '2 a zend_extension = "/usr/lib/php/20240924/ioncube_loader_lin_8.4.so"' /etc/php/8.4/apache2/php.ini
sed -i '2 a zend_extension = "/usr/lib/php/20240924/ioncube_loader_lin_8.4.so"' /etc/php/8.4/cli/php.ini
sed -i '2 a zend_extension = "/usr/lib/php/20240924/ioncube_loader_lin_8.4.so"' /etc/php/8.4/fpm/php.ini
```

#### For NGINX

```sh
sed -i '2 a zend_extension = "/usr/lib/php/20240924/ioncube_loader_lin_8.4.so"' /etc/php/8.4/cli/php.ini
sed -i '2 a zend_extension = "/usr/lib/php/20240924/ioncube_loader_lin_8.4.so"' /etc/php/8.4/fpm/php.ini
```

### Change php-fpm default settings 

```sh
sudo sed -i -e 's/^file_uploads =.*/file_uploads = On/' \
           -e 's/^allow_url_fopen =.*/allow_url_fopen = On/' \
           -e 's/^short_open_tag =.*/short_open_tag = On/' \
           -e 's/^memory_limit =.*/memory_limit = 256M/' \
           -e 's/^;cgi.fix_pathinfo=1.*/cgi.fix_pathinfo = 0/' \
           -e 's/^upload_max_filesize =.*/upload_max_filesize = 100M/' \
           -e 's/^post_max_size =.*/post_max_size = 100M/' \
           -e 's/^max_execution_time =.*/max_execution_time = 360/' \
           /etc/php/8.4/fpm/php.ini
```

### Change php-cli default settings 

```
sudo sed -i -e 's/^file_uploads =.*/file_uploads = On/' \
           -e 's/^allow_url_fopen =.*/allow_url_fopen = On/' \
           -e 's/^short_open_tag =.*/short_open_tag = On/' \
           -e 's/^memory_limit =.*/memory_limit = 256M/' \
           -e 's/^;cgi.fix_pathinfo=1.*/cgi.fix_pathinfo = 0/' \
           -e 's/^upload_max_filesize =.*/upload_max_filesize = 100M/' \
           -e 's/^post_max_size =.*/post_max_size = 100M/' \
           -e 's/^max_execution_time =.*/max_execution_time = 360/' \
           /etc/php/8.4/cli/php.ini
```

### Change php-apache default settings (For Apache only)

```
sudo sed -i -e 's/^file_uploads =.*/file_uploads = On/' \
           -e 's/^allow_url_fopen =.*/allow_url_fopen = On/' \
           -e 's/^short_open_tag =.*/short_open_tag = On/' \
           -e 's/^memory_limit =.*/memory_limit = 256M/' \
           -e 's/^;cgi.fix_pathinfo=1.*/cgi.fix_pathinfo = 0/' \
           -e 's/^upload_max_filesize =.*/upload_max_filesize = 100M/' \
           -e 's/^post_max_size =.*/post_max_size = 100M/' \
           -e 's/^max_execution_time =.*/max_execution_time = 360/' \
           /etc/php/8.4/apache2/php.ini
```



### Enable php-fpm 

#### For Apache
```
a2enconf php8.4-fpm
```

#### For Nginx

If you are using Faveo with nginx webserver, make the following change in faveo.conf file.

```
nano /etc/nginx/sites-available/faveo.conf
```

Change this line <code><b>fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;</b></code> to below to use php8.4-fpm.sock.

```
fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
```

### Restart Webserver

#### For Apache
```
systemctl restart php8.4-fpm
systemctl restart apache2
```


#### For Nginx
```
systemctl restart php8.4-fpm
systemctl restart nginx
```

---


<a id="2alma-rocky-and-rhel" name="2alma-rocky-and-rhel"></a>

### <strong>2. Alma, Rocky and RHEL</strong>

In Alma, Rocky and RHEL machines, we can simply upgrade from a lower version of PHP to a higher version by switching the Repository. 


<p class="notice--warning">
For RHEL you may come accorss with this error while installing php8.4 <code><b>This system is not registered with an entitlement server. You can use subscription-manager to register.</b></code>. To resolve this error <a href="https://access.redhat.com/solutions/253273" target="_blank" rel="noopener">follow this official documentation</a> of RHEL, if you don't have a Licensed RHEL server, do the following change in the plugin configuration file to disable plugin <code><b>vim /etc/yum/pluginconf.d/subscription-manager.conf</b></code> change <code><b>enabled=0</b></code>
</p>


Run the below commands to disable PHP 8.2 and enable PHP 8.4 Remi repo.

```
sudo dnf module reset php:remi-8.2 -y
sudo dnf module enable php:remi-8.4 -y
```

Now run the below command to update to PHP 8.4

```
sudo yum update -y
```

### Install and configure IonCube 8.4 extension

```
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar xfz ioncube_loaders_lin_x86-64.tar.gz
```

Copy the ioncube_loader_lin_8.4.so to PHP Extension directory.

```
cp ioncube/ioncube_loader_lin_8.4.so /usr/lib64/php/modules
```

Update the PHP configuration file

```
sed -i 's:ioncube_loader_lin_8.4.so:ioncube_loader_lin_8.4.so:g' /etc/php.ini
sed -i "s/max_execution_time = .*/max_execution_time = 300/" /etc/php.ini
```

### Restart php-fpm

```
systemctl restart php-fpm 
```

### Restart Webserver

For Apache
```
sudo systemctl restart httpd
```


For Nginx
```
sudo systemctl restart nginx
```

---

<a id="3windows-servers" name="3windows-servers"></a>

### <strong>1. Windows Servers</strong>

-   <a href="https://windows.php.net/downloads/releases/archives/" target="_blank" rel="noopener">Click Here</a> to download php 8.4.9 NTS 64bit file. Extract the zip file & rename it to <code><b>php8.4</b></code>. Now move the renamed <code><b>php8.4</b></code> folder to <code><b>C:\php8.4</b></code>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/GUI-images/php84-a.png" alt="" style=" width:400px ; height:80px ">

-   Open <code><b>php8.4</b></code> folder, find <code><b>php.ini-development</b></code> & rename it to <code><b>php.ini</b></code> to make it php configuration file.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/phpconfig.png?raw=true" alt="" style=" width:400px ; height:230px ">

-   Open <code><b>php.ini</b></code> using Notepad++, add the below lines at the end of this file & save the file:

Required configuration changes for Faveo Helpdesk.

```
error_log=C:\Windows\temp\PHP84x64_errors.log
upload_tmp_dir="C:\Windows\Temp"
session.save_path="C:\Windows\Temp"
cgi.force_redirect=0
cgi.fix_pathinfo=1
fastcgi.impersonate=1
fastcgi.logging=0
max_execution_time=300
date.timezone=Asia/Kolkata
extension_dir="C:\php8.4\ext\"
upload_max_filesize = 100M
post_max_size = 100M
memory_limit = 256M
```

Uncomment these extensions.

```
extension=bz2
extension=curl
extension=fileinfo
extension=gd2
extension=imap
extension=ldap
extension=mbstring
extension=mysqli
extension=soap
extension=sockets
extension=sodium
extension=openssl
extension=pdo_mysql
```
### Update the Environment Variable for PHP Binary
- Right click on This PC, go to Properties > Advanced System Settings > Environment Variables.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/env1.png" alt="" style=" width:500px ; height:200px ">

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/env2.png" alt="" style=" width:500px ; height:300px ">

- Now click on Path > Edit > New & add copied path C:\php8.4\ here and click OK in all 3 tabs.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/envpath.png" alt="" style=" width:500px ; height:300px ">

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/GUI-images/php84-b.png" alt="" style=" width:500px ; height:300px ">

### Enable cacert.pem File in PHP Configuration File

-   <a href="https://curl.se/ca/cacert.pem" target="_blank" rel="noopener">Click Here</a> to download <code><b>cacaert.pem</b></code> file. This is required to avoid the “cURL 60 error” which is one of the Probes that Faveo checks.



- Copy the <code><b>cacert.pem</b></code> file to <code><b>C:\php8.4</b></code> path.

- Edit the <code><b>php.ini</b></code> located in <code><b>C:\php8.4</b></code>, Uncomment <code><b>curl.cainfo</b></code> and add the location of cacert.pem to it as below:

```
curl.cainfo = "C:\php8.4\cacert.pem"
```

### Install Ioncube Loader

-   <a href="https://downloads.ioncube.com/loader_downloads/ioncube_loaders_win_nonts_vc17_x86-64.zip" target="_blank" rel="noopener">Click Here</a> to download Ioncube Loader zip file, Extract the zip file.

- Copy the <code><b>ioncube_loader_win_8.4.dll</b></code> file from extracted Ioncube folder and paste it in the PHP extension directory <code><b>C:\php8.4\ext.</b></code>

- Add the below line in your php.ini file at the starting to enable Ioncube.

```
zend_extension = "C:\php8.4\ext\ioncube_loader_win_8.4.dll"
```


### Create FastCGI Handler Mapping


- Open Server Manager, locate <code><b>Tools</b></code> on the top right corner  of the Dashboard, Open <code><b>Internet Information Services (IIS) Manager</b></code>.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/iis.png?raw=true" alt="" style=" width:550px ; height:120px ">


- Now in the Left Panel of the IIS Manager select the server then you will find the <code><b>Handler Mappings</b></code> it will populate the available options to configure.


<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/handlermap.png" alt="" style=" width:400px ; height:250px ">


- Open <code><b>Handler Mappings</b></code>, Select <code><b>FastCGI</b></code> Click on <code><b>Edit</b></code> in the Right Panel and update <code><b>c:\php8.4\php-cgi.exe</b></code> path.

- Click on <code><b>OK</b></code> and restart the IIS server once.

### Install PHP Redis 8.4 Extension


<a href="https://pecl.php.net/package/redis/6.1.0/windows" target="_blank" rel="noopener">Click Here</a> to download PHP 8.4 NTS x64 zip file.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/GUI-images/php84-c.png" style=" width:400px ; height:250px ">

- Unzip the php-redis zip file, a folder will be created, go inside the folder, copy the *php_redis.dll* file and paste it in *C:\php8.4\ext.* *(C:\php\ext incase of Apache WebServer).* 
- Now enable php redis extension in *php.ini* configuration located in *C:\php8.4.*  *(C:\php incase of Apache WebServer).*

```
extension=php_redis.dll
```
- Now go to Server Manager, open IIS Server and restart it. *(or restart Apache incase of Apache WebServer)*

---

<a id="4cpanel" name="4cpanel"></a>

### <strong>4. cPanel</strong>


- To enable PHP 8.4 in cPanel the PHP version has to be installed in the server this is done through <code><b>WHM</b></code>, This can be done by contacting your Hosting Provider.

- After installing PHP 8.4 on the server we need to change the php version for the faveo domain, follow the below steps to do so.

- Login to the cPanel and search for <code><b>MultiPHP Manager</b></code>  as shown in the below snap.

<img alt="" src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/GUI-images/multi-php-manager.png?raw=true"/>

- After opening the MultiPHP Manager select the *"checkbox"* of the domain, change the PHP version from the drop-down to PHP 8.4 and click <code><b>Apply</b></code> as shown in the below snap.

<img alt="" src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/GUI-images/php84-d.png"/>

> **Note:** If you are not able to find the PHP version in the drop-down then it is not installed on the server Please contact your Hosting provider and install PHP-8.4 and try again.



- Once PHP 8.4 is updated to the domain we need to update PHP version in cron as well to do so, search for <code><b>Cron Jobs</b></code> in the Cpanel search and click on it to open the cron jobs page as below.

<img alt="" src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/GUI-images/cron-search.png?raw=true"/>


<img alt="" src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/GUI-images/Screenshot%20from%202022-11-28%2011-30-14.png?raw=true"/>

- Once we get to the cronjobs page we need to edit the cron to use the php8.4, to do so we need to edit the cron job to use the domain-specific php path and save as shown in the below snap with the below commands.

Change This
 ```
/usr/local/bin/ea-php8.2 
```

<img alt="" src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/GUI-images/php84-e.png"/>

To This
```
/usr/local/bin/ea-php8.4
```

<img alt="" src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/GUI-images/php84-f.png"/>


---
---
---


<div style="display: flex; align-items: center;">
    <a href="https://www.linkedin.com/in/mohammadasifdevops">
        <img src="https://1.gravatar.com/avatar/c0d70118d1dcf472a3b428453e49e1723127a1d83d8aeb4fb9d7b53a15860d13?size=128" alt="Author Image" style="border-radius: 50%; width: 50px; height: 50px; margin-right: 10px;">
    </a>
    <div style="text-align: left;">
        <div style="line-height: 1;">Authored by:</div>
      <div style="line-height: 1;"> <b>Mohammad Asif</b> </div>
			<div style="line-height: 1;">Associate DevOps Engineer</div>
    </div>
</div>

---
---
---



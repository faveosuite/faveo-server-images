---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/memcached/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-04-12
last_modified_by: Mohammad_Asif
toc: true
title: Installing Memcached for Faveo
---
<img alt="Memcached" src="https://cdn.icon-icons.com/icons2/2699/PNG/512/memcached_logo_icon_170963.png" width="200"  />


- [<strong>Introduction :</strong>](#introduction-) 
    - [<strong>1. Debian and Derivatives</strong>](#1-debian-and-derivatives)
    - [<strong>2. Red Hat and Derivatives</strong>](#2-redhat-and-derivatives)
    - [<strong>3. Windows Server</strong>](#3-windows-server)

<a id="introduction-" name="introduction-"></a>

## <strong>Introduction:</strong>

Memcached is free & open source, high-performance, distributed memory object caching system, generic in nature, but intended for use in speeding up dynamic web applications by alleviating database load. Memcached is an in-memory key-value store for small chunks of arbitrary data (strings, objects) from results of database calls, API calls, or page rendering.

---

<a id="1-debian-and-derivatives" name="1-debian-and-derivatives"></a>

### <strong>Debian and Derivatives</strong>

Debian and Derivates include:
 
a. Debian 11 (Bullseye) 

b. Debian 12 (Bookworm)  

c. Ubuntu 22.04 (Jammy Jellyfish)

d. c. Ubuntu 24.04 (Noble Numbat) 


#### Installing PHP extension

```
apt-get install -y libapache2-mod-php8.4 php8.4-memcached
```

#### Installing Memcached

```
sudo apt update
```

```
sudo apt-get install -y memcached libmemcached-tools
```

```
sudo systemctl start memcached
sudo systemctl enable memcached
```

```
sudo systemctl restart apache2
```

Verify that Memcached is currently bound to the local IPv4 127.0.0.1 interface and listening only for TCP connections by using the ss command:

```
sudo ss -plunt
```

You should receive output like the following:

```sh
Output
Netid      State       Recv-Q      Send-Q           Local Address:Port             Peer Address:Port      Process                                         
. . .
tcp        LISTEN      0           1024                 127.0.0.1:11211                 0.0.0.0:*          users:(("memcached",pid=8889,fd=26))
. . .
```

#### Adding an Authenticated User
You will need to install the *sasl2-bin* package, which contains administrative programs for the SASL (Simple Authentication and Security Layer) user database. This tool will allow you to create an authenticated user or users. Run the following command to install it:

```
sudo apt install sasl2-bin
```

Next, create the directory and file that Memcached will check for its SASL configuration settings using the mkdir command:

```
sudo mkdir -p /etc/sasl2
```

Now create the SASL configuration file using nano or your preferred editor:

```
sudo nano /etc/sasl2/memcached.conf
```

Add the following lines:

```
log_level: 5
mech_list: plain
sasldb_path: /etc/sasl2/memcached-sasldb2
```

Now you will create a SASL database with user credentials. You’ll use the *saslpasswd2* command with the -c flag to create a new user entry in the SASL database.

```
sudo saslpasswd2 -a memcached -c -f /etc/sasl2/memcached-sasldb2 faveo
```

Finally, give the memcache user and group ownership over the SASL database with the following chown command:

```
sudo chown memcache:memcache /etc/sasl2/memcached-sasldb2
```

Restart the Memcached service:

```
sudo systemctl restart memcached
```

---


<a id="2-redhat-and-derivatives" name="2-redhat-and-derivatives"></a>

### <strong>2. Red Hat and Derivatives</strong>

Red Hat and Derivatives include: 

a. Alma 8 

b. Alma 9 

c. Rocky 8 

d. Rocky 9 

e. RHEL 8 

f. RHEL 9


#### Installing PHP extension

```
yum -y install php-pecl-memcached php-pecl-memcache -y
```

#### Installing Memcached

```
sudo dnf update -y
```

```
sudo dnf install memcached -y
```

```
sudo yum groupinstall 'Development Tools'
```

```
wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
```

```
tar -zxvf libmemcached-1.0.18.tar.gz
```

```
cd libmemcached-1.0.18
```

```
./configure
```

```
nano clients/memflush.cc
```
Replace all the occurrences of *opt_servers == false* 

```
// Change this line:
// if (opt_servers == false)

// To:
if (!opt_servers)
```

```
make
```

```
sudo make install
```


```
sudo systemctl start memcached
sudo systemctl enable memcached
```

```
systemctl restart httpd.service
```

Verify that Memcached is currently bound to the local IPv4 127.0.0.1 interface and listening only for TCP connections by using the ss command:

```
sudo ss -plunt
```

You should receive output like the following:

```sh
Output
Netid      State       Recv-Q      Send-Q           Local Address:Port             Peer Address:Port      Process                                         
. . .
tcp        LISTEN      0           1024                 127.0.0.1:11211                 0.0.0.0:*          users:(("memcached",pid=8889,fd=26))
. . .
```

#### Adding an Authenticated User

Now we can download two packages that will allow us to work with the Cyrus SASL Library and its authentication mechanisms, including plugins that support PLAIN authentication schemes. These packages, cyrus-sasl-devel and cyrus-sasl-plain, will allow us to create and authenticate our user. Install the packages by typing:

```
sudo yum install cyrus-sasl-devel cyrus-sasl-plain
```

Next, we will create the directory and file that Memcached will check for its SASL configuration settings:

```
sudo mkdir -p /etc/sasl2
```

```
sudo nano /etc/sasl2/memcached.conf
```

Add the following to the SASL configuration file:

```
mech_list: plain
log_level: 5
sasldb_path: /etc/sasl2/memcached-sasldb2
```

Now you will create a SASL database with user credentials. You’ll use the saslpasswd2 command with the -c flag to create a new user entry in the SASL database.

```
sudo saslpasswd2 -a memcached -c -f /etc/sasl2/memcached-sasldb2 faveo
```

Finally, give the memcache user and group ownership over the SASL database with the following chown command:

```
sudo chown memcached:memcached /etc/sasl2/memcached-sasldb2
```

Restart the Memcached service:

```
sudo systemctl restart memcached
```

---


<a id="3-windows-server" name="3-windows-server"></a>

### <strong>3. Windows Server</strong>

#### Installing PHP extension

<a href="https://pecl.php.net/package/memcached/3.4.0/windows" target="_blank" rel="noopener">Click Here</a> to download PHP 8.4 x64 extension zip file (NTS or TS depending on the PHP type) for Memcached.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/GUI-images/memcached.png" alt="" style=" width:400px ; height:150px ">

- Unzip the downloaded zip file *(php_memcached-3.2.0rc2-8.4-nts-vs16-x64.zip file or php_memcached-3.4.0.8.4-nts-vs17-x64.zip file)*.

- Copy the *libmemcached.dll* file from the extracted zip content and paste it in C:\php8.4\ext. (C:\php\ext incase of Apache WebServer).

- Also copy *php_memcached.dll* and *libhashkit.dll* and paste it in C:\windows.


- Now enable php memcached extension in php.ini configuration located in C:\php8.4. (C:\php incase of Apache WebServer).

```
extension=php_memcached
```

- Now restart the IIS or Apache

#### Installing Memcached

<a href="https://static.runoob.com/download/memcached-win64-1.4.4-14.zip" target="_blank" rel="noopener">Click Here</a> to download the stable version of Memcached for windows Server.

- Unzip it in some hard drive folder. For example *C:\memcached*

- There will be memcached.exe file in the unzipped folder.

- Open a command prompt (need to be opened as administrator).

Run the below command to install to install Memcached. 

```
c:\memcached\memcached.exe -d install
```

For start and stop run following command line

To Start

```
c:\memcached\memcached.exe -d start
```

To Stop

```
c:\memcached\memcached.exe -d stop
```

To check Status

```
tasklist | findstr "memcached.exe"
```























---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/redis-windows/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-02-26
last_modified_by: Mohammad_Asif
toc: true
title: Install and configure Redis for Faveo on Windows Server
---


<img alt="Windows" src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Windows_logo_and_wordmark_-_2021.svg/250px-Windows_logo_and_wordmark_-_2021.svg.png" width="200"  />   


<img alt="Redis" src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Logo-redis_%28old%29.svg/3840px-Logo-redis_%28old%29.svg.png" width="200"  /> 

This guide explains how to configure Redis specifically for running Faveo Helpdesk Enterprise on Windows servers.

 Redis is used by Faveo to improve ticket queue processing, background jobs, and overall application performance.

 > This documentation is intended only for administrators setting up Faveo Helpdesk and does not cover general Redis installation outside of the Faveo environment.


<b>1. Install PHP 8.4 Redis Extension </b>

<a href="https://pecl.php.net/package/redis/6.1.0/windows" target="_blank" rel="noopener">Click Here</a> to download PHP 8.4 NTS x64 zip file.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/GUI-images/php84-c.png" style=" width:400px ; height:250px ">

- Unzip the php-redis zip file, a folder will be created, go inside the folder, copy the *php_redis.dll* file and paste it in *C:\php8.4\ext.* *(C:\php\ext incase of Apache WebServer).* 
- Now enable php redis extension in *php.ini* configuration located in *C:\php8.4.*  *(C:\php incase of Apache WebServer).*

```
extension=php_redis.dll
```
- Now go to Server Manager, open IIS Server and restart it. *(or restart Apache incase of Apache WebServer)*

---

<b>2. Install Redis </b>

<a href="https://github.com/tporadowski/redis/releases" target="_blank" rel="noopener">Click Here</a> to download last recent release of Redis.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/redis2.png?raw=true" style=" width:400px ; height:250px ">

Execute the installer to perform the required installation steps
- Accept the terms in the License agreement.
- Add the Redis installation folder to the PATH environment variable.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/redis3.png?raw=true" style=" width:400px ; height:250px ">

- Set the Max Memory Limit from 300-500 MB.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/redis4.png?raw=true" style=" width:400px ; height:250px ">

The Redis installation is finished. 

- Now go to *windows menu > Run > Services*, This can be done by  following shortcut *win+R*, type *services.msc* & click *OK*, it will open a new Services tab. 
- Find *Redis* right click on it & go to *Properties > Recovery* a new tab will open. 

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/redis5.png?raw=true" style=" width:400px ; height:250px ">

- Change *first failure, second failure & subsequent failure* from Take No Action to *Restart the Service* & click *OK*. 

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/redis6.png?raw=true" style=" width:400px ; height:250px ">

Redis has been successfully installed, this can be confirmed in Command Prompt by typing *redis-cli*, a loopback address will be shown in the Command Prompt.

---

## Install WinSW Service

Download WinSW Config File.
- [IIS](https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/redis-config-file/WinSW-IIS.zip) 
- [Apache](https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/redis-config-file/WinSW-Apache.zip)

Unzip the <code>WinSW-{version}.zip</code> file.

Go inside the folder & copy the WinSW folder & paste it in C:\ .

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/redis19.png" style=" width:400px">

---

<b>4. General Instructions to Create WinSW Services</b>

**NOTE: These are the General Instructions to create WinSW Services for Faveo. The actual ones are listed below as Faveo-Mail-Worker, Faveo-Recurring, Faveo-Reports, Faveo-Notifications & Faveo Deactivation.**

Go to Command Prompt and configure WinSW-SERVICE by typing the following commands. (Faveo-Mail-Worker, Faveo-Recurring, Faveo-Reports, Faveo-Notifications & Faveo-Deactivation are to be configured in actual).


- Install your application as a service using the following command:

```
winsw install
```
This will register your application as a Windows service.

#### Verifying the Installation

After installing the service, you can use standard service management commands to control it. For example:

- Start the service:

```
winsw start
```

- Checks the status of the service.

```
winsw status
```

- Stop the service:

```
winsw stop
```

- Restart the service:

```
winsw restart
```
#### Uninstalling a Service

If you need to remove the service:

Uninstall the service using the following command:

```
winsw uninstall
```


---
**Follow the below steps to create WinSW Services for Faveo-Mail-Worker, Faveo-Recurring, Faveo-Reports, Faveo-Notifications & Faveo Deactivation.**


- **FAVEO WORKER**

Open a Command Prompt window with administrator privileges.

Navigate to the directory containing the WinSW executable and your application files using the cd command.

```
cd C:\WinSW\Faveo-Mail-Worker
```
Install your application as a service using the following command:

```
winsw install
```

Start the service:

```
winsw start
```

---
- **FAVEO RECURRING**

Open a Command Prompt window with administrator privileges.

Navigate to the directory containing the WinSW executable and your application files using the cd command.
```
cd C:\WinSW\Faveo-Recurring
```
Install your application as a service using the following command:

```
winsw install
```

Start the service:

```
winsw start
```
---
- **FAVEO REPORTS**

Open a Command Prompt window with administrator privileges.

Navigate to the directory containing the WinSW executable and your application files using the cd command.

```
cd C:\WinSW\Faveo-Reports
```
Install your application as a service using the following command:

```
winsw install
```

Start the service:

```
winsw start
```

---
- **FAVEO NOTIFICATIONS**

Open a Command Prompt window with administrator privileges.

Navigate to the directory containing the WinSW executable and your application files using the cd command.

```
cd C:\WinSW\Faveo-Notifications
```
Install your application as a service using the following command:

```
winsw install
```

Start the service:

```
winsw start
```

---
- **FAVEO DEACTIVATYE AGENTS**

Open a Command Prompt window with administrator privileges.

Navigate to the directory containing the WinSW executable and your application files using the cd command.

```
cd C:\WinSW\Faveo-Deactivation
```
Install your application as a service using the following command:

```
winsw install
```

Start the service:

```
winsw start
```

Open service manager and check status of all the services configured by WinSW.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/redis20.png" style=" width:400px">

---
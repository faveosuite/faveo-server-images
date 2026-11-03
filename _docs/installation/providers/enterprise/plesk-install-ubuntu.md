---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/plesk-ubuntu/
redirect_from:
  - /theme-setup/
last_modified_at: 2023-11-3
last_modified_by: TamilSelvan_M
toc: true
title: Faveo Installation on Ubuntu with Plesk Panel
---

<style>p>code, a>code, li>code, figcaption>code, td>code {background: #dedede;}</style>

<img alt="Wamp" src="https://contabo.com/blog/wp-content/uploads/2019/11/Plesk-OBSIDIAN-logo_positive-1024x341.png" width="200"  /> 

[<strong>Faveo Installation on Windows with Xampp Server</strong>](#Faveo-Installation-on-Windows-with-Xampp-Server)

- [<strong>Installation steps:</strong>](#installation-steps)

  - [<strong> 1. Plesk Installation </strong>](#1)
  - [<strong> 2. Adding Domains </strong>](#2)
  - [<strong> 3. Configure the PHP 8.1 </strong>](#3)
  - [<strong> 4. Setup the database </strong>](#6)
  - [<strong> 5. Scheduling Tasks </strong>](#7)
  - [<strong> 6. Redis Installation </strong>](#8)
  - [<strong> 7. SSL Installation </strong>](#9)
  - [<strong> 8. Install Faveo </strong>](#10)

<a id="1" name="1"></a>
## 1. Plesk Installation

- Follow the [instructions here](https://www.plesk.com/blog/various/install-plesk-linux/)

<a id="2" name="2"></a>
## 2. Adding Domains

- Go to <code><b>Websites & Domains</b></code>, click <code><b>Add Domain</b></code> and follow on-screen instructions.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/add-domain.png" alt="" style=" width:600px">

- Click <code><b>Add Domain</b></code>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/new-domain.png" alt="" style=" width:600px">

The new domain name is now shown in the list at the bottom of the screen.

### To upload a website using File Manager:

- Download the Faveo Helpdesk from [https://store.faveohelpdesk.com](https://store.faveohelpdesk.com)

Go to <b>Websites & Domains > domain name > Files</b>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/upload-Faveo-zip.png" alt="" style=" width:600px">

- Click the <code><b>httpdocs</b></code> folder to open it, click <code><b>Upload File</b></code>, select the archive file, and click <code><b>Open</b></code>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/Extract-zip.png" alt="" style=" width:600px">

- Once the file has been uploaded, click the <code><b>checkbox</b></code> next to it and select the <code><b>Extract Files</b></code> option.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/Extract-files.png" alt="" style=" width:600px">


<a id="3" name="3"></a>
## 3. Configure the PHP 8.1

### 3.a. Switch PHP Versions

Step 1: In Plesk, go to <code><b>Tools & Settings</b></code> and click <code><b>Updates</b></code> (under Plesk).

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/updates.png" alt="" style=" width:600px">

Step 2: On the Updates and Upgrades page, click <code><b>Add/Remove Components</b></code>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/add-remove-components.png" alt="" style=" width:600px">

Step 3: On the Add/Remove Components page, expand: 

- <b>Web hosting > PHP interpreter versions</b> section, if this is a Linux server.

- Select required PHP versions for installation/uninstallation and click <code><b>Continue</b></code>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/install-php8-1.png" alt="" style=" width:600px">

Step 4: Go to <b>Websites & Domains > Hosting Settings > PHP version</b>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/php-version.png" alt="" style=" width:600px">

Step 5: Now select the <code><b>PHP Version 8.1.X</b></code>, then scroll down and press <code><b>OK</b></code>:

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/change-php-version.png" alt="" style=" width:600px">

### 3.b. Setting Up ionCube

Go to <b>Tools & Settings > PHP Settings</b>

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/php-settings.png" alt="" style=" width:600px">

Click on the required PHP handler, for example, <code><b>8.1.X FPM application</b></code>

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/fpm-application.png" alt="" style=" width:600px">

Go to <code><b>Manage PECL Packages</b></code>

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/pecl-packages.png" alt="" style=" width:600px">

Search <code><b>"ioncube"</b></code> and click <code><b>install</b></code> the ioncube loader

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/pecl-installer.png" alt="" style=" width:600px">


### 3.c. Install wkhtmltopdf

Wkhtmltopdf is an open source simple and much effective command-line shell utility that enables user to convert any given HTML (Web Page) to PDF document or an image (jpg, png, etc).

It uses WebKit rendering layout engine to convert HTML pages to PDF document without losing the quality of the pages. Its is really very useful and trustworthy solution for creating and storing snapshots of web pages in real-time.

```
apt-get -y install wkhtmltopdf
```


<a id="4" name="4"></a>
## 4. Setup the database

Click <code><b>Databases</b></code> from the left-side menu to <b>create a new database</b>

Click the <code><b>Add Database</b></code> button.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/add-database.png" alt="" style=" width:600px">

Fill out the details for the new database

- Provide the name of the new database.

- Select the correct server type (MySQL or MariaDB) from the Database server dropdown.

- You may keep the Related site's default value.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/add-a-database.png" alt="" style=" width:600px">

Once done with the database name, you will need to create the database user. Fill out the details for the Users.

If you want this new user to have access to all databases within your domain, you may want to put a checkmark on User has access to all databases within the selected subscription.

Click <code><b>OK</b></code>.

A confirmation will be displayed, and your new database is now added under your domain name.

<a id="5" name="5"></a>
## 5. Scheduling Tasks

go to <b>Tools & Settings > Scheduled Tasks (Cron jobs) > Add Task</b>. 

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/scheduled-tasks.png" alt="" style=" width:600px">

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/add-task.png" alt="" style=" width:600px">

Fill in the Command text field with the cron command

Pick a editor of your choice copy the following and replace <code><b>"–DOMAINNAME–"</b></code> 

```bash
/opt/plesk/php/8.1/bin/php /var/www/vhosts/"–DOMAINNAME"–/httpdocs/artisan schedule:run 2>&1
```

Click <code><b>Add task</b></code> and set specify Run parameter to <code><b>Cron style</b></code>.

Fill in the Run text field with cron-style time syntax

```
*****
```

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/schedule-a-task.png" alt="" style=" width:600px">


<a id="6" name="6"></a>
## 6. Redis Installation

Redis is an open-source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.

This is an optional step and will improve system performance and is highly recommended.

[Redis installation documentation](/docs/installation/providers/enterprise/plesk-redis)


<a id="7" name="7"></a>
## 7. SSL Installation

### Let's Encrypt

- Go to <b>Websites & Domains > domain name</b> and click <code><b>SSL/TLS Certificates</b></code>:

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/SSLTLS-Certificates.png" alt="" style=" width:600px">

- At the bottom of the page, click <code><b>Install</b></code> in the section <b>More options > Install</b> a free basic certificate provided by Let's Encrypt:

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/install-ssl.png" alt="" style=" width:600px">

Select the desired options for the certificate to be issued. We recommend enabling the checkboxes:

- Secure the domain name
- Include a "www" subdomain for the domain and each selected alias
- Secure webmail on this domain
- Assign the certificate to mail domain

Note: The specified Email address will be used to receive important notifications and warnings about the certificate sent by Let's Encrypt. Plesk by default takes the email from the owner of the domain to secure.

- Click <code><b>Get it free</b></code>

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/plesk-images/install-ssl-1.png" alt="" style=" width:600px">

<a id="8" name="8"></a>
## 8. Install Faveo

<a id="9Install-Faveo" 
name="9Install-Faveo"></a>

Now you can install Faveo via [GUI](/docs/installation/installer/gui) Wizard


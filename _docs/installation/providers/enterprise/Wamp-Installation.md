---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/wamp-windows/
redirect_from:
  - /theme-setup/
last_modified_at: 2024-11-12
last_modified_by: Mohammad_Asif
toc: true
title: Faveo Installation on Windows with Wamp Server
---

<style>p>code, a>code, li>code, figcaption>code, td>code {background: #dedede;}</style>

<img alt="Wamp" src="https://i.pinimg.com/originals/69/78/47/697847ca00eef7069db9aef07c602389.png" width="200"  /> 

[<strong>Faveo Installation on Windows with Wamp Server</strong>](#Faveo-Installation-on-Windows-with-Wamp-Server)

- [<strong>Installation steps:</strong>](#installation-steps)

  - [<strong> 1.Download and Install WampServer </strong>](#1)
  - [<strong> 2. Upload Faveo </strong>](#2)
  - [<strong> 3. Setting up the Database </strong>](#3)
  - [<strong> 4. Install Ioncube Loader </strong>](#4)
  - [<strong> 5. Install wkhtmltopdf </strong>](#5)
  - [<strong> 6. Configure the PHP 8.4 </strong>](#6)
  - [<strong> 7. Install Redis Extension </strong>](#7)
  - [<strong> 8. Cron in Task Scheduler </strong>](#8)
  - [<strong> 9. Self-Signed SSL </strong>](#9)
  - [<strong> 10. Install Faveo </strong>](#10)

  
<a id="1" name="1"></a>
## 1. Download and Install WampServer

- <b>Download and Install WampServer with PHP 8.4:</b> If WampServer has been updated to include PHP 8.4, you can start by downloading and installing the latest version of WampServer from their official website.
[Click here](https://sourceforge.net/projects/wampserver/files/WampServer%203/WampServer%203.0.0/wampserver3.3.0_x64.exe/download)

- <b>Switch PHP Versions:</b> After installing WampServer with PHP 8.4, you can switch between different PHP versions using the WampServer icon in your system tray:

- Left-click on the WampServer icon in the system tray to open the menu.
Hover your mouse over "PHP," and you should see a list of available PHP versions.
Select PHP 8.4 (if available) from the list.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/php-version.png" alt="" style=" width:500px">


<a id="2" name="2"></a>
## 2. Upload Faveo
- Download the Faveo Helpdesk from <b>[https://billing.faveohelpdesk.com](https://billing.faveohelpdesk.com)</b> and upload it to the below directory.

```
C:\wamp64\www
```

<a id="3" name="3"></a>
## 3. Setting up the Database

- Visit <b>[http://localhost/phpmyadmin/](http://localhost/phpmyadmin/)</b> from browser to log on the database management panel.

- Once you are in phpMyAdmin, you can create a new database by following these steps:

- Click on the "Databases" tab in the top menu.

- In the "Create database" section, enter a name for your new database in the "Database name" field.

- Click the "Create" button.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/phpmyadmin.png" alt="" style=" width:500px">

- Your new database should now be created.


<a id="4" name="4"></a>
##  4. Install Ioncube Loader

[Click Here](https://downloads.ioncube.com/loader_downloads/ioncube_loaders_win_vc16_x86-64.zip) to download IonCube Loader zip file.

- Step 1: Extract the IonCube Loader file downloaded.

- Step 2: Copy the <code><b>ioncube_loader_win_8.4.dll</b></code> file and paste it into the PHP extensions directory <code><b>C:\wamp64\bin\php\php8.4.13\ext</b></code>.

- Step 3: Copy the “loader-wizard.php” from the extracted Ioncube folder and paste it into the <code><b>C:\wamp64\www</b></code>.

- Step 4: Edit the <code><b>C:\wamp64\bin\php\php8.4.13\phpForApache.ini</b></code> file and below the last line enter the path to the extension within the <code><b>zend_extension</b></code> parameter:

```
zend_extension = "C:\wamp64\bin\php\php8.4.13\ext\ioncube_loader_win_8.4.dll"
```
- Step 5: Run the below URL to verify the ionCube Installation.
- Note: If you didn’t get the below output try restarting the Apache Server.

```
http://127.0.0.1\loader-wizard.php
```

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache32.png" alt="" style=" width:500px ; height:150px ">


<a id="5" name="5"></a>
## 5. Install wkhtmltopdf

Wkhtmltopdf is an open source simple and much effective command-line shell utility that enables user to convert any given HTML (Web Page) to PDF document or an image (jpg, png, etc). It uses WebKit rendering layout engine to convert HTML pages to PDF document without losing the quality of the pages. It is really very useful and trustworthy solution for creating and storing snapshots of web pages in real-time.

-   <a href="https://wkhtmltopdf.org/downloads.html" target="_blank" rel="noopener">Click Here</a> to download 64-bit wkhtmltopdf-0.12.6-1.exe installer file.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/wkhtmltopdf.png" alt="" style=" width:400px ; height:250px ">

- Run the downloaded <code><b>wkhtmltopdf-0.12.6-1.exe installer</b></code>.

- Click <code><b>I Agree</b></code> on the license agreement screen.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/wkhtmltopdf1.png" alt="" style=" width:400px ; height:250px ">

- Specify the installation destination folder or leave it as default location and click <code><b>Install</b></code>

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/wkhtmltopdf2.png" alt="" style=" width:400px ; height:250px ">

- When the installation is complete, click the <code><b>Close</b></code> button.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/wkhtmltopdf3.png" alt="" style=" width:400px ; height:250px ">

- Now copy <code><b>wkhtmltox.dll</b></code> located at <code><b>C:\Program Files\wkhtmltopdf\bin</b></code> and paste it in <code><b>C:\wamp64\bin\php\php8.4.13\ext</b></code>

- Update the Environment variable for <code><b>wkhtmltopdf</b></code>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/envwkhtml.png" alt="" style=" width:400px ; height:250px ">

<a id="6" name="6"></a>
## 6. Configure the PHP 8.4

- Left-click on the WampServer icon in the system tray to open the menu.
- PHP > PHP extensions > ... several extensions to be checked or uncheched

Default Extensions

```
extension=bz2
extension=ldap
extension=curl
extension=fileinfo
extension=gd
extension=gettext
extension=imap
extension=mbstring
extension=exif
extension=mysqli
extension=openssl
extension=pdo_mysql
extension=soap
extension=sockets
extension=sodium
```
<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/Extension.png" alt="" style=" width:500px">

- PHP > PHP settings > ... several options to be modified

```
max_execution_time = 360
max_input_time = 360
max_input_vars = 10000
memory_limit = 256M
post_max_size = 1024M
short_open_tag = On
```

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/PHP%20Setting.png" alt="" style=" width:500px">

- Update the Environment Variable for PHP Binary.

- Right click on This PC, go to <code><b>Properties > Advanced System Settings ></b></code> Environment Variables.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/env1.png" alt="" style=" width:500px ; height:200px ">

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/env2.png" alt="" style=" width:500px ; height:300px ">

- Now click on Path > Edit > New & add copied path <code><b>C:\php</b> </code> here and click OK in all 3 tabs.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/envpath.png" alt="" style=" width:500px ; height:300px ">

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/php-env.png" alt="" style=" width:500px ; height:300px ">


<a id="7" name="7"></a>

## 7. Install Redis Extension

<a href="https://pecl.php.net/package/redis/6.1.0/windows" target="_blank" rel="noopener">Click Here</a> to download PHP 8.4 Non Thread Safe (TS) x64 zip file.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/PHPredis.png" style=" width:400px ; height:250px ">

- Unzip the php-redis zip file, a folder will be created, go inside the folder, copy the <code><b>php_redis.dll</b></code> file and paste it in <code><b>C:\wamp64\bin\php\php8.4.13\ext</b></code>. (C:\xampp\php incase of Apache WebServer).
- Now enable php redis extension in <code><b>phpForApache.ini</b></code> configuration located in <code><b>C:\wamp64\bin\php\php8.4.13</b></code>.  

```
extension=php_redis.dll
```

<a id="8" name="8Configure-Task-Scheduler"></a>
## <b>8. Cron in Task Scheduler</b>


- To open Task scheduler press <b>Win+R</b> and type <code><b>taskschd.msc</b></code>.
- On the Right pane of the Task scheduler select <code><b>Create Basic Task</b></code> enter a <code><b>Name</b></code> for the task and click <code><b>Next</b></code>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache34.png" alt="" style=" width:500px ; height:250px ">

- Under <code><b>Task Trigger</b></code>, section select <code><b>Daily</b></code> and click <code><b>Next</b></code> and leave the default values in <code><b>Daily</b></code> section tick the <code><b>Synchronize across time zones</b></code> and proceed <code><b>Next</b></code>.

- Now under the <code><b>Action</b></code> section select <code><b>Start a program</b></code> and click <code><b>Next</b></code>. 


- In <code><b>Start a program</b></code> copy the below value into the <code><b>program/script field</b></code>.
```
C:\Windows\System32\cmd.exe
```
- Add the following highlighted values to the Argument :

- This is for faveo incoming mail, esacalation, faveo update check.
```
/c php "C:\wamp64\www\faveo\artisan" schedule:run
```
<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache35.png" alt="" style=" width:500px ; height:250px ">

- Finally under the <code><b>Finish</b></code> section select the <code><b>checkbox</b></code> to open the properties window after finish and click the <code><b>Finish</b></code> button.

- In the properties window, select the <code><b>Triggers</b></code> tab, click on <code><b>Edit</b></code> and select the checkbox for <code><b>Repeat task every</b></code> set values to run every <code><b>5 minutes</b></code>, for a duration of <code><b>indefinitely</b></code> and click on <code><b>OK</b></code>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache37.png" alt="" style=" width:500px ; height:250px ">

- Similarly add two more triggers <code><b>At log on</b></code> & <code><b>At startup up</b></code>, set values to run every <code><b>5 minutes</b></code>, for a duration of <code><b>indefinitely</b></code> and click on <code><b>OK</b></code>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/trigger.png" alt="" style=" width:400px ; height:250px ">


<a id="9" name="9"></a>
## 9. Self-Signed SSL

This document will list how to install Self-Signed SSL certificates on Windows servers.

- We will be using the tool OpenSSL for creating a Self-Signed SSL certificate on a windows machine.

- The OpenSSL is an open-source library that provides cryptographic functions and implementations. 

- OpenSSL is a defacto library for cryptography-related operations and is used by a lot of different applications. 

- OpenSSL is provided as a library and application. 

- OpenSSL provides functions and features like SSL/TLS, SHA1, Encryption, Decryption, AES, etc.

---

- Edit the <code><b>httpd.conf</b></code> file Open the file <code><b>C:\wamp64\bin\apache\apache2.4.54.2\conf\httpd.conf</b></code> and un-comment (remove #) from the following 3 lines 



```
LoadModule ssl_module modules/mod_ssl.so
Include conf/extra/httpd-ssl.conf
LoadModule socache_shmcb_module modules/mod_socache_shmcb.so
```

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/httpd.png" alt="" style=" width:500px">


### Step 1: Install Chocolatey

- Open an elevated Command Prompt or PowerShell. Right-click on the "Start" button and select "Windows Terminal (Admin)" or "Command Prompt (Admin)" or "Windows PowerShell (Admin)".

- Copy and paste the following command to download and run the Chocolatey installation script:

```
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/chocol.png" alt="" style=" width:500px">

- You may be prompted to confirm the execution of scripts. Enter <code><b>"A"</b></code> and press Enter to allow the script to run.

- Wait for the installation to complete. Chocolatey will be installed in the <code><b>"C:\ProgramData\chocolatey"</b></code> directory by default.

- To verify the installation, open a new Command Prompt or PowerShell window and run:

```
choco --version
```

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/choco-v.png" alt="" style=" width:500px">

### Step 2: Install OpenSSL

- After successfully installing Chocolatey, you can proceed to install OpenSSL.

- Open a new Command Prompt or PowerShell window with administrator privileges.

- To install OpenSSL, run the following Chocolatey command:

```
choco install openssl
```

- Follow the on-screen prompts to confirm the installation. You can typically accept the default options by pressing Enter <code><b>"A"</b></code>.

- Wait for the installation to complete. Chocolatey will download and install OpenSSL and its dependencies.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/openssl.png" alt="" style=" width:500px">

- To verify the OpenSSL installation, run: 
```
openssl version
```

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/ssl-v.png" alt="" style=" width:500px">


#### Generate a private key for the CA

Create a directory named SSL under C directory like <code><b>C:\SSL</b></code>, the following commands will create the SSL files those files will be saved in the directory which we create.

- Open Command Prompt from the SSL directory that we created,

- Run the below command to create a Private key for the rootCA this command will save a file name faveoroot.key in the SSL folder.

```
openssl ecparam -out faveoroot.key -name prime256v1 -genkey
```

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/ssl-1.png" alt="" style=" width:500px">

#### Generate a certificate signing request for the CA

From the command prompt run the below command which will create a CSR (certificate signing request) for the Root CA.

```
openssl req -new -sha256 -key faveoroot.key -out faveoroot.csr
```

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/ssl-2.png" alt="" style=" width:500px">

The above command will ask for the below information if needed you can provide them or you can just hit enter and skip them but it is recommended to give the meaningful details.

- Country Name.
- State Name.
- Organization.
- Common name (Leave this as blank or provide the company domain not the faveo domain).
- Email address.

The above command will save a file in the name faveoroot.csr in the SSL directory.

#### Generate a root certificate

The below command will create the Root CA certificate which we will use to sign the SSL certificates. 

```
openssl x509 -req -sha256 -days 3650 -in faveoroot.csr -signkey faveoroot.key -out faveorootCA.crt
```


<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/ssl-3.png" alt="" style=" width:500px">

The above command will create a file and save it as faveorootCA.crt in the SSL directory.

#### Create a private key for the certificate 

The below command will create a private key file for the server SSL certificate.

```
openssl ecparam -out private.key -name prime256v1 -genkey
```

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/ssl-4.png" alt="" style=" width:500px">

The above command will save a key file with the name private.key for the server SSL certificate.

#### Create a certificate signing request for the server SSL

The below command will create a Certificate Signing Request for the Server SSL.

```
openssl req -new -sha256 -key private.key -out faveolocal.csr
```

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/ssl-5.png" alt="" style=" width:500px">

It will ask for the details below we should give the details as shown below.

- Country Name.
- State Name.
- Organization.
- Common name (Here please provide the Domain or the IP through which you need to access faveo).
- Email address.

The rest can be left blank and after this is completed it will create the CSR file and save it with the name faveolocal.csr in the SSL directory.

#### Create a certificate and sign it with the CA private key

The below command will create the server SSL certificate which is signed by the Root CA that we created above.

```
openssl x509 -req -in faveolocal.csr -CA  faveorootCA.crt -CAkey faveoroot.key -CAcreateserial -out faveolocal.crt -days 3650 -sha256 
```

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/ssl-6.png" alt="" style=" width:500px">

The above command will create a server SSL file and save it in the name faveolocal.crt, this certificate will be valid for 3650 days which is ten years.

#### Verify the newly created certificate

```
openssl x509 -in faveolocal.crt -text -noout  
```

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/ssl-7.png" alt="" style=" width:500px">

#### Compiling the created certificate and key file as .pfx file

As windows need the certificate file in .pfx format which will contain the both certificate and the key file and the CA file for the installation, so we need to convert the created files to .pfx format, this can be done with the below command.
```
openssl pkcs12 -export -out cert.pfx -inkey private.key -in faveolocal.crt -certfile faveorootCA.crt
```

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/ssl-8.png" alt="" style=" width:500px">

The above command will create a .pfx file with the name cert.pfx in the SSL directory.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/openssl-dir.png" alt="" style=" width:500px">

#### Installing the SSL certificate

- Navigate inside your SSL directory and double click on faveorootCA.crt

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/cert-1.png" alt="" style=" width:300px">

- Click on Install Certificate → Select local machine→ Click on next

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/cert-2.png" alt="" style=" width:300px">

- Select “Trusted Root Certification Authorities” directory and click on OK.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/cert-3.png" alt="" style=" width:500px">

- Click Next and Finish. You should get imported successful .

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/cert-4.png" alt="" style=" width:300px">

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/cert-5.png" alt="" style=" width:300px">

### Step 3: Download & Enable cacert.pem File in PHP Configuration File


-   <a href="https://curl.se/docs/caextract.html" target="_blank" rel="noopener">Click Here</a> to download <code><b>cacart.pem</b></code> file. This is required to avoid the “cURL 60 error” which is one of the Probes that Faveo checks.
- Extract the <code><b>cacert.pem</b></code> file and copy it to <code><b>C:\wamp64\bin\php\php8.4.13</b></code> path.

- Edit the <code><b>phpForApache.ini</b></code>, Uncomment <code><b>curl.cainfo</b></code> and add the location of <code><b> cacert.pem </b></code> to it as below:
```
curl.cainfo = "C:\wamp64\bin\php\php8.4.13\cacert.pem"
```

- Edit the faveorootCA.crt and copy the content.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/faveorootCA.png" alt="" style=" width:500px">

- Edit the cacert.pem file and append the content copied from faveorootCA.crt in this file.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/cacert.png" alt="" style=" width:500px">

- Save and Close the File.


### Step 4: Edit the “hosts” file on the OS to Map the Custom Domain to Loopback Address.

- Open the hosts file from the path <code><b>C:\Windows\System32\drivers\etc </b></code>

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/hosts.png" alt="" style=" width:500px">

- Map your custom domain to 127.0.0.1

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/hosts-map.png" alt="" style=" width:500px">

- Save and Close the File.

- if the above is done we need to edit the php.ini file which is found inside the PHP root directory. Uncomment and add the location of <code><b>cacert.pem</b></code> to <code><b>“openssl.cafile”</b></code> like.
```
openssl.cafile = "C:\wamp64\bin\php\php8.4.13\cacert.pem"
```

- Edit the <code><b>C:\Apache24\conf\extra\httpd-ssl.conf</b></code> file, search for <VirtualHost _default_:443>
- Turn SSL Engine on & add the certificate paths respectively as shown below:

```
SSLEngine on
SSLCertificateFile "C:\SSL\faveolocal.crt"
SSLCertificateKeyFile "C:\SSL\private.key"
SSLCACertificateFile "C:\SSL\faveorootCA.crt"
```

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/httpd-ssl.png" alt="" style=" width:500px">

Update  the “DocumentRoot” to value to “C:\wamp64\www” 


<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Wamp-Images/https-ssl-doc.png" alt="" style=" width:500px">

Restart the apache service from WAMP tray and visit https://faveo.localhost from your browser and Self Sign the certificate.


<a id="10" name="10"></a>
### <b>10. Install Faveo</b>

Now you can install Faveo via [GUI](/docs/installation/installer/gui) Wizard or [CLI](/docs/installation/installer/cli)


---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/apache-windows/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-07-15
last_modified_by: Mohammad_Asif
toc: true
title: Faveo Installation on Windows with Apache Web Server
---

<style>p>code, a>code, li>code, figcaption>code, td>code {background: #dedede;}</style>


<img alt="Windows" src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Windows_logo_and_wordmark_-_2021.svg/250px-Windows_logo_and_wordmark_-_2021.svg.png" width="200"  />



<img alt="Apache" src="https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Apache_HTTP_server_logo_%282019-present%29.svg/2560px-Apache_HTTP_server_logo_%282019-present%29.svg.png" width="200"  /> 

[<strong>Faveo Installation on Windows with Apache Web Server</strong>](#Faveo-Installation-on-Windows-with-Apache-Web-Server)

- [<strong>Installation steps:</strong>](#installation-steps)

  - [<strong>1.Install & Configure Apache for Windows</strong>](#1Install-&-Configure-Apache-for-Windows)
  - [<strong> 2. PHP 8.2 for Apache Web Server </strong>](#2PHP-8.2-for-Apache-Web-Server)
  - [<strong> 3. Install Ioncube Loader </strong>](#3Install-Ioncube-Loader)
  - [<strong> 4. Install wkhtmltopdf </strong>](#4Install-wkhtmltopdf)
  - [<strong> 5. Upload Faveo </strong>](#5Upload-Faveo)
  - [<strong> 6. Install MariaDB 10.6/MySQL 8.0  </strong>](#3Install-MariaDB-10.6/MySQL-8.0)
  - [<strong> 7. Setting up the Database </strong>](#7Setting-up-the-Database)
  - [<strong> 8. Set Cron & Configure Queue Driver </strong>](#8Configure-Task-Scheduler)
  - [<strong> 9. Install Meilisearch </strong>](#9Install-meilisearch)
  - [<strong> 10. SSL Installation </strong>](#10SSL-Installation)
  - [<strong> 11. Install Faveo </strong>](#11Install-Faveo)
  - [<strong> 12. Faveo Backup</strong>](#12-faveo-backup)



Before we follow the installation steps <a href="https://notepad-plus-plus.org/downloads/" target="_blank" rel="noopener">Notepad++</a>  ,  <a href="https://www.win-rar.com/download.html?&L=0" target="_blank" rel="noopener">Winrar</a> &  <a href="https://7-zip.org/download.html" target="_blank" rel="noopener">7-Zip</a> must be installed.


<a id="1Install-&-Configure-Apache-for-Windows" name="1Install-&-Configure-Apache-for-Windows"></a>

### <b>1. Install & Configure Apache for Windows</b>

### <b>a. Download Apache for Windows</b>

- <a href="https://www.apachelounge.com/download/" target="_blank" rel="noopener" > Click Here</a> to download 64-bit version Apache. 

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Win-Apache-Images/Apache-Window-1.png" alt="" style=" width:500px ; height:250px ">

- Extract its contents of the zip file to a suitable location on your Windows server to be configured. It is recommended to extract the contents in the <code><b>C drive</b></code> of the server.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache3.png" alt="" style=" width:500px ; height:250px ">

In addition, you need to have the relevant C++ Redistributable for Visual Studio installed on your server too.
- <a href="https://docs.microsoft.com/en-US/cpp/windows/latest-supported-vc-redist?view=msvc-170" target="_blank" rel="noopener" > Click Here</a> to download the Visual Studio.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache4.png" alt="" style=" width:500px ; height:250px ">

- Execute the installer to perform the required installation.
- Accept the License Agreement terms and click <code><b>Install</b></code>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache4a.png" alt="" style=" width:500px ; height:250px ">

- Click <code><b>Close</b></code> to finish the installation.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache4b.png" alt="" style=" width:500px ; height:250px ">

### <b>b. Run Apache</b>

Open a Command Prompt in the <Code><b>C:\Apache24\bin</b></code> folder. (i.e., the location where you extracted Apache).

- For command prompt, enter the following command to start Apache:

```
Httpd.exe
```
<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache10.png" alt="" style=" width:500px ; height:100px ">

You might see a Windows Firewall prompt. <code><b>Allow</b></code> the access to be appropriate. 

Failing to allow Apache access through your server’s firewall will result in other computers/devices being unable to connect to your web server.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache11.png" alt="" style=" width:500px ; height:300px ">

You will come across a <b>could not bind to address</b> error if another service is already running on Apache’s default port (80).

Therefore, check that you don’t currently have an IIS (Internet Information Services) server already running. 

If so, you either need to stop/disable IIS in order to run Apache or change the port on either IIS or Apache to allow both services to run simultaneously.

<b>c. Test Whether Apache is Running Successfully </b>

- Keep the previous command window open, and navigate to the below address with your web browser.

```cpp
http://127.0.0.1
```

- If Apache is running on your Windows Server 2022 you will see the message <b>It works!</b> in your browser.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache12.png" alt="" style=" width:500px ; height:100px ">

<b>d. Install Apache as a Windows Service Default </b>

After the previous step, Apache will exit after you close the command window. 

To ensure that your Apache web server runs all the time, you need to install it as a Windows service.

Here is how you can install Apache as a Windows Service in an easy and quick way:

Step 1: Open an administrative command prompt window, navigate to the <code><b>C:\Apache24\bin</b></code> location and enter the following command:

```cpp
httpd.exe -k install -n "Apache HTTP Server"
```

- You will see the following output,

```cpp
Installing the 'Apache HTTP Server' service
The 'Apache HTTP Server' service is successfully installed.
Testing httpd.conf....
Errors reported here must be corrected before the service can be started.
```

Step 2: Then, write the following command and press <code><b>Enter</b></code> In the Command Prompt window.

```cpp
services.msc
```

Look for the service <code><b>Apache HTTP Server.</b></code> You should see <code><b>Automatic</b></code> towards the left of that line. If you don’t, change the Startup Type to <b>Automatic</b> by double-clicking the line.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache13.png" alt="" style=" width:500px ; height:350px ">

Step 3: Finally, restart your server and open a web browser once you are logged back in. Navigate to the following address in the web browser: 

```
http://127.0.0.1
```
### <b>e. Configure Windows Firewall – Open to World </b>

Configuring the Window's Firewall is the final step to install Apache web server on Windows Server 2022. It allows connections from the Internet to your new web server. Here are the steps that you need to follow:

- Step 1: Go to Start Menu and enter a search query, <code><b>firewall</b></code>. Select the <code><b>Windows Firewall With Advanced Security</b></code> item.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache14.png" alt="" style=" width:500px ; height:110px ">

- Step 2: Select the <code><b>New Rule</b></code> on the right-hand sidebar.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache15.png" alt="" style=" width:500px ; height:130px ">

- Step 3: Click on <code><b>Port,</b></code> and then click <code><b>Next</b></code>. 

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache16.png" alt="" style=" width:500px ; height:250px ">

- Step 4: Then, select the radio button next to <code><b>Specific remote ports:</b></code> and enter the following into the input box: <code><b>80, 443.</b></code>

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache16b.png" alt="" style=" width:500px ; height:250px ">

- Step 5: Click <code><b>Next</b></code> and select the <code><b>Allow the connection</b></code> option.

- Step 6: Click <code><b>Next</b></code>. Make sure that all the boxes on the next page are selected and then click <code><b>Next</b></code> again.

- Step 7: In the <code><b>Name</b></code> section, enter a description which ensures that you will be able to remember the rule’s purpose later such as: <code><b>Allow Incoming Apache Traffic.</b></code>

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache17.png" alt="" style=" width:500px ; height:250px ">

- Step 8: Click <code><b>Finish</b></code>.
- Step 9: Test the server for other devices by connecting to your server’s IP address from a device other than the one you are using to connect to the server right now. Open a web browser on that device and enter the IP address of your server like:

 ```
 http://SERVER-PUBLIC-IP
 ```

You will be able to see the test web page that shows the message <b>It works!</b>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache18.png" alt="" style=" width:500px ; height:100px ">

If the test page works successfully and shows the message, it means that you have successfully configured Windows Firewall and other devices can connect to your web server. 

These were the simple steps by which you can install Apache Web Server on Windows Server 2022.

### <b>f. Mod_fcgi </b>

-   <a href="https://www.apachelounge.com/download/" target="_blank" rel="noopener">Click Here</a> to download Mod_fcgi zip file. 

 <img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Win-Apache-Images/Apache-Window-11.png" alt="" style=" width:500px ; height:100px ">

 - Step 1: Unzip the <code><b>mod_Fcgi file</b></code>, copy the <code><b>mod_fcgid.so</b></code> file to the <code><b>C:\Apache24\modules</b></code> folder.

  <img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache22.png" alt="" style=" width:500px ; height:100px ">

 - Step 2:Edit the <code><b>C:\Apache24\conf\httpd.conf</b></code> file using a text editor in Administrator mode, so that any changes you make are saved.

 - Add the content below after the <code><b>#LoadModule xml2enc_module modules/mod_xml2enc.so</b></code> line:

 ```cpp
LoadModule fcgid_module modules/mod_fcgid.so
FcgidInitialEnv PHPRC "/php"
FcgidInitialEnv PHP_FCGI_MAX_REQUESTS "100000"
FcgidIOTimeout 1800
FcgidBusyTimeout 1800
FcgidConnectTimeout 1800
FcgidMaxRequestLen 1073741824
FcgidMaxRequestsPerProcess 10000
FcgidOutputBufferSize 4000
FcgidProcessLifeTime 3600
Timeout 1024
KeepAlive On
KeepAliveTimeout 50
MaxKeepAliveRequests 500
AddHandler fcgid-script .php
FcgidWrapper "/php/php-cgi.exe" .php
 ```


  <img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache24a.png" alt="" style=" width:500px ; height:170px ">

- Step 3: Search for <code><b>#ServerName www.example.com:80</b></code> and change this line to below:

```
ServerName YOURDOMAIN:80
```

- Step 4: Change the contents of the <code><b>DirectoryIndex</b></code> directive by adding the following contents to the directive line:

```
index.php index.phtml
```
After adding this, it will look like below:

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache25.png" alt="" style=" width:500px ; height:100px ">

- Step 5: Set the <code><b>${SRVROOT}</b></code> variable with your Apache folder path:
Search for the <code><b>Define SRVROOT</b></code> and edit it as follows:

```
Define SRVROOT "c:/Apache24"
```
- Step 6: Change the contents of the <code><b><Directory "${SRVROOT}/htdocs"></b></code> directive.

```
Options Indexes FollowSymLinks ExecCGI
AllowOverride All
```
<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Win-Apache-Images/Apache-Window-12.png" alt="" style=" width:500px">

- Step 7: Search for the <code><b>IfModule mime_module</b></code> directive and add the below content above this directive:

```
<Directory "/php">
    AllowOverride None
    Options None
    Require all granted
</Directory>
```
<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Win-Apache-Images/Apache-Window-13.png" alt="" style=" width:500px ; height:170px ">

### <b>g. Enable Necessary Modules </b>

- Look for the following line in <code><b>C:\Apache24\conf\httpd.conf</b></code>, Uncomment it by removing # at its beginning.

```
LoadModule rewrite_module modules/mod_rewrite.so
LoadModule authz_host_module modules/mod_authz_host.so
LoadModule access_compat_module modules/mod_access_compat.so
```


<a id="2PHP-8.2-for-Apache-Web-Server" 
name="2PHP-8.2-for-Apache-Web-Server"></a>


### <b>2. PHP 8.2 for Apache Web Server</b>


-   <a href="https://windows.php.net/downloads/releases/archives/" target="_blank" rel="noopener">Click Here</a> to download <code>php-8.2.29-nts-Win32-vs16-x64.zip</code> file.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/GUI-images/php82-a.png" alt="" style=" width:500px ; height:150px ">

- Extract the zip file & rename it to <code><b>php</b></code>. Now move the renamed <code><b>php</b></code> folder to <code><b>C drive</b></code>.


<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache20.png" alt="" style=" width:500px ; height:150px ">

### <b>b. Configure the PHP 8.2</b>

With Apache active and functional, you now need to define and configure the <code><b>C:\php\php.ini</b> </code>file so those database extensions and libraries are available for use by Faveo.

- Step 1: Access the PHP folder in <code><b>C:/</b> </code> and rename the <code><b>php.ini-development</b></code> file to <code><b>php.ini</b></code>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache28.png" alt="" style=" width:500px ; height:200px ">

- Step 2: Access the <code><b>php.ini</b></code> file with a text editor using Administrative privileges and search for the <code><b>;extension_dir = "ext"</b></code> directive.

Assign the value <code><b>“C:\php\ext”</b></code> to this directive as shown below:

```
extension_dir = "C:\php\ext"
```
After assigning the value <code><b>C:\php\ext</b></code>, it will look like below:

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache29.png" alt="" style=" width:300px ; height:100px ">

- Step 3: Enable the extensions listed below, by uncommenting them (Remove the semicolon <code><b>;</b></code> at beginning of line).

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

- Step 4: Set the recommended minimum value of these PHP directives listed below for Faveo to work properly. 
- Search for the directives and assign the value according to this example:

```
max_execution_time = 360
max_input_time = 360
max_input_vars = 10000
memory_limit = 256M
post_max_size = 1024M
upload_max_filesize = 100M
max_file_uploads = 100
short_open_tag = On
```

- Step 5: Set up PHP TimeZone according to your region. You must use the value available in <a href="https://www.php.net/manual/en/timezones.php" target="_blank" rel="noopener">PHP Documentation</a> 
- Search for the <code><b>date.timezone</b></code> line, uncomment it and edit it according to the selected TimeZone:


```
date.timezone = Asia/Kolkata
```

- Step 6: Set the folder where temporary files will be stored. 
- Search for the <code><b>;session.save_path line</b></code>, uncomment it, and enter the path to your temporary folder.


```
session.save_path = "C:\Windows\Temp"
```
After adding the path, it look look like below:

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache30.png" alt="" style=" width:300px ; height:100px ">

- Step 7:  Save all changes made to the <code><b>php.ini</b></code> file.

- Step 8: Update the Environment Variable for PHP Binary.

- Right click on This PC, go to <code><b>Properties > Advanced System Settings ></b></code> Environment Variables.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/env1.png" alt="" style=" width:500px ; height:200px ">

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/env2.png" alt="" style=" width:500px ; height:300px ">

- Now click on Path > Edit > New & add copied path <code><b>C:\php</b> </code> here and click OK in all 3 tabs.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/envpath.png" alt="" style=" width:500px ; height:300px ">

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/env5.png" alt="" style=" width:500px ; height:300px ">

- Step 9:  Verify changes made through the <code><b>info.php</b></code> file. 
- You need to create this file and place it in the <code><b>C:\Apache24\htdocs</b></code> directory with the following content:

```
<?php
phpinfo();
?>
```

- Step 10: Restart <code><b>Apache HTTP Server</b></code> Service.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Win-Apache-Images/Apache-Window-14.png" alt="" style=" width:500px">

- After this, check the generated page in your browser by going to the URL below:

```
http://127.0.0.1/info.php
```

 <img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Win-Apache-Images/Apache-Window-16.png" alt="" style=" width:500px ; height:100px ">

 
### <b>c. Download & Enable cacert.pem File in PHP Configuration File</b>

-   <a href="https://curl.se/ca/cacert-2025-07-15.pem" target="_blank" rel="noopener">Click Here</a> to download <code><b>cacert.pem</b></code> file. This is required to avoid the “cURL 60 error” which is one of the Probes that Faveo checks.
- Rename the file to <code><b>cacert.pem</b></code> and copy it to <code><b>C:\php</b></code> path.
- Edit the <code><b>C:\php\php.ini</b></code>, Uncomment <code><b>curl.cainfo</b></code> and add the location of cacert.pem to it as below:
```
curl.cainfo = "C:\php\cacert.pem"
```



<a id="3Install-Ioncube-Loader" 
name="3Install-Ioncube-Loader"></a>

### <b>3. Install Ioncube Loader</b>


-   <a href="https://downloads.ioncube.com/loader_downloads/ioncube_loaders_win_nonts_vc16_x86-64.zip" target="_blank" rel="noopener">Click Here</a> to download IonCube Loader zip file.

- Step 1: Extract the IonCube Loader file downloaded.

- Step 2: Copy the <code><b>ioncube_loader_win_8.2.dll</b></code> file and paste it into the PHP extensions directory <code><b>C:\php\ext</b></code>.

- Step 3: Copy the <code><b>“loader-wizard.php”</b></code> from the extracted Ioncube folder and paste it into the <code><b>C:\Apache24\htdocs</b></code>.

- Step 4: Edit the <code><b>C:\php\php.ini</b></code> file and below the last line enter the path to the extension within the <code><b>zend_extension</b></code> parameter:

```
zend_extension = "C:\php\ext\ioncube_loader_win_8.2.dll"
```

- Step 5: Run the below URL to verify the ionCube Installation. 
- Note: If you didn’t get the below output try restarting the Apache Server.

```
http://127.0.0.1\loader-wizard.php
```
<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache32.png" alt="" style=" width:500px ; height:150px ">

<a id="4Download-&-Enable-cacert.pem-File-in-PHP-Configuration-File" 
name="4Download-&-Enable-cacert.pem-File-in-PHP-Configuration-File"></a>


<a id="4Install-wkhtmltopdf" 
name="4Install-wkhtmltopdf"></a>

### <b>4. Install wkhtmltopdf</b>

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

- Now copy <code><b>wkhtmltox.dll</b></code> located at <code><b>C:\Program Files\wkhtmltopdf\bin</b></code> and paste it in <code><b>C:\php\ext</b></code>

- Update the Environment variable for wkhtmltopdf. 

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/envwkhtml.png" alt="" style=" width:400px ; height:250px ">

<a id="5Upload-Faveo" 
name="5Upload-Faveo"></a>

### <b>5. Upload Faveo</b>


- Download the Faveo Helpdesk from https://billing.faveohelpdesk.com and upload it to the below directory.

```
 C:\Apache24\htdocs
```

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache33.png" alt="" style=" width:500px ; height:250px ">
  
- We need to give full write permission to <code><b>Users</b></code> for the <code><b>C:\Apache24\htdocs</b></code> folder.
  
<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache33a.png" alt="" style=" width:500px ; height:250px ">

Give full permissions (same as above) to the Windows Temp folder as well:

```
C:\Windows\Temp
```


<a id="6Setting-up-the-Database" 
name="6Setting-up-the-Database"></a>

<a id="6Install-MariaDB-10.6/MySQL-8.0" 
name="6Install-MariaDB-10.6/MySQL-8.0"></a>

### <b>6. Install MariaDB 10.6/MySQL 8.0 </b>


- An open-source relational database management system(RDBMS) can be chosen among the MariaDB and MySQL.

- [MariaDB documentation](/docs/installation/providers/enterprise/mariadb-windows)
- [MySQL documentation](/docs/installation/providers/enterprise/mysql-windows)

<a id="4Install-Ioncube-Loader" 
name="4Install-Ioncube-Loader"></a>

### <b>7. Setting up the Database</b>


Open MariaDB 10.6 or Mysql 8.0 Command Line Client and run the below command.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/Win-Apache-Images/Apache-Window-15.png" alt="" style=" width:500px ; height:300px ">

- Create a database called ‘faveo’.

```sql
CREATE DATABASE faveo;
```

- Create a user called ‘faveo’ and its password ‘strong password’.

```sql
CREATE USER 'faveo'@'localhost' IDENTIFIED BY 'strongpassword';
```

- We have to authorize the new user on the faveo DB so that he is allowed to change the database.

```sql
GRANT ALL ON faveo.* TO 'faveo'@'localhost';
```

- And finally, we apply the changes and exit the database.

```sql
FLUSH PRIVILEGES;
exit
```


<a id="8Configure-Task-Scheduler" 
name="8Configure-Task-Scheduler"></a>

### <b>8. Set Cron & Configure Queue Driver</b>

### <b>a. Cron in Task Scheduler</b>

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
/c php "c:\Apache24\htdocs\artisan" schedule:run
```
<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache35.png" alt="" style=" width:500px ; height:250px ">

- Finally under the <code><b>Finish</b></code> section select the <code><b>checkbox</b></code> to open the properties window after finish and click the <code><b>Finish</b></code> button.

- In the properties window, select the <code><b>Triggers</b></code> tab, click on <code><b>Edit</b></code> and select the checkbox for <code><b>Repeat task every</b></code> set values to run every <code><b>5 minutes</b></code>, for a duration of <code><b>indefinitely</b></code> and click on <code><b>OK</b></code>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache37.png" alt="" style=" width:500px ; height:250px ">

- Similarly add two more triggers <code><b>At log on</b></code> & <code><b>At startup up</b></code>, set values to run every <code><b>5 minutes</b></code>, for a duration of <code><b>indefinitely</b></code> and click on <code><b>OK</b></code>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/trigger.png" alt="" style=" width:400px ; height:250px ">

### <b>b. Queue Drivers</b>

A queue driver is the handler for managing how to run a queued job, identifying whether the jobs succeeded or failed, and trying the job again if configured to do so. There are different queue lists available to be used by the system:

- Sync (Activated by default)
- Database (this will use the database used by the application to act as a queue)
- Redis

- <b>Sync</b>, or synchronous, is the default queue driver which runs a queued job within your existing process. With this driver enabled, you effectively have no queue as the queued job runs immediately. When a small number of incoming and outgoing mail functionalities are operated by the system, this sync method can be used. 

- <b>Database</b> driver stores queued jobs in the database. In Database queue multiple users need to work on a pool of records in a queue to process them. The records in the queue are in an unprocessed state. After the user worked on any record, that record is in a completed state and is removed from the queue.
- Database Queue option lets the emails queue to execute using First in First out (FIFO) method and sends emails to the clients one by one.
- In Database, Read and Write operations are slow because of storing data in secondary memory.

- [Database Configuring documentation](/docs/installation/providers/enterprise/database) 

- <b>Redis</b> is an open-source (BSD licensed), in-memory data structure store, used as a database, cache and message broker. This  will improve system performance and is highly recommended.
- In Redis, Read and Write operations are extremely fast because of storing data in primary memory.

- [Redis Installation documentation](/docs/installation/providers/enterprise/redis-windows)

<b>Note:</b> Database queue driver must be used only in windows server. C Panel or Linux users should not use database as queue driver.


<a id="9Install-meilisearch" 
name="9Install-meilisearch"></a>

### <b>9. Install Meilisearch</b>

MeiliSearch is an open-source search engine developed in Rust that delivers flexible search and indexing capabilities. It adeptly handles typos, supports full-text search, synonyms, and comes packed with various features, making it an ideal choice for elevating search functionalities in Faveo.

[Meilisearch installation documentation](/docs/installation/providers/enterprise/meilisearch)


<a id="10SSL-Installation" 
name="10SSL-Installation"></a>

### <b>10. SSL Installation</b>


Secure Sockets Layer (SSL) is a standard security technology for establishing an encrypted link between a server and a client. Let’s Encrypt is a free, automated, and open certificate authority.

Apache only supports Paid SSL or the Self Signed SSL, Let’s Encrypt is not supported by Apache.


- [ Self Signed SSL installation documentation](/docs/installation/providers/enterprise/windows-apache-ssl)



<a id="11Install-Faveo" 
name="11Install-Faveo"></a>

### <b>11. Install Faveo</b>

Now you can install Faveo via [GUI](/docs/installation/installer/gui) Wizard or [CLI](/docs/installation/installer/cli)



<a id="12-faveo-backup" name="12-faveo-backup"></a>

### <b>12. Faveo Backup</b>

At this stage, Faveo has been installed, it is time to setup the backup for Faveo File System and Database. [Follow this article](/docs/helper/backup) to setup Faveo backup.

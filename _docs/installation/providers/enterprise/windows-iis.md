---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/windows-iis/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-07-15
last_modified_by: Mohammad_Asif
toc: true
title: Installing Faveo Helpdesk on Windows Server
---
<style>p>code, a>code, li>code, figcaption>code, td>code {background: #dedede;}</style>

<img alt="Windows" src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Windows_logo_and_wordmark_-_2021.svg/250px-Windows_logo_and_wordmark_-_2021.svg.png" width="200"  />

Faveo can run on the [Windows Server](https://www.microsoft.com/en-au/windows-server).


- [<strong>Installation steps:</strong>](#installation-steps)

  - [<strong>1.Install IIS Server</strong>](#1Install-IIS-Server)
  - [<strong> 2. Install PHP 8.2 </strong>](#2Install-PHP-8.2)
  - [<strong> 3. Create FastCGI Handler Mapping </strong>](#3Create-FastCGI-Handler-Mapping)
  - [<strong> 4. Install MariaDB 10.6/MySQL 8.0 </strong>](#4Install-MariaDB-10.6/MySQL-8.0)
  - [<strong> 5. Install Ioncube Loader </strong>](#5Install-Ioncube-Loader)
  - [<strong> 6. Install wkhtmltopdf </strong>](#6Install-wkhtmltopdf)
  - [<strong> 7. Upload Faveo </strong>](#7Upload-Faveo)
  - [<strong> 8. Configure Faveo in IIS Manager </strong>](#8Configure-Faveo-in-IIS-Manager)
  - [<strong> 9. Configure web.config file for IIS </strong>](#9Configure-web.config-file-for-IIS)
  - [<strong> 10. Setting up the Database </strong>](#10Setting-up-the-Database)
  - [<strong> 11. Setting up Bindings </strong>](#11Setting-up-Bindings)
  - [<strong> 12. Set Cron & Configure Queue Driver </strong>](#12Configure-Task-Scheduler)
  - [<strong> 13. Install Meilisearch </strong>](#13Install-Meilisearch)
  - [<strong> 14. SSL Installation </strong>](#14SSL-Installation)
  - [<strong> 15. Install Faveo </strong>](#15Install-Faveo)
  - [<strong>16. Faveo Backup</strong>](#16-faveo-backup)

The Installation steps listed above are to be followed to install Faveo on your Windows-IIS Server.

Before we follow the installation steps <a href="https://notepad-plus-plus.org/downloads/" target="_blank" rel="noopener">Notepad++</a>  ,  <a href="https://www.win-rar.com/download.html?&L=0" target="_blank" rel="noopener">Winrar</a> &  <a href="https://7-zip.org/download.html" target="_blank" rel="noopener">7-Zip</a> must be installed.

<a id="1Install-IIS-Server" name="1Install-IIS-Server"></a>

### <strong>1. Install IIS Server</strong>

To install IIS Server open Server Manager and locate the <code><b>Manage</b></code> button on the top right corner click on it and select  <code><b>Add Roles and Features</b></code>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/servermanager.png" alt="" style=" width:550px ; height:120px ">

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/addroles.png" alt="" style=" width:550px ; height:120px ">

- A wizard will open displaying the overview, click on <code><b>Next</b></code>, and under <code><b>Installation Type</b></code> select <code><b>Role-based and Feature-based installation</b></code> and select <code><b>Next</b></code>. 

- Leave the default in <code><b>Server Selection</b></code> and click <code><b>Next</b></code>. 

- Now under <code><b>Server Roles</b></code> search and enable the checkbox for <code><b>Web Server IIS</b></code> click on the <code><b>Add Features</b></code> window and proceed by clicking <code><b>Next</b></code>.



<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/Server-roles.png?raw=true" alt="" style=" width:400px ; height:250px ">


- In the <code><b>Features</b></code> section locate the <code><b>.NET Framework 3.5 and .NET Framework 4.7</b></code> select the packages as shown in the below image:

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/netframeworl.png?raw=true" alt="" style=" width:400px ; height:250px ">


- In the <code><b>Role Services</b></code> section locate the <code><b>Application Development</b></code> select the package <code><b>CGI</b></code> and click <code><b>Next</b></code>.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/cgi.png?raw=true" alt="" style=" width:400px ; height:250px ">



- Click <code><b>Next</b></code> thrice to confirm the settings and finally click on <code><b>Install</b></code>. It will get the IIS installed on the server. To verify the installation, you can type the following URL in the browser

```
http://localhost/
```

<a id="2Install-PHP-8.2" 
name="2Install-PHP-8.2"></a>

### <strong>2. Install PHP 8.2</strong>

-   <a href="https://windows.php.net/downloads/releases/archives/" target="_blank" rel="noopener">Click Here</a> to download php 8.2.9 NTS 64bit file. Extract the zip file & "rename it to <code><b>php8.2</b></code>. Now move the renamed <code><b>php8.2</b></code> folder to <code><b>C:\php8.2</b></code>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/GUI-images/php82-a.png" alt="" style=" width:400px ; height:150px ">

-   Open <code><b>php8.2</b></code> folder, find <code><b>php.ini-development</b></code> & rename it to <code><b>php.ini</b></code> to make it php configuration file.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/phpconfig.png?raw=true" alt="" style=" width:400px ; height:250px ">

-   Open <code><b>php.ini</b></code> using Notepad++, add the below lines at the end of this file & save the file:

Required configuration changes for Faveo Helpdesk.
```
error_log=C:\Windows\temp\PHP82x64_errors.log
upload_tmp_dir="C:\Windows\Temp"
session.save_path="C:\Windows\Temp"
cgi.force_redirect=0
cgi.fix_pathinfo=1
fastcgi.impersonate=1
fastcgi.logging=0
max_execution_time=300
date.timezone=Asia/Kolkata
extension_dir="C:\php8.2\ext\"
upload_max_filesize = 100M
post_max_size = 100M
memory_limit = 256M
```

Uncomment these extensions.
```
extension=bz2
extension=curl
extension=fileinfo
extension=gd
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
### <strong>2.a. Update the Environment Variable for PHP Binary</strong>
- Right click on This PC, go to Properties > Advanced System Settings > Environment Variables.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/env1.png" alt="" style=" width:500px ; height:200px ">

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/env2.png" alt="" style=" width:500px ; height:300px ">

- Now click on Path > Edit > New & add copied path C:\php8.2\ here and click OK in all 3 tabs.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/envpath.png" alt="" style=" width:500px ; height:300px ">

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/GUI-images/php82-b.png" alt="" style=" width:500px ; height:300px ">

### <strong>2.b. Enable cacert.pem File in PHP Configuration File</strong>

-   <a href="https://curl.se/ca/cacert-2025-07-15.pem" target="_blank" rel="noopener">Click Here</a> to download <code><b>cacaert.pem</b></code> file. This is required to avoid the “cURL 60 error” which is one of the Probes that Faveo checks.
- Rename the file to <code><b>cacert.pem</b></code> and copy it to <code><b>C:\php8.2</b></code> path.
- Edit the <code><b>php.ini</b></code> located in <code><b>C:\php8.2</b></code>, Uncomment <code><b>curl.cainfo</b></code> and add the location of cacert.pem to it as below:

```
curl.cainfo = "C:\php8.2\cacert.pem"
```


<a id="3Create-FastCGI-Handler-Mapping" 
name="3Create-FastCGI-Handler-Mapping"></a>

### <strong>3. Create FastCGI Handler Mapping</strong>


- Open Server Manager, locate <code><b>Tools</b></code> on the top right corner  of the Dashboard, Open <code><b>Internet Information Services (IIS) Manager</b></code>.
<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/iis.png?raw=true" alt="" style=" width:550px ; height:150px ">


- Now in the Left Panel of the IIS Manager select the server then you will find the <code><b>Handler Mappings</b></code> it will populate the available options to configure.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/handlermap.png" alt="" style=" width:400px ; height:250px ">

- Open <code><b>Handler Mappings</b></code>, Click on <code><b>Add Module Mapping</b></code> in the Right Panel, Add Module Mapping window will appear. Add the below values in the respective fields.


- RequestPath
```
*.php
```
- Module
```
FastCgiModule
```
- Executable (Optional)
```
"C:\php8.2\php-cgi.exe"
```
- Name
```
FastCGI
```

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/modulemapping.png" alt="" style=" width:400px ; height:250px ">

By default, IIS configures PHP only to accept GET, POST, and HEAD request types. Since Faveo makes use of other requests types (such as DELETE and PUT), you must manually change the PHP handler to allow them.

- Click on the <code><b>Request Restrictions</b></code> button, then switch to the <code><b>Verbs</b></code> tab. Switch the radio button to <code><b>All Verbs</b></code>, then click <code><b>OK</b></code> to close the window, then <code><b>OK</b></code> again to close the other.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/Verbs2.png?raw=true" alt="" style=" width:400px ; height:250px ">

**Note:** You may be prompted with an alert to <code><b>fix</b></code> the path to the PHP executable. If so, just put double-quotation marks around the path that already exists in the <code><b>Executable</b></code> box and it will save successfully.

- Open notepad and copy the below lines and save the file under the path <code><b>C:\inetpub\wwwroot</b></code> as <code><b>index.php</b></code>. Make sure while saving you select all file types otherwise you will end up having the file as index.php.txt
```
<?php
phpinfo();
?>
```

- Now go back to the main server configuration and select <code><b>Default Document</b></code>. Open <code><b>Default Document</b></code>, Click on <code><b>Add</b></code> from the Right Panel, a new window will appear. Add the value <code><b>index.php</b></code> and click <code><b>OK</b></code>.


<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/defaultdoc.png" alt="" style=" width:400px ; height:250px ">
<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/indexphp.png?raw=true" alt="" style=" width:400px ; height:250px ">

- Now if you visit "http://localhost" in the browser you should be able to see PHP Info page.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/phpinfo.png?raw=true" alt="" style=" width:400px ; height:250px ">

**Note:** If you don't see the above php page and see the error page like below, you need to install the relevant C++ Redistributable for Visual Studio.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/GUI-images/error-iis.png" alt="" style=" width:400px ; height:250px ">

#### Install Visual Studio (Conditional Step)
- <a href="https://docs.microsoft.com/en-US/cpp/windows/latest-supported-vc-redist?view=msvc-170" target="_blank" rel="noopener" > Click Here</a> to download the Visual Studio.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache4.png" alt="" style=" width:500px ; height:250px ">

- Execute the installer to perform the required installation.
- Accept the License Agreement terms and click <code><b>Install</b></code>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache4a.png" alt="" style=" width:500px ; height:250px ">

- Click <code><b>Close</b></code> to finish the installation.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/apache4b.png" alt="" style=" width:500px ; height:250px ">



<a id="4Install-MariaDB-10.6/MySQL-8.0" 
name="4Install-MariaDB-10.6/MySQL-8.0"></a>


### <strong>4. Install MariaDB 10.6/MySQL 8.0</strong>

- An open-source relational database management system(RDBMS) can be chosen among the MariaDB and MySQL.

- [MariaDB documentation](/docs/installation/providers/enterprise/mariadb-windows)
- [MySQL documentation](/docs/installation/providers/enterprise/mysql-windows)



<a id="5Install-Ioncube-Loader" 
name="5Install-Ioncube-Loader"></a>

### <strong>5. Install Ioncube Loader</strong>

-   <a href="https://downloads.ioncube.com/loader_downloads/ioncube_loaders_win_nonts_vc16_x86-64.zip" target="_blank" rel="noopener">Click Here</a> to download Ioncube Loader zip file, Extract the zip file.

- Copy the <code><b>ioncube_loader_win_8.2.dll</b></code> file from extracted Ioncube folder and paste it in the PHP extension directory <code><b>C:\php8.2\ext.</b></code>

- Add the below line in your php.ini file at the starting to enable Ioncube.

```
zend_extension = "C:\php8.2\ext\ioncube_loader_win_8.2.dll"
```

<a id="6Install-wkhtmltopdf" 
name="6Install-wkhtmltopdf"></a>

### <strong>6. Install wkhtmltopdf</strong>

Wkhtmltopdf is an open source simple and much effective command-line shell utility that enables user to convert any given HTML (Web Page) to PDF document or an image (jpg, png, etc). It uses WebKit rendering layout engine to convert HTML pages to PDF document without losing the quality of the pages. Its is really very useful and trustworthy solution for creating and storing snapshots of web pages in real-time.

-   <a href="https://wkhtmltopdf.org/downloads.html" target="_blank" rel="noopener">Click Here</a> to download 64-bit wkhtmltopdf-0.12.6-1.exe installer file.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/wkhtmltopdf.png" alt="" style=" width:400px ; height:250px ">

- Run the downloaded <code><b>wkhtmltopdf-0.12.6-1.exe installer</b></code>.

- Click <code><b>I Agree</b></code> on the license agreement screen.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/wkhtmltopdf1.png" alt="" style=" width:400px ; height:250px ">

- Specify the installation destination folder or leave it as default location and click <code><b>Install</b></code>

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/wkhtmltopdf2.png" alt="" style=" width:400px ; height:250px ">

- When installation is complete, click the <code><b>Close</b></code> button.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/wkhtmltopdf3.png" alt="" style=" width:400px ; height:250px ">

- Now copy wkhtmltox.dll located at C:\Program Files\wkhtmltopdf\bin and paste it in C:\php8.2\ext

- Update the Environmet variable for wkhtmltopdf. <code><b>Refer to section (2.a) for adding Environment Variable</b></code>

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/envwkhtml.png" alt="" style=" width:400px ; height:250px ">


<a id="7Upload-Faveo" 
name="7Upload-Faveo"></a>

### <strong>7. Upload Faveo</strong>

- Download the Faveo Helpdesk from <code><b>https://billing.faveohelpdesk.com</b></code> and extract the contents inside IIS Root Directory.
```
C:\inetpub\wwwroot\
```

- Right click on <code><b>wwwroot</b></code> directory and in the security tab click on edit and add user <code><b>IUSR</b></code>. Give full permissions to <code><b>IIS_IUSRS</b></code>, <code><b>IUSR</b></code> and <code><b>Users</b></code> for the wwwroot folder.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/Permission.png?raw=true" alt="" style=" width:400px ; height:250px ">

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/permissioniis.png" alt="" style=" width:400px ; height:250px ">

Give full permissions (same as above) to the Windows Temp folder as well:

```
C:\Windows\Temp
```

<a id="8Configure-Faveo-in-IIS-Manager" 
name="8Configure-Faveo-in-IIS-Manager"></a>

### <strong>8. Configure Faveo in IIS Manager</strong>

- Open IIS Manager and in the left pane, Explore till you find <code><b>Default Web Site</b></code>, select it.
- Then in the right panel, you will see the <code><b>Basic Settings</b></code> option click on it, a new window will open as  shown below:


- Set the <code><b>Physical Path</b></code> value to: 

```
"%SystemDrive%\inetpub\wwwroot\public"
``` 


<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/BasicSettings.png?raw=true" alt="" style=" width:400px ; height:200px ">

<a id="9Configure-web.config-file-for-IIS" 
name="9Configure-web.config-file-for-IIS"></a>

### <strong>9. Configure web.config file for IIS</strong>

- Open notepad and copy the below lines and save the file under the path <code><b>C:\inetpub\wwwroot\public</b></code> as <code><b>web.config</b></code>. Make sure while saving you select all file types.

```
<?xml version="1.0" encoding="UTF-8"?>

<configuration>

    <system.webServer>

        <rewrite>

            <rules>

                <rule name="Imported Rule 1" stopProcessing="true">

                    <match url="^" ignoreCase="false" />

                    <conditions logicalGrouping="MatchAll">

                        <add input="{REQUEST_FILENAME}" matchType="IsDirectory" ignoreCase="false" negate="true" />

                        <add input="{REQUEST_FILENAME}" matchType="IsFile" ignoreCase="false" negate="true" />

                    </conditions>

                    <action type="Rewrite" url="index.php" />

                </rule>

            </rules>

        </rewrite>

    </system.webServer>

</configuration>
```

-   <a href="https://www.iis.net/downloads/microsoft/url-rewrite" target="_blank" rel="noopener">Click Here</a> to download URL Rewrite. Click on <code><b>Install this Extension</b></code> execute the installer and click <code><b>Install</b></code>.
- URL Rewrite enables Web administrators to create powerful rules to implement URLs that are easier for users to remember and easier for search engines to find.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/URL-Rewrite.png" alt="" style=" width:400px ; height:200px ">

<a id="10Setting-up-the-Database" 
name="10Setting-up-the-Database"></a>

### <strong>10. Setting up the Database</strong>

Open MariaDB 10.6 Command Line Client from the start menu and enter the password that you set while installing. Run the below commands to create a database and database user for Faveo Helpdesk.

- Create a database called ‘faveo’.

```sql
CREATE DATABASE faveo;
```

- Create a user called ‘faveo’ and change the <code><b>strongpassword</b></code> with the password of your choice.

```sql
CREATE USER 'faveo'@'localhost' IDENTIFIED BY 'strongpassword';
```

- Grant access to the faveo user to faveo Database.

```sql
GRANT ALL ON faveo.* TO 'faveo'@'localhost';
```

- And finally, we apply the changes and exit the database.

```sql
FLUSH PRIVILEGES;
exit
```


<a id="11Setting-up-Bindings" 
name="11Setting-up-Bindings"></a>

### <strong>11. Setting up Bindings</strong>

- To Open the Faveo on your domain, you must set the binding.

- Open IIS Manager and in the left panel, Explore till you find <code><b>Default Web Site</b></code>, select it.

- Then in the right panel, you will see the <code><b>Bindings</b></code> option click on it, a new window will open select HTTP and edit the hostname to your concerned Domain as  shown below:

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/bindingnew.png" alt="" style=" width:400px ; height:250px ">

- After adding the Bindings we need to edit the <code><b>host file</b></code>, which will present be at this location.

```
C:\Windows\System32\drivers\etc
```

- Add the below line by replacing the 'yourdomain' with the domain that we used in the above step.

```
127.0.0.1            yourdomain
```

- Now you can open the browser and enter the IP or Domain Name to open Faveo.


**Disable WebDav (Optional)**

To test the successful configuration perform some delete operations in Faveo if the Delete operation fails then the above steps are not sufficient at this point you may need to remove WebDav:

- Go to <code><b>Control Panel > Uninstall Program > Turn Windows features on or off > IIS > World Wide Web Services > Common HTTP feature > WebDAV Publishing</b></code>.


<a id="12Configure-Task-Scheduler" 
name="12Configure-Task-Scheduler"></a>

### <strong>12. Set Cron & Configure Queue Driver</strong>

- To open Task scheduler press <code><b>Win+R</b></code> and type <code><b>taskschd.msc</b></code>.
- On the Right pane of the Task scheduler select <code><b>Create Basic Task</b></code> enter a <code><b>Name</b></code> for the task and click <code><b>Next</b></code>.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/TaskScheduler.png?raw=true" alt="" style=" width:400px ; height:250px ">

- Under <code><b>Task Trigger</b></code>, section select <code><b>Daily</b></code> and click <code><b>Next</b></code> and leave the default values in <code><b>Daily</b></code> section tick the <code><b>Synchronize across time zones</b></code> and proceed <code><b>Next</b></code>.

- Now under the <code><b>Action</b></code> section select <code><b>Start a program</b></code> and click <code><b>Next</b></code>. 


- In <code><b>Start a program</b></code> copy the below value into the <code><b>program/script field</b></code>.
```
C:\Windows\System32\cmd.exe
```
- Add the following highlighted values to the Argument :

- This is for faveo incoming mail, esacalation, faveo update check.
```
/c php "c:\inetpub\wwwroot\artisan" schedule:run
```

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/Taskschd.gif?raw=true" alt="" style=" width:400px ; height:250px ">

- Finally under the <code><b>Finish</b></code> section select the <code><b>checkbox</b></code> to open the properties window after finish and click the <code><b>Finish</b></code> button.

- In the properties window, select the <code><b>Triggers</b></code> tab, click on <code><b>Edit</b></code> and select the checkbox for <code><b>Repeat task every</b></code> set values to run every <code><b>5 minutes</b></code>, for a duration of <code><b>indefinitely</b></code> and click on <code><b>OK</b></code>.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/TaskTrigger.png?raw=true" alt="" style=" width:400px ; height:250px ">

- Similarly add two more triggers <code><b>At log on</b></code> & <code><b>At startup up</b></code>, set values to run every <code><b>5 minutes</b></code>, for a duration of <code><b>indefinitely</b></code> and click on <code><b>OK</b></code>.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/trigger.png" alt="" style=" width:400px ; height:250px ">

**Queue Drivers**

A queue driver is the handler for managing how to run a queued job, identifying whether the jobs succeeded or failed, and trying the job again if configured to do so. There are different queue lists are available to be used by the system:

- Sync (Activated by default)
- Database (this will use the database used by the application to act as a queue)
- Redis

- **Sync**, or synchronous, is the default queue driver which runs a queued job within your existing process. With this driver enabled, you effectively have no queue as the queued job runs immediately. When a small number of incoming and outgoing mail functionalities are operated by the system, this sync method can be used. 

- **Database** driver stores queued jobs in the database. In Database queue multiple users need to work on a pool of records in a queue to process them. The records in the queue are in an unprocessed state. After the user worked on any record, that record is in completed state and is removed from the queue.
- Database Queue option lets the emails queue to execute using First in First out (FIFO) method and sends emails to the clients one by one.
- In Database, Read and Write operations are slow because of storing data in secondary memory.

- [Database Configuring documentation](/docs/installation/providers/enterprise/database) 

- **Redis** is an open-source (BSD licensed), in-memory data structure store, used as a database, cache and message broker. This  will improve system performance and is highly recommended.
- In Redis, Read and Write operations are extremely fast because of storing data in primary memory.

- [Redis Installation documentation](/docs/installation/providers/enterprise/redis-windows)

**Note:** Database queue driver must be used only in windows server. C Panel or Linux users should not use database as queue driver.

<a id="13Install-Meilisearch" 
name="13Install-Meilisearch"></a>

### <strong>13. Install Meilisearch</strong>

MeiliSearch is an open-source search engine developed in Rust that delivers flexible search and indexing capabilities. It adeptly handles typos, supports full-text search, synonyms, and comes packed with various features, making it an ideal choice for elevating search functionalities in Faveo.

[Meilisearch installation documentation](/docs/installation/providers/enterprise/meilisearch)

<a id="14SSL-Installation" 
name="14SSL-Installation"></a>

### <strong>14. SSL Installation</strong>

Secure Sockets Layer (SSL) is a standard security technology for establishing an encrypted link between a server and a client. Let’s Encrypt is a free, automated, and open certificate authority.

Faveo Requires HTTPS so the SSL is a must to work with the latest versions of faveo, so for the internal network and if there is no domain for free you can use the Self-Signed-SSL.

- [Let’s Encrypt SSL installation documentation](/docs/installation/providers/enterprise/windows-iis-ssl)


- [Self-Signed SSL installation documentation](/docs/installation/providers/enterprise/self-signed-ssl-windows)


<a id="15Install-Faveo" 
name="15Install-Faveo"></a>

### <strong>15. Install Faveo</strong>

Now you can install Faveo via [GUI](/docs/installation/installer/gui) Wizard or [CLI](/docs/installation/installer/cli)


<a id="16-faveo-backup" name="16-faveo-backup"></a>

### <strong>16. Faveo Backup</strong>


At this stage, Faveo has been installed, it is time to setup the backup for Faveo File System and Database. [Follow this article](/docs/helper/backup) to setup Faveo backup.

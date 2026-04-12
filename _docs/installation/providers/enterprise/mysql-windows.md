---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/mysql-windows/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-04-12
last_modified_by: Mohammad_Asif
toc: true
title: Installing MySQL 8.0 on Windows Server
---


<img alt="Windows" src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Windows_logo_and_wordmark_-_2021.svg/250px-Windows_logo_and_wordmark_-_2021.svg.png" width="200"  /> 


<img alt="mysql" src="https://upload.wikimedia.org/wikipedia/fr/thumb/6/62/MySQL.svg/3840px-MySQL.svg.png" width="200"  />

[<strong>Install MySQL 8.0 on Windows Server</strong>](#Install-MySQL-8.0-on-Windows-Server)

<a href="https://dev.mysql.com/downloads/windows/installer/8.0.html" target="_blank" rel="noopener">Click Here</a> to download *MySQL Installer 8.0* for Windows from official official website.




<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/mysql8.0.png" alt="" style=" width:400px ; height:250px ">

In order to download, you must click *Login,Sign Up*, or click *No thanks, just start my download*.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/mysql3.png?raw=true" alt="" style=" width:400px ; height:250px ">

If prompted, select *Yes* to allow changes to the computer.
After downloading, check the *"I accept"* check box under the License Agreement and click *Next*.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/mysql4.png?raw=true" alt="" style=" width:400px ; height:250px ">

Select the *Setup Type*  as *Server Only* then click *Next*.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/mysql5.png?raw=true" alt="" style=" width:400px ; height:250px ">

To begin installation, click on *Execute*.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/mysql6.png?raw=true" alt="" style=" width:400px ; height:250px ">

When installation is complete, click *Next*.

A walk through product configuration will then appear. Click *Next* to begin.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/mysql7.png?raw=true" alt="" style=" width:400px ; height:250px ">


First, select the Server Configuration Type as shown in below image then click *Next*.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/mysql9.png?raw=true" alt="" style=" width:400px ; height:250px ">

Set an account password, then click *Next*. This Sets the *MysQl Root Password*.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/mysql10.png?raw=true" alt="" style=" width:400px ; height:250px ">

Choose a name for the installed program, choose a user account under which the program will be used, then click *Next*.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/mysql11.png?raw=true" alt="" style=" width:400px ; height:250px ">

Use the Plugins and Extensions window to choose how the program will connect to the server, then click *Next*.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/mysql12.png?raw=true" alt="" style=" width:400px ; height:250px ">

To apply the chosen settings, click *Execute* in the *Apply Server Configuration* window.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/mysql13.png?raw=true" alt="" style=" width:400px ; height:250px ">

When configuration is complete, click *Finish*.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/mysql14.png?raw=true" alt="" style=" width:400px ; height:250px ">

The program will then go back to the *Product Configuration* screen. Click *Next*.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/mysql15.png?raw=true" alt="" style=" width:400px ; height:250px ">

Installation is now complete. Click *Copy Log to Clipboard* to see ReadMe file, or click *Finish*.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/mysql16.png?raw=true" alt="" style=" width:400px ; height:250px ">


MySQL has been successfully installed on your windows server.

Add the System Environmental Variables for Mysql by following the below steps:

Right click on *This PC*, go to Properties > Advanced System Settings > Environment Variables.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/envpath.png" alt="" style=" width:400px ; height:250px ">

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/env2.png" alt="" style=" width:400px ; height:250px ">

Now click on *Path > Edit > New* & add copied path *C:\Program Files\MySQL\MySQL Server 8.0\bin* here and click *OK* in all 3 tabs.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/envpath.png" alt="" style=" width:400px ; height:250px ">

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/envmysql.png" style=" width:400px ; height:250px ">

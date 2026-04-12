---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/mariadb-windows/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-04-12
last_modified_by: Mohammad_Asif
toc: true
title: Installing Mariadb 10.6 on Windows Server
---


<img alt="Windows" src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Windows_logo_and_wordmark_-_2021.svg/250px-Windows_logo_and_wordmark_-_2021.svg.png" width="200"  /> 


<img alt="mariadb" src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/MariaDB_colour_logo.svg/3840px-MariaDB_colour_logo.svg.png" width="200"  />

[<strong>Install MariaDB 10.6  on Windows Server</strong>](#Install-MariaDB-10.6-on-Windows-Server)


<a href="https://downloads.mariadb.org/mariadb/" target="_blank" rel="noopener">Click Here</a> to download  *MariaDB-10.6* from the official MariaDB website.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/mariadb10.6.png" alt="" style=" width:400px ; height:250px ">

Execute the installer and click Next.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/maria1.png" alt="" style=" width:400px ; height:250px ">

Accept the License Agreement and click Next.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/maria2.png?raw=true" alt="" style=" width:400px ; height:250px ">

In the *Custom Setup* section select *MariaDB Server* and click *Next*.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/maria3.png" alt="" style=" width:400px ; height:250px ">

Set the root user password for MariaDB, then click *Next*. 

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/maria4.png" alt="" style=" width:400px ; height:250px ">

In *Default Instance Properties* section leave the default values and click *Next*.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/maria5.png" alt="" style=" width:400px ; height:250px ">

Feedback plugin can be enabled or disabled in the checkbox then click *Next*.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/maria6.png" alt="" style=" width:400px ; height:250px ">

Click *Install* to begin the MariaDB installation.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/maria7.png" alt="" style=" width:400px ; height:250px ">

Click *Finish* to complete the installation.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/maria8.png" alt="" style=" width:400px ; height:250px ">

MariaDB has been successfully installed on your windows server.

Now dd the System Environmental Variables for MariaDB by following the below steps:

Right click on *This PC*, go to *Properties > Advanced System Settings > Environment Variables.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/envpath.png" alt="" style=" width:400px ; height:250px ">

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/env2.png" alt="" style=" width:400px ; height:250px ">

Now click on *Path > Edit > New* & add path *C:\Program Files\MariaDB 10.6\bin* here and click *OK* in all 3 tabs.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/envpath.png" alt="" style=" width:400px ; height:250px ">

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/envmaria.png" style=" width:400px ; height:250px ">


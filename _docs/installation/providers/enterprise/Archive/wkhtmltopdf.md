---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/wkhtmltopdf/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-02-26
toc: true
title: How to Configure WKHTMLTOPDF for PDF Generation in Faveo Helpdesk 
---
<img alt="Wkhtmltopdf" src="https://wkhtmltopdf.org/images/logo.png" width="200"  />

# <strong>Introduction :</strong>
This guide explains how to install and configure WKHTMLTOPDF specifically for generating PDFs within Faveo Helpdesk Enterprise.

WKHTMLTOPDF is used by Faveo to create ticket exports, invoices, and other PDF documents inside the application.

> This documentation is intended only for administrators installing or maintaining Faveo Helpdesk and does not cover general standalone usage of WKHTMLTOPDF.


WKHTMLTOPDF is an open source simple and much effective command-line shell utility that enables user to convert any given HTML (Web Page) to PDF document or an image (jpg, png, etc).

It uses WebKit rendering layout engine to convert HTML pages to PDF document without losing the quality of the pages. Its is really very useful and trustworthy solution for creating and storing snapshots of web pages in real-time.

#  <!-- omit in toc -->
- [<strong>Steps to install wkhtmltopdf for Faveo Helpdesk:</strong>](#steps-to-install-wkhtmltopdf-for-faveo-helpdesk)
    - [<strong> 1. Linux Distros</strong>](#-1-linux-distros)
    - [<strong> 2. Windows Servers</strong>](#-2-windows-servers)
    
  

<a id="-1-linux-distros" name="-1-linux-distros"></a>

### <strong> 1. Linux Distros</strong>

  Follow the below steps to install wkhtmltopdf on your Faveo server.

**For Alma Linux 9, Rocky9 and RHEL9**

Install different fonts to support wkhtmltopdf.

```
yum install -y xorg-x11-fonts-75dpi xorg-x11-fonts-Type1 libpng libjpeg openssl icu libX11 libXext libXrender xorg-x11-fonts-Type1 xorg-x11-fonts-75dpi
```

Download the rpm package from github

```
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox-0.12.6.1-2.almalinux9.x86_64.rpm
```

Install the package.

```
sudo dnf install ./wkhtmltox-0.12.6.1-2.almalinux9.x86_64.rpm
```

**For Ubuntu 18.04, 20.04 and Debain**

For Ubuntu 18.04, 20.04 and Debian type the below command, it will install the package along with all the required fonts.

```
apt-get -y install wkhtmltopdf
```

**For Ubuntu 22.04**

For Ubuntu 22.04 run the below commands to install the package.

```
echo "deb http://security.ubuntu.com/ubuntu focal-security main" | sudo tee /etc/apt/sources.list.d/focal-security.list
apt-get update
apt install libssl1.1 -y
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb 
dpkg -i wkhtmltox_0.12.6-1.focal_amd64.deb
apt --fix-broken install -y
```

<a id="-2-windows-servers" name="-2-windows-servers"></a>

### <strong> 2. Windows Servers</strong>

Follow the below procedure to install wkhtmltopdf plugin for Faveo Helpdesk on windows server with IIS or Apache webserver.


-   <a href="https://wkhtmltopdf.org/downloads.html" target="_blank" rel="noopener">Click Here</a> to download 64-bit wkhtmltopdf-0.12.6-1.exe installer file.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/wkhtmltopdf.png" alt="" style=" width:400px ; height:250px ">

- Run the downloaded *wkhtmltopdf-0.12.6-1.exe installer*.

- Click *I Agree* on the license agreement screen.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/wkhtmltopdf1.png" alt="" style=" width:400px ; height:250px ">

- Specify the installation destination folder or leave it as default location and click *Install*

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/wkhtmltopdf2.png" alt="" style=" width:400px ; height:250px ">

- When installation is complete, click the *Close* button.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/wkhtmltopdf3.png" alt="" style=" width:400px ; height:250px ">

- Now copy wkhtmltox.dll located at C:\Program Files\wkhtmltopdf\bin and paste it in C:\php8.1\ext (C:\php8.1\ext - incase of Apache)

- Update the Environmet variable for wkhtmltopdf.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/envwkhtml.png" alt="" style=" width:400px ; height:250px ">



  



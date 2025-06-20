---
layout: single
permalink: /
type: docs
author_profile: false
toc: true
---

<style>
.button {
  border: none;
  color: black;
  #padding: 15px 32px;
  border-radius:4px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  margin: 4px 2px;
  cursor: pointer;
}
.button1 {background-color: #4CAF50;} /* Green */
.button2 {background-color: #F70A0A;} /* Red */
.NEW {background-color: #FFF933;} /* yellow */
</style>

Welcome to the Faveo installation documentation.
This documentation shows how to install Faveo Helpdesk on various platforms(OS)

# About Faveo
Faveo is a leading open source, self-hosted, on-premise help desk software. 

[Find out more >>](https://www.faveohelpdesk.com){: .btn .btn--info}

# Installing Faveo <!-- omit in toc -->

Faveo can be installed on a variety of platforms. The choice of the platform is yours.

- [About Faveo](#about-faveo)
- [Requirements](#requirements)
- [Installation instructions for specific platforms](#installation-instructions-for-specific-platforms)
- [Installation instructions for Freelancer, Paid, Enterprise and Community editions](#installation-instructions-for-freelancer-paid-enterprise-and-community-editions)
- [Installation on a shared server](#installation-on-a-shared-server)
- [One click installers](#one-click-installers)
- [Installation via scripts](#installation-via-scripts)
- [Help](#help)


## How To's <button class="button NEW"><b>NEW</b></button>
- Upgrade to PHP 8.1 [click here](/docs/installation/providers/enterprise/php-upgrade/)
- Upgrade to PHP 8.2 [click here](/docs/installation/providers/enterprise/php82-upgrade/)
- Migrate or Clone Faveo Helpdesk [click here](/docs/installation/providers/enterprise/generic-migration/)
- Install Wkhtmltopdf [click here](/docs/installation/providers/enterprise/wkhtmltopdf/)
- Faveo Backup Script [click here](/docs/installation/providers/enterprise/backup-script/)
- UrBackup Tool [click here](/docs/installation/providers/enterprise/backup-tool/)
- Custom Domain for Faveo Cloud [click here](/docs/helper/cname)
- Resolve SSL Error for Linux [click here](/docs/installation/providers/enterprise/ssl-error/)
- Install Meilisearch for Faveo [click here](/docs/installation/providers/enterprise/meilisearch/)
- Install Memcached for Faveo [click here](/docs/installation/providers/enterprise/memcached/)
- Enable Websockets for Faveo [click here](/docs/installation/providers/enterprise/websockets/)
- Setup Email Server for Faveo [click here](/docs/helpers/email-server/)
- Configure LDAPS for Faveo [click here](/docs/helpers/ldaps/)
- Secure Server for security implications [click here](/docs/helpers/server-hardening/home)
- Install Node for Graphical reports [click here](/docs/helpers/node)
- Install NATS Server for Agent Software [click here](/docs/helpers/nats)
- Troubleshooting script [click here](/docs/installation/providers/enterprise/basic-troubleshooting-script)


<a id="markdown-requirements" name="requirements"></a>
## Requirements

### **Hardware Requirements**:

The minimum Hardware requirements for faveo to work:
-   **CPU:** 4vCPU
-   **RAM:**  8GiB
-   **Storage:** 40GiB

The above is the minimum requirements for Faveo Helpdesk, and will vary accordingly with the frequency of tickets and workflows.

### **Software Requirements**:

Basically, Faveo depends on the following:

-   **Apache** (with mod_rewrite enabled) or **Nginx** or **IIS**
-   **PHP 8.2.x** with the certain extensions like php-curl, php-gd, php-mbstring, php-pecl-mcrypt, php-mysqlnd, php-odbc, php-pdo etc
-   **Composer**(Optional)
-   **MySQL 8.0.x** or **MariaDB 10.6.x**
-   **Redis** 
-   **Supervisor**

For detailed Software requirements list [check here](/docs/system-requirement/requirement)


<a id="markdown-installation-instructions-for-specific-platforms" name="installation-instructions-for-specific-platforms"></a>
## Installation instructions for specific platforms

The above mentioned prerequisites to be met have to be installed then faveo can be installed in any OS/Distro from the below list:
<a id="markdown-generic-linux-instructions-enterprise" name="generic-linux-instructions-enterprise"></a>
### Installation instructions for Freelancer, Paid, Enterprise and Community editions
* [Alma Linux with Apache](/docs/installation/providers/enterprise/alma9-apache)
* [Alma Linux with Nginx](/docs/installation/providers/enterprise/alma9-nginx)
* [Rocky Linux with Apache](/docs/installation/providers/enterprise/rocky9-apache)
* [Rocky Linux with Nginx](/docs/installation/providers/enterprise/rocky9-nginx)
* [RHEL with Apache](/docs/installation/providers/enterprise/rhel9-apache)
* [RHEL with Nginx](/docs/installation/providers/enterprise/rhel9-nginx)
* [Ubuntu with Apache](/docs/installation/providers/enterprise/ubuntu-apache)<button class="button button1"><b>Recommended</b></button>
* [Ubuntu with NGINX](/docs/installation/providers/enterprise/ubuntu-nginx)
* [Debian with Apache](/docs/installation/providers/enterprise/debian-apache)
* [Debian with NGINX](/docs/installation/providers/enterprise/debian-nginx)
* [Windows IIS](/docs/installation/providers/enterprise/windows-iis)
* [Windows Apache](/docs/installation/providers/enterprise/apache-windows)
* [WAMP](/docs/installation/providers/enterprise/wamp-windows)
* [XAMPP](/docs/installation/providers/enterprise/xampp-windows/)
* [Docker](/docs/installation/providers/enterprise/faveo-helpdesk-docker/)
* [Kubernetes](/docs/installation/providers/enterprise/faveo-helpdesk-k8s/)
* [Network Discovery](/docs/installation/providers/enterprise/network-discovery/)



<a id="markdown-one-click-installer" name="markdown-one-click-installer"></a>
### One click installers 

Faveo Helpdesk Community can be installed using following installers
- **Softaculous** [https://www.softaculous.com/apps/customersupport/Faveo_Helpdesk](https://www.softaculous.com/apps/customersupport/Faveo_Helpdesk)
- **Fantastico** [https://www.netenberg.com/fantastico.php](https://www.netenberg.com/fantastico.php)

<a id="markdown-script-installer" name="markdown-script-installer"></a>
### Installation via scripts 
Bash script to Auto Installation of Faveo Helpdesk on the following Linux Operating System Ubuntu 20.04/22.04, Debian 11, RHEL 9, Rocky 9

- [**Installation via Script**](/docs/installation/providers/enterprise/script-installers/)

<a id="markdown-shared-sever" name="markdown-shared-sever"></a>
### Installation on a shared server <button class="button button2"><b>Not Recommended</b></button>
Faveo can also be installed on a shared server if Emails Incoming/Outgoing is the only requirement, though we highly recommend cloud, VPS or dedicated server for best performance and more control. <br />

<b>Note: </b> In Faveo features like Report generation, Recurring Emails, Notifications etc relies on Redis Database. So if you choose shared hosting like Cpanel. These features will not be available.
* [cPanel](/docs/installation/providers/community/cpanel)

<a id="markdown-script-troubleshooting" name="markdown-script-troubleshooting"></a>
### Troubleshooting via script
Basic script to troubleshoot Faveo Helpsdesk

- [**Troubleshooting via script**](/docs/installation/providers/enterprise/basic-troubleshooting-script)

<a id="markdown-help" name="markdown-help"></a>
## Help

If you'd like professional help commercial support is available, email us through the [contact form](https://www.faveohelpdesk.com/contact-us/).

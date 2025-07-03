---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/network-discovery/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-07-03
last_modified_by: Mohammad_Asif
toc: true
title: Installing Faveo Network Discovery Tool on Linux Distributions.
---

[<strong>Introduction :</strong>](#introduction:) 

Faveo Network Discovery is a self-hosted software that can be installed on your local on-premisis Linux Servers. While this installation document provides a step-by-step guide during the installation, it’s essential and helpful to have general knowledge about Web Servers, PHP and MySQL.

---

> **NOTE:** The Installation steps for Faveo Network Discovery Tool  are same as that of **Faveo Helpdesk**. You only need to follow the below instructions in addition to the Faveo Helpdesk documentation. 

---

Faveo Network Discovery Tool can run on the Linux Distributions listed below. Choose your Linux Distribution and follow the instructions:

- [<strong>Installation steps :</strong>](#installation-steps-) 
    - [<strong>1. Rocky Linux 9</strong>](#1-rocky-linux-9)
    - [<strong>2. Alma Linux 9:</strong>](#2-alma-linix-9)
    - [<strong>3. RHEL 9</strong>](#3-rhel-9)
    - [<strong>4. Ubuntu 20.04 & 22.04</strong>](#4-ubuntu-20.04-&-22.04)
    - [<strong>5. Debian 11 & 12</strong>](#5-debian-11-&-12)
 

 Faveo Network Discovery uses the below protocols to gather the information about the Assets/Devices present on a network.

- SSH
- NMAP
- SNMP

Also PING should be enabled on the devices to be scanned.

The below ports should be Open on the Faveo Network Discovery Server:

- HTTP: 80
- HTTPS: 443
- Redis: 6379
- SMTP: 587
- SSH: 22
- SNMP: 161, 162


---


<a id="1-rocky-linux-9" name="1-rocky-linux-9"></a>

### <strong>1. Rocky Linux 9</strong>

<a href="https://docs.faveohelpdesk.com/docs/installation/providers/enterprise/rocky9-apache/" target="_blank" rel="noopener">Click Here</a> to follow the installation steps of Faveo Helpdesk.

After following the installation document of Faveo Helpdesk till step 7, you need to follow the below steps for Faveo Network Discovery Tool.

Package Installation:

```
dnf install -y nmap arp-scan nbtscan net-tools avahi-tools
```

```
yum -y install php-snmp
```

Sudo Configuration:

```
visudo
```

Add the following lines to allow the apache user to run arp-scan and nmap without a password:

```
apache ALL=NOPASSWD: /usr/sbin/arp-scan
apache ALL=NOPASSWD: /usr/bin/nmap
```

Now you can now install Faveo Network Discovery Tool via <a href="https://docs.faveohelpdesk.com/docs/installation/installer/gui/" target="_blank" rel="noopener">GUI</a>

---


<a id="2-alma-linix-9" name="2-alma-linix-9"></a>

### <strong>2. Alma Linux 9</strong>

<a href="https://docs.faveohelpdesk.com/docs/installation/providers/enterprise/alma9-apache/" target="_blank" rel="noopener">Click Here</a> to follow the installation steps of Faveo Helpdesk.

After following the installation document of Faveo Helpdesk till step 7, you need to follow the below steps for Faveo Network Discovery Tool.

Package Installation:

```
dnf install -y nmap arp-scan nbtscan net-tools avahi-tools
```

```
yum -y install php-snmp
```

Sudo Configuration:

```
visudo
```

Add the following lines to allow the apache user to run arp-scan and nmap without a password:

```
apache ALL=NOPASSWD: /usr/sbin/arp-scan
apache ALL=NOPASSWD: /usr/bin/nmap
```

Now you can now install Faveo Network Discovery Tool via <a href="https://docs.faveohelpdesk.com/docs/installation/installer/gui/" target="_blank" rel="noopener">GUI</a>

---


<a id="3-rhel-9" name="3-rhel-9"></a>

### <strong>3. RHEL 9</strong>

<a href="https://docs.faveohelpdesk.com/docs/installation/providers/enterprise/rhel9-apache/" target="_blank" rel="noopener">Click Here</a> to follow the installation steps of Faveo Helpdesk.

After following the installation document of Faveo Helpdesk till step 7, you need to follow the below steps for Faveo Network Discovery Tool.

Package Installation:

```
dnf install -y nmap arp-scan nbtscan net-tools avahi-tools
```

```
yum -y install php-snmp
```

Sudo Configuration:

```
visudo
```

Add the following lines to allow the apache user to run arp-scan and nmap without a password:

```
apache ALL=NOPASSWD: /usr/sbin/arp-scan
apache ALL=NOPASSWD: /usr/bin/nmap
```

Now you can now install Faveo Network Discovery Tool via <a href="https://docs.faveohelpdesk.com/docs/installation/installer/gui/" target="_blank" rel="noopener">GUI</a>

---


<a id="4-ubuntu-20.04-&-22.04" name="4-ubuntu-20.04-&-22.04"></a>

### <strong>4. Ubuntu 20.04 & 22.04</strong>

<a href="https://docs.faveohelpdesk.com/docs/installation/providers/enterprise/ubuntu-apache/" target="_blank" rel="noopener">Click Here</a> to follow the installation steps of Faveo Helpdesk.

After following the installation document of Faveo Helpdesk till step 8, you need to follow the below steps for Faveo Network Discovery Tool.

Package Installation (for each version):

```
apt install -y nmap arp-scan nbtscan avahi-utils net-tools
```

```
apt install -y php8.2-snmp
```

Sudo Configuration:

```
visudo
```

Add the following lines to allow the www-data user to run arp-scan and nmap without a password for each Ubuntu version:

```
www-data ALL=NOPASSWD: /usr/sbin/arp-scan
www-data ALL=NOPASSWD: /usr/bin/nmap
```

Now you can now install Faveo Network Discovery Tool via <a href="https://docs.faveohelpdesk.com/docs/installation/installer/gui/" target="_blank" rel="noopener">GUI</a>

---



<a id="5-debian-11-&-12" name="5-debian-11-&-12"></a>

### <strong>5. Debian 11 & 12</strong>

<a href="https://docs.faveohelpdesk.com/docs/installation/providers/enterprise/debian-apache/" target="_blank" rel="noopener">Click Here</a> to follow the installation steps of Faveo Helpdesk.

After following the installation document of Faveo Helpdesk till step 7, you need to follow the below steps for Faveo Network Discovery Tool.

Package Installation:

```
apt install -y nmap arp-scan nbtscan avahi-utils net-tools
```

```
apt install -y php8.2-snmp
```

Sudo Configuration:

```
visudo
```

Add the following lines to allow the www-data user to run arp-scan and nmap without a password:

```
www-data ALL=NOPASSWD: /usr/sbin/arp-scan
www-data ALL=NOPASSWD: /usr/bin/nmap
```

Now you can now install Faveo Network Discovery Tool via <a href="https://docs.faveohelpdesk.com/docs/installation/installer/gui/" target="_blank" rel="noopener">GUI</a>
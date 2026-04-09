---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/alma-apache-ssl/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-04-09
last_modified_by: Mohammad_Asif
toc: true
title: Install LetsEncrypt SSL for Faveo on Alma Linux Running Apache Web Server
---


<img alt="Alma Linux Logo" src="https://upload.wikimedia.org/wikipedia/commons/0/0e/Almalinux_logo.png" width="200"  />


## Introduction
This document will list on how to install Let’s Encrypt SSL on Alma Linux Running Apache Web Server

PS : Please replace example.com with your valid domain name which is mapped with your server

We will install following dependencies in order to make Let’s Encrypt SSL work:

- epel-release
- mod_ssl
- python-certbot-apache

## Installing dependent modules

```sh
yum install -y epel-release mod_ssl
```

## Downloading the LetsEncrypt for Amla Linux

```sh
yum install -y python3-certbot-apache
```

```sh
systemctl restart httpd.service
```

## Setting up the SSL certificate

Certbot will handle the SSL certificate management quite easily, it will generate a new certificate for provided domain as a parameter.

In this case, example.com will be used as the domain for which the certificate will be issued:

```sh
certbot --apache -d example.com
```

If you want to generate SSL for multiple domains or subdomains, please run this command:

```sh
certbot --apache -d example.com -d www.example.com
```

**PS :** IMPORTANT! The first domain should be your base domain, in this sample it’s example.com

## Setting up auto renewal of the certificate

Create new cron job for automatic renewal of SSL

This job can be safely scheduled to run every Monday at midnight:

Create a new `/etc/cron.d/faveo-ssl` file with:

```sh
echo "45 2 * * 6 /etc/letsencrypt/ && ./certbot renew && /bin/systemctl restart httpd.service" | sudo tee /etc/cron.d/faveo-ssl
```

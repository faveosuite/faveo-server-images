---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/ubuntu-apache-ssl/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-04-09
last_modified_by: Mohammad_Asif
toc: true
title: Install LetsEncrypt SSL for Faveo on Ubuntu Server Running Apache Web Server
---

<img alt="Ubuntu" src="https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Logo-ubuntu_cof-orange-hex.svg/120px-Logo-ubuntu_cof-orange-hex.svg.png" width="120" height="120" />

## Introduction
This document will list on how to install LetsEncrypt SSL on Ubuntu Running Apache Web Server

PS : Please replace example.com with your valid domain name which is mapped with your server

We will install following dependencies in order to make LetsEncrypt SSL work:

- python-certbot-apache
## Downloading the LetsEncrypt client 

```sh
apt install python3-certbot-apache
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
echo "45 2 * * 6 /etc/letsencrypt/ && ./certbot renew && systemctl restart apache2 " | sudo tee /etc/cron.d/faveo-ssl
```

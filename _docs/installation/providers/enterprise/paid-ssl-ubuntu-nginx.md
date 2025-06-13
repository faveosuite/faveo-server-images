---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/paid-ssl-ubuntu-nginx/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-06-13
last_modified_by: Sivakumar
toc: true
title: Install Paid SSL for Faveo on Ubuntu
---


<img alt="Ubuntu" src="https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Logo-ubuntu_cof-orange-hex.svg/120px-Logo-ubuntu_cof-orange-hex.svg.png" width="120" height="120" />

## Introduction

This document will guide on how to install Paid SSL certificates on Ubuntu with NGINX.

## Obtain SSL Certificate and CA Certificate

1. Obtain your SSL certificate (`your_domain.crt`) and private key (`your_domain.key`) from your SSL certificate provider.
2. If applicable, also obtain the CA certificate (`your_domain-CA.crt`) from your SSL provider.

## Setting up the Virtual host file for the Paid SSL certificate's.

- Before creating the Virtual host file for SSL we need to copy the created SSL certificate's and Key file to the corresponding directory with below command, these commands should be runned from the SSL Directory.
```
cp your_domain.crt /etc/ssl/certs
cp your_domain.key /etc/ssl/private
cp your_domain-CA.crt /usr/local/share/ca-certificates/
```
- Then adding the Virtual host file, for that we need to create a file in webserver directory as <b> /etc/nginx/sites-available/faveo.conf</b>

```
nano /etc/nginx/sites-available/faveo.conf
```

- Then need to copy the below configuration inside the faveo.conf file.

```
server {
    listen 80;
    listen [::]:80;
    root /var/www/faveo/public;
    index  index.php index.html index.htm;
    server_name  ---DomainName or IP---;

     client_max_body_size 100M;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
               include snippets/fastcgi-php.conf;
               fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
               fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
               include fastcgi_params;
    }
    listen 443 ssl;
    ssl_certificate /etc/ssl/certs/your_domain.crt;
    ssl_certificate_key /etc/ssl/private/your_domain.key;
    ssl_trusted_certificate /usr/local/share/ca-certificates/your_domain-CA.crt;
}
```

## After Creating the Virtual Host file we need to enable the Nginx SSL virtual host configuration and add the local host for the domain.
- Then need to enable the Nginx SSL virtual host configuration.
```
sudo ln -s /etc/nginx/sites-available/faveo-ssl.conf /etc/nginx/sites-enabled/
```
- Then need to update the CA certificate's to that run the below command.
```
sudo update-ca-certificates
```

- After adding the SSL certificates and virtual hosts we need to add the domain to the hosts file to the local host as below.
```
nano /etc/hosts
```
- In the above file add the below line replace the domain or the IP which is used for the faveo.
```
127.0.0.1  ---Domain or IP---
```
- After the above is done then we need to add the the ca-cert file path to the <b>/etc/php/8.2/fpm/php.ini</b> file add the path to the openssl.cafile like this : 
```
openssl.cafile = "/usr/local/share/ca-certificates/your_domain-CA.crt"
```
- After adding the above path restart the webserver and php-fpm service.
```
systemctl restart php8.2-fpm
systemctl restart nginx
```

- Now check the faveo on the Browser it will take you to probe page, if everything is good then you can proceed with the installation in Browser.

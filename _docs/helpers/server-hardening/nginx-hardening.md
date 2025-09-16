---
layout: single
type: docs
permalink: /docs/helpers/server-hardening/nginx-hardening
redirect_from:
  - /theme-setup/
last_modified_at: 2024-09-12
last_modified_by: Mohammad_Asif
toc: true
title: "Nginx Hardening for Security Implications"
---

<img alt="NGINX" src="https://linuxctl.com/images/thumb/cover-nginx.png"/>

The web server has a crucial role in web-based applications. Since most of us leave it to the default configuration, it can leak sensitive data regarding the web server.

By applying numerous configuration tweaks, we can make NGINX more resilient against malicious attacks. Following are some NGINX hardening tips that you can incorporate to improve security.


 - [<strong>1. Hide NGINX Version</strong>](#1Hide-NGINX-Version)
 - [<strong>2. Disable Unnecessary HTTP Methods</strong>](#2Disable-Unnecessary-HTTP-Methods)
 - [<strong>3. Disable Directory Listing</strong>](#3Disable-Directory-Listing)
 - [<strong>4. Click Jacking defense with X-Frame Options</strong>](#4Click-Jacking-defense-with-X-Frame-Options)
 - [<strong>5. Basic XSS Protection</strong>](#5Basic-XSS-Protection)
 - [<strong>6. Enable HttpOnly and Secure Flag</strong>](#6Enable-HttpOnly-and-Secure-Flag)
 - [<strong>7. Disable ETag</strong>](#7Disable-ETag)
 - [<strong>8. Enable HTTP/2 Protocol</strong>](#8Enable-HTTP/2-Protocol)
 - [<strong>9. Set Referrer Policy</strong>](#9Set-Referrer-Policy)
 - [<strong>10. Set Permissions Policy</strong>](#10Set-Permissions-Policy)
 - [<strong>11. Enforce HSTS (HTTP Strict Transport Security)</strong>](#11Enforce-HSTS-HTTP-Strict-Transport-Security)
---


<a id="1Hide-NGINX-Version" name="1Hide-NGINX-Version"></a>

<strong>1. Hide NGINX Version</strong>

Hiding the NGINX version number can prevent attackers from using known vulnerabilities specific to your NGINX version. Exposing the Nginx version can provide attackers with useful information for targeting known vulnerabilities. To hide the version:

Edit the NGINX configuration file:

- RHEL Based Servers
```
sudo nano /etc/nginx/nginx.conf
```

- Debian Based Servers
```
sudo nano /etc/nginx/sites-available/faveo.conf
```

Find the `http` block and add the following line:
```
server_tokens off;
```

Save and exit the file.
```
ctrl + x
```

Restart NGINX:
```
sudo systemctl restart nginx
```

The `server_tokens off;` directive disables the display of the NGINX version in HTTP headers and error pages.


<a id="2Disable-Unnecessary-HTTP-Methods" name="2Disable-Unnecessary-HTTP-Methods"></a>

<strong>2. Disable Unnecessary HTTP Methods</strong>

Limiting HTTP methods helps to prevent attacks that exploit certain HTTP methods.

Edit the NGINX configuration file:

- RHEL Based Servers
```
sudo nano /etc/nginx/nginx.conf
```

- Debian Based Servers
```
sudo nano /etc/nginx/sites-available/faveo.conf
```

Find the `http` block and add the following line:
```
if ($request_method !~ ^(GET|POST|HEAD)$ ) {
    return 444;
}
```

Save and exit the file.
```
ctrl + x
```

Restart NGINX:
```
sudo systemctl restart nginx
```

This configuration will return a `444 No Response` status code for requests using HTTP methods other than GET, POST, and HEAD, which helps mitigate risks..


<a id="3Disable-Directory-Listing" name="3Disable-Directory-Listing"></a>

<strong>3. Disable Directory Listing</strong>

Directory listing should be disabled to prevent exposure of sensitive files and directory contents.

Edit the NGINX configuration file:

- RHEL Based Servers
```
sudo nano /etc/nginx/nginx.conf
```

- Debian Based Servers
```
sudo nano /etc/nginx/sites-available/faveo.conf
```

Find the `http` block and add the following line:
```
location / {
    autoindex off;
}
```
For Faveo Helpdesk, we can skip this step as we have already enabled it in default configuration file as below:
```
location / {
            try_files $uri $uri/ /index.php?$query_string;
        }
```

Save and exit the file.
```
ctrl + x
```

Restart NGINX:
```
sudo systemctl restart nginx
```

The `autoindex off;` directive disables directory listing.


<a id="4Clickjacking-Defense-with-X-Frame-Options" name="4Clickjacking-Defense-with-X-Frame-Options"></a>

<strong>4. Clickjacking Defense with X-Frame-Options</strong>

To prevent your content from being used in a frame, which could be exploited for clickjacking attacks:

Edit the NGINX configuration file:

- RHEL Based Servers
```
sudo nano /etc/nginx/nginx.conf
```

- Debian Based Servers
```
sudo nano /etc/nginx/sites-available/faveo.conf
```

Find the `http` block and add the following line:
```
add_header X-Frame-Options "SAMEORIGIN";
```

Save and exit the file.
```
ctrl + x
```

Restart NGINX:
```
sudo systemctl restart nginx
```

The `add_header X-Frame-Options "SAMEORIGIN";` directive ensures that your content can only be framed by pages from the same origin.


<a id="5Basic-XSS-Protection" name="5Basic-XSS-Protection"></a>

<strong>5. Basic XSS Protection</strong>

Enabling XSS protection in modern browsers helps prevent cross-site scripting attacks.

Edit the NGINX configuration file:

- RHEL Based Servers
```
sudo nano /etc/nginx/nginx.conf
```

- Debian Based Servers
```
sudo nano /etc/nginx/sites-available/faveo.conf
```

Find the `http` block and add the following line:
```
add_header X-XSS-Protection "1; mode=block";
```

Save and exit the file.
```
ctrl + x
```

Restart NGINX:
```
sudo systemctl restart nginx
```

The `add_header X-XSS-Protection "1; mode=block";` directive enables the XSS filter built into modern browsers.

<a id="6Enable-HttpOnly-and-Secure-Flags-for-Cookies" name="6Enable-HttpOnly-and-Secure-Flags-for-Cookies"></a>

<strong>6. Enable HttpOnly and Secure Flags for Cookies</strong>

Setting HttpOnly and Secure flags for cookies helps protect them from theft via client-side scripts and ensures they are only sent over HTTPS.

Edit the NGINX configuration file:

- RHEL Based Servers
```
sudo nano /etc/nginx/nginx.conf
```

- Debian Based Servers
```
sudo nano /etc/nginx/sites-available/faveo.conf
```

Find the `http` block and add the following line:
```
http {
    ...
    add_header Set-Cookie "HttpOnly;Secure";
    ...
}
```

Save and exit the file.
```
ctrl + x
```

Restart NGINX:
```
sudo systemctl restart nginx
```

The `add_header Set-Cookie "HttpOnly;Secure";` directive ensures that cookies are marked as HttpOnly and Secure.

<p class="notice--warning">
Note: This has been handled on code level so we will not add it to the final conf file.
</p>


<a id="7Disable-ETag" name="7Disable-ETag"></a>

<strong>7. Disable ETag</strong>

Disabling ETags helps prevent leaking information about the server. Disabling them can enhance privacy.

Edit the NGINX configuration file:

- RHEL Based Servers
```
sudo nano /etc/nginx/nginx.conf
```

- Debian Based Servers
```
sudo nano /etc/nginx/sites-available/faveo.conf
```

Find the `http` block and add the following line:
```
server {
    ...
    add_header ETag "";
    ...
}
```

Save and exit the file.
```
ctrl + x
```

Restart NGINX:
```
sudo systemctl restart nginx
```

The `add_header ETag "";` directive disables the generation of ETag headers.

<a id="8Enable-HTTP/2-Protocol" name="8Enable-HTTP/2-Protocol"></a>

<strong>8. Enable HTTP/2 Protocol</strong>

Enabling HTTP/2 can improve performance and security over HTTP/1.1..

Edit the NGINX configuration file:

- RHEL Based Servers
```
sudo nano /etc/nginx/nginx.conf
```

- Debian Based Servers
```
sudo nano /etc/nginx/sites-available/faveo.conf
```

Find the `http` block and add the following line:
```
listen 443 ssl http2;
```

Save and exit the file.
```
ctrl + x
```

Restart NGINX:
```
sudo systemctl restart nginx
```

The `listen 443 ssl http2;` directive enables HTTP/2 for improved performance.


<a id="9Set-Referrer-Policy" name="9Set-Referrer-Policy"></a>

<strong>9. Set Referrer Policy</strong>

A referrer policy can prevent sensitive information from being leaked in HTTP referrer headers. Setting a strict referrer policy enhances privacy and security.

Edit the NGINX configuration file:

- RHEL Based Servers
```
sudo nano /etc/nginx/nginx.conf
```

- Debian Based Servers
```
sudo nano /etc/nginx/sites-available/faveo.conf
```

Find the `http` block and add the following line:
```
add_header Referrer-Policy "strict-origin";
```

Save and exit the file.
```
ctrl + x
```

Restart NGINX:
```
sudo systemctl restart nginx
```

The `add_header Referrer-Policy "strict-origin";` directive sets a referrer policy that restricts referrer information sent with requests.


<a id="10Set-Permissions-Policy" name="10Set-Permissions-Policy"></a>

<strong>10. Set Permissions Policy</strong>

Implementing a permissions policy can enhance the security of your site by controlling the use of certain features. Permissions policies (formerly known as Feature Policy) control which features and APIs can be used in your web application.

Edit the NGINX configuration file:

- RHEL Based Servers
```
sudo nano /etc/nginx/nginx.conf
```

- Debian Based Servers
```
sudo nano /etc/nginx/sites-available/faveo.conf
```

Find the `http` block and add the following line:
```
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()";
```

Save and exit the file.
```
ctrl + x
```

Restart NGINX:
```
sudo systemctl restart nginx
```

The `add_header Permissions-Policy "geolocation=(), microphone=(), camera=()";` directive restricts access to certain features.

<a id="11Enforce-HSTS-HTTP-Strict-Transport-Security" name="11Enforce-HSTS-HTTP-Strict-Transport-Security"></a>

<strong>11. Enforce HSTS-HTTP Strict Transport Security</strong>

Enforcing HSTS ensures that browsers only connect to your server over HTTPS.

Edit the NGINX configuration file:

- RHEL Based Servers
```
sudo nano /etc/nginx/nginx.conf
```

- Debian Based Servers
```
sudo nano /etc/nginx/sites-available/faveo.conf
```

Find the `http` block and add the following line:
```
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
```

Save and exit the file.
```
ctrl + x
```

Restart NGINX:
```
sudo systemctl restart nginx
```

The `add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";` directive enforces HSTS for one year and includes all subdomains.

## Nginx Virtual Host Configuration for Security Hardening

Here is the combined configuration for Debian-based systems, summarized from all 11 points, to be placed in the virtual host configuration files. Here we are directly making changing in a single virtual host file for a particular website.

### Enabling and Applying Configuration:

Edit the NGINX configuration file:
```
sudo nano /etc/nginx/sites-available/faveo.conf
```

Edit or create the site-specific configuration file:

```nginx
server {
    root /var/www/faveo/public;
    index index.php index.html index.htm;
    server_name helpdesk.example.com;

    client_max_body_size 100M;

    location / {
        try_files $uri $uri/ /index.php?$query_string;       

#1. Hide NGINX Version
        server_tokens off;
#2. Disable Unnecessary HTTP Methods
if ($request_method !~ ^(GET|POST|HEAD)$ ) {
    return 444;
}


# Security Headers
#4. Clickjacking Defense with X-Frame-Options
add_header X-Frame-Options "SAMEORIGIN";
#5. Basic XSS Protection
add_header X-XSS-Protection "1; mode=block";
#6. Enable HttpOnly and Secure Flags for Cookies
add_header Set-Cookie "HttpOnly;Secure";
#7. Disable ETag 
#add_header ETag "";
etag off;
#9. Set Referrer Policy
add_header Referrer-Policy "strict-origin";
#10. Set Permissions Policy
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()";
#11. Enforce HSTS (HTTP Strict Transport Security)
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";

    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

#8. Enable HTTP/2 Protocol
    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl http2; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/helpdesk.example.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/helpdesk.example.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
server {
    if ($host = helpdesk.example.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    listen [::]:80;
    server_name helpdesk.example.com;
    return 404; # managed by Certbot


}
```

Please make sure that the server name/domain is changed at all locations and ssl paths are correct.

Save and exit the file.
```
ctrl + x
```

Restart NGINX:
```
sudo systemctl restart nginx
```

## Nginx Virtual Host Configuration for Security Hardening

Here is the combined configuration for Debian-based systems, summarized from all 11 points, to be placed in the virtual host configuration files. Here we are directly making changing in a single virtual host file for a particular website.

### Enabling and Applying Configuration:

Edit the NGINX configuration file:
```
sudo nano /etc/nginx/nginx.conf
```

Edit or create the site-specific configuration file:

```

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

#Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
#6. Enable HttpOnly and Secure Flags for Cookies
#    add_header Set-Cookie "HttpOnly;Secure";

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        server_name  helpdesk.example.com;
        root         /var/www/faveo/public/;
        index index.php index.html index.htm;

#1. Hide NGINX Version
        server_tokens off; # Disable server tokens for security
#2. Disable Unnecessary HTTP Methods
	if ($request_method !~ ^(GET|POST|HEAD)$ ) {
	    return 444;
	}


        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        # This is for user friendly URL 
        location ~ \.php$ {
            try_files $uri =404;
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }

        location / {
            try_files $uri $uri/ /index.php?$query_string;
#3. Disable Directory listing
	    autoindex off;
        }

# Security Headers
#4. Clickjacking Defense with X-Frame-Options
add_header X-Frame-Options "SAMEORIGIN";
#5. Basic XSS Protection
add_header X-XSS-Protection "1; mode=block";
#7. Disable ETag 
#add_header ETag "";
etag off;
#9. Set Referrer Policy
add_header Referrer-Policy "strict-origin";
#10. Set Permissions Policy
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()";
#11. Enforce HSTS (HTTP Strict Transport Security)
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";



        location ~* \.html$ {
            expires -1;
        }

        location ~* \.(css|gif|jpe?g|png)$ {
            expires 1M;
            add_header Pragma public;
            add_header Cache-Control "public, must-revalidate, proxy-revalidate";
        }

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    
#8. Enable HTTP/2 Protocol
    listen 443 ssl http2; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/helpdesk.example.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/helpdesk.example.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}

    gzip on;
    gzip_http_version 1.1;
    gzip_vary on;
    gzip_comp_level 6;
    gzip_proxied any;
    gzip_types application/atom+xml
               application/javascript
               application/json
               application/vnd.ms-fontobject
               application/x-font-ttf
               application/x-web-app-manifest+json
               application/xhtml+xml
               application/xml
               font/opentype
               image/svg+xml
               image/x-icon
               text/css
               text/plain
               text/xml;
    gzip_buffers 16 8k;
    gzip_disable "MSIE [1-6]\.(?!.*SV1)";



    server {
    if ($host = helpdesk.example.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


        server_name  helpdesk.example.com;
    listen 80;
    return 404; # managed by Certbot


}}

```

Please make sure that the server name/domain is changed at all locations and ssl paths are correct.

Save and exit the file.
```
ctrl + x
```

Restart NGINX:
```
sudo systemctl restart nginx
```

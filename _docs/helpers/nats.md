---
layout: single
type: docs
permalink: /docs/helpers/nats/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-09-22
last_modified_by: Mohammad_Asif
toc: true
title: "Install NATS Server on Faveo Helpdesk Server"
---

This document is for clients using the Agent Software. NATS Server needs to be installed on the Faveo Server to ensure the Agents (Assets) data is received/listened to by the Faveo Server. This guide outlines the steps to install and configure the NATS server on a Faveo Helpdesk server.

- [1. Installing the NATS Server](#1-installing-the-nats-server)  
- [2. Configure NATS as a Systemd Service](#2-configure-nats-as-a-systemd-service)  
- [3. Supervisor Configuration](#3-supervisor-configuration)  
- [4. Proxy Configuration](#4-proxy-configuration)  
  - [4.a Apache Configuration](#4a-apache-configuration)  
  - [4.b NGINX Configuration](#4b-nginx-configuration)  

---

<a id="1-installing-the-nats-server" name="1-installing-the-nats-server"></a>
### **1. Installing the NATS Server**

### Download the NATS Server Binary
Find the latest version of NATS Server from the <a href="https://github.com/nats-io/nats-server/releases" target="_blank" rel="noopener">official NATS releases</a>   and replace <code><b>2.10.24</b></code> in the URL below with the desired version:

```
curl -L https://github.com/nats-io/nats-server/releases/download/v2.10.24/nats-server-v2.10.24-linux-amd64.zip -o nats-server.zip
```

### Extract and Move the Binary
Extract the downloaded file and place the binary in a system-wide path:

```
unzip nats-server.zip -d nats-server
sudo cp nats-server/nats-server-v2.10.24-linux-amd64/nats-server /usr/local/bin/
```

> NOTE: Replace <code><b>2.10.24</b></code> with the downloaded version.

### Verify the Installation
Ensure NATS is installed correctly:

```
nats-server --version
```

<a id="2-configure-nats-as-a-systemd-service" name="2-configure-nats-as-a-systemd-service"></a>
### **2. Configure NATS as a Systemd Service**
 
Ensure the NATS configuration file exists at <code><b>/var/www/faveo/nats.conf</b></code>. This path is used in the below Service file. 

### Create a Systemd Service File
Create a service file for NATS:

```
sudo nano /etc/systemd/system/nats.service
```

Add the following content: 

- For Debian Based Servers:

```
[Unit]
Description=NATS Server
After=network.target

[Service]
PrivateTmp=true
Type=simple
ExecStart=/usr/local/bin/nats-server -c /var/www/faveo/nats.conf
ExecReload=/usr/bin/kill -s HUP $MAINPID
ExecStop=/usr/bin/kill -s SIGINT $MAINPID
User=www-data
Group=www-data
Restart=always
RestartSec=5s
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
```

- For RHEL Based Servers:

```
[Unit]
Description=NATS Server
After=network.target

[Service]
PrivateTmp=true
Type=simple
ExecStart=/usr/local/bin/nats-server -c /var/www/faveo/nats.conf
ExecReload=/usr/bin/kill -s HUP $MAINPID
ExecStop=/usr/bin/kill -s SIGINT $MAINPID
User=apache
Group=apache
Restart=always
RestartSec=5s
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
```

### Enable and Start the Service
Reload systemd and start the service:

```
sudo systemctl daemon-reload
sudo systemctl enable nats
sudo systemctl start nats
sudo systemctl status nats
```


<a id="3-supervisor-configuration" name="3-supervisor-configuration"></a>
### **3. Supervisor Configuration**

Add the below contents to the supervisor conf file.

### For Debian Based Systems
Open the file with nano editor.

```
nano /etc/supervisor/conf.d/faveo-worker.conf
```

Add the below configurations at the end of the file.

```
[program:faveo-Nats]
process_name=%(program_name)s
command=php /var/www/faveo/artisan nats:listen
autostart=true
autorestart=true
user=www-data
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/nats-worker.log
```

Restart Supervisor

```
systemctl restart supervisor
```

Check the service status.

```
supervisorctl
```


### For RHEL Based Systems
Open the file with nano editor.

```
nano /etc/supervisord.d/faveo-worker.ini
```

Add the below configurations at the end of the file.

```
[program:faveo-Nats]
process_name=%(program_name)s
command=php /var/www/faveo/artisan nats:listen
autostart=true
autorestart=true
user=apache
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/nats-worker.log
```

Restart Supervisor

```
systemctl restart supervisord
```

Check the service status.

```
supervisorctl
```


<a id="4-proxy-configuration" name="4-proxy-configuration"></a>
### **4. Proxy Configuration**

Faveo requires a reverse proxy configuration so that the NATS WebSocket connection can be securely proxied through your web server.  
Please follow the configuration instructions based on the web server installed on your system(Apache or NGINX). 

---

<a id="4a-apache-configuration" name="4a-apache-configuration"></a>
### **4a. Apache Configuration**
 
Make the changes in the SSL conf files as below:

For Debian Based Servers:

```
nano /etc/apache2/sites-available/faveo-ssl.conf
```

For RHEL Based Servers:

```
nano /etc/httpd/conf.d/faveo-ssl.conf
```

Add the following proxy configuration for Apache (inside <VirtualHost> block):

```
ProxyPass "/natsws" "ws://127.0.0.1:9235/"
ProxyPassReverse "/natsws" "ws://127.0.0.1:9235/"
Header always set Upgrade "websocket"
Header always set Connection "Upgrade"
Header always set X-Forwarded-Host %{HTTP_HOST}e
Header always set X-Forwarded-For %{REMOTE_ADDR}e
Header always set X-Forwarded-Proto %{HTTPS}e
```

Example:
```
<IfModule mod_ssl.c>
    <VirtualHost *:443>
        ServerName --DOMAINNAME--
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/faveo/public

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        SSLEngine on
        SSLCertificateFile      /etc/ssl/certs/faveolocal.crt
        SSLCertificateKeyFile   /etc/ssl/private/private.key
        SSLCertificateChainFile /usr/local/share/ca-certificates/faveorootCA.crt

        # NATS Proxy
        ProxyPass "/natsws" "ws://127.0.0.1:9235/"
        ProxyPassReverse "/natsws" "ws://127.0.0.1:9235/"
        Header always set Upgrade "websocket"
        Header always set Connection "Upgrade"
        Header always set X-Forwarded-Host %{HTTP_HOST}e
        Header always set X-Forwarded-For %{REMOTE_ADDR}e
        Header always set X-Forwarded-Proto %{HTTPS}e
    </VirtualHost>
</IfModule>
```

## Install and Enable required modules 
For Debian Based Servers:

```
sudo a2enmod proxy proxy_wstunnel headers proxy_http
```

For RHEL Based Servers

```
yum install -y mod_proxy mod_proxy_http mod_proxy_wstunnel mod_headers
```

Then ensure the following lines exist in <code><b>/etc/httpd/conf/httpd.conf</b></code>. if not present, add at the end of file
```
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so
LoadModule proxy_wstunnel_module modules/mod_proxy_wstunnel.so
LoadModule headers_module modules/mod_headers.so
```

## Restart Apache

For Debian Based Servers:

```
sudo systemctl restart apache2
```

For RHEL Based Servers

```
sudo systemctl restart httpd
```

<a id="4b-nginx-configuration" name="4b-nginx-configuration"></a>
### **4b. NGINX Configuration**

For Debian Based Servers:

```
nano /etc/nginx/sites-available/faveo.conf
```

For RHEL Based Servers:

```
nano /etc/nginx/nginx.conf
```

Add the following configuration for NGINX:

```
location ~ ^/natsws {
    proxy_pass http://127.0.0.1:9235;
    proxy_http_version 1.1;

    proxy_set_header Host $host;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header X-Forwarded-Host $host:$server_port;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

Example
```
server {
    listen 443 ssl;
    server_name --DOMAINNAME--;

    ssl_certificate /etc/ssl/certs/your_domain.crt;
    ssl_certificate_key /etc/pki/tls/private/your_domain.key;

    location ~ ^/natsws {
        proxy_pass http://127.0.0.1:9235;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-Host $host:$server_port;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Restart Nginx

```
sudo systemctl restart nginx
```
---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/websockets/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-11-13
last_modified_by: Mohammad_Asif
toc: true
title: Enabling WebSockets in Faveo Helpdesk
---

<img alt="MeshCentral" src="https://www.svgrepo.com/show/354553/websocket.svg" width="170" height="150" />


## Introduction:

WebSockets provide a bidirectional communication protocol for real-time data exchange over a persistent connection. Pusher simplifies WebSocket integration, enabling seamless real-time communication between clients and the server for responsive, interactive applications.

WebSockets enable real-time updates in web apps, making UIs more responsive. Instead of polling for changes, data is sent over a WebSocket when updated on the server.

## Server Level Changes:
Add the below contents to the supervisor conf file.

#### For Debian Based Systems:

##### 1. Install Node.js 

```
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
```

Verify installation

```
node -v
npm -v
```

##### 2. Configure Web Server
Choose based on which web server you are using.

**If Using Apache**

Enable Required Modules

```
a2enmod proxy proxy_http proxy_wstunnel rewrite ssl
systemctl restart apache2
```

Edit the SSL Virtual Host file

```
nano /etc/apache2/sites-available/faveo-ssl.conf
```

Paste WebSocket Proxy Block inside <VirtualHost *:443> after SSL Block

```
ProxyPreserveHost On
SSLProxyEngine On

# WebSocket Proxy (for Socket.IO)
ProxyPass /fc/ http://localhost:6001/fc/ retry=0
ProxyPassReverse /fc/ http://localhost:6001/fc/

# Handle WebSocket upgrade
RewriteEngine On
RewriteCond %{HTTP:Upgrade} websocket [NC]
RewriteCond %{HTTP:Connection} upgrade [NC]
RewriteRule ^/fc/(.*) ws://localhost:6001/fc/$1 [P,L]
```

Restart Apache

```
systemctl restart apache2
```

**If Using Nginx**

Edit the SSL Virtual Host file

```
nano /etc/nginx/sites-available/faveo.conf
```

Paste WebSocket Proxy server {} Block

```
# WebSocket Support
location /fc/ {
    proxy_pass http://127.0.0.1:6001/fc/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
    proxy_read_timeout 3600s;
    proxy_send_timeout 3600s;
}
```

Restart Nginx

```
systemctl restart nginx
```

##### 3. Configure Supervisor

Open the Supervisor conf file with nano editor.

```
nano /etc/supervisor/conf.d/faveo-worker.conf
```

Add the below configurations at the end of the file.

```
[program:faveo-websockets-subscribe]
process_name=%(program_name)s
command=php /var/www/faveo/artisan socket:serve
autostart=true
autorestart=true
user=root
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/socket-worker.log

[program:faveo-websockets-node]
process_name=%(program_name)s
command=node /var/www/faveo/resources/assets/js/socket
autostart=true
autorestart=true
user=root
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/node-server.log
```

Restart Supervisor

```
systemctl restart supervisor
```

Check the service status.

```
supervisorctl
```

---

#### For RedHat Based Systems:

##### 1. Install Node.js

```
curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
sudo yum install -y nodejs
```

Verify installation

```
node -v
npm -v
```

##### 2. Configure Web Server
Choose based on which web server you are using.

**If Using Apache**

Install required Modules

```
yum install mod_proxy mod_proxy_wstunnel -y
```

Open the SSL Virtual Host file

```
/etc/httpd/conf.d/faveo-ssl.conf
```

Paste WebSocket Proxy Block inside <VirtualHost *:443> after SSL Block

```
ProxyPreserveHost On
SSLProxyEngine On

# WebSocket Proxy (for Socket.IO)
ProxyPass /fc/ http://localhost:6001/fc/ retry=0
ProxyPassReverse /fc/ http://localhost:6001/fc/

# Handle WebSocket upgrade
RewriteEngine On
RewriteCond %{HTTP:Upgrade} websocket [NC]
RewriteCond %{HTTP:Connection} upgrade [NC]
RewriteRule ^/fc/(.*) ws://localhost:6001/fc/$1 [P,L]
```

Restart Apache

```
systemctl restart apache2
```

**If Using Nginx**

```
nano /etc/nginx/nginx.conf
```

Paste WebSocket Proxy server {} Block

```
# WebSocket Support
location /fc/ {
    proxy_pass http://127.0.0.1:6001/fc/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
    proxy_read_timeout 3600s;
    proxy_send_timeout 3600s;
}
```

Restart Nginx

```
systemctl restart nginx
```

##### 3. Configure Supervisor

Open the Supervisor conf file with nano editor.

```
nano /etc/supervisord.d/faveo-worker.ini
```

Add the below configurations at the end of the file.

```
[program:faveo-websockets-subscribe]
process_name=%(program_name)s
command=php /var/www/faveo/artisan socket:serve
autostart=true
autorestart=true
user=root
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/socket-worker.log

[program:faveo-websockets-node]
process_name=%(program_name)s
command=node /var/www/faveo/resources/assets/js/socket
autostart=true
autorestart=true
user=root
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/node-server.log

```

Restart Supervisor

```
systemctl restart supervisord
```

Check the service status.

```
supervisorctl
```

> **Note** that the user will be *root* only in both the cases.

---

## Faveo GUI Changes:

Login to the Faveo HelpDesk and go to **Admin Panel > Drivers > Websockets**.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/GUI-images/websockets.png" alt="" style=" width:400px ; height:auto">

Select Pusher Settings icon ⚙️ and enter the following details:

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/GUI-images/websockets1.png" alt="" style=" width:400px ; height:auto">

**Details:**

1. **Host:**  Add your helpdesk domain name here (FQDN).
2. **SSL Certificate Path:**  Add your main SSL certificate path here.
3. **SSL Private Key:**  Add the Private Key for the helpdesk domain.
4. **SSL Passphrase:** Add SSL Password if the SSL is password protected, if not leave this field blank.

<img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/GUI-images/websockets2.png" alt="" style=" width:400px ; height:auto">

Save the above details. The Websockets is configured on the Helpdesk at this stage.

---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/websockets/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-11-20
last_modified_by: Sivakumar
toc: true
title: Enabling WebSockets in Faveo Helpdesk (Laravel Reverb)
---

<img alt="WebSocket" src="https://upload.wikimedia.org/wikipedia/commons/c/cd/WebSocket_colored_logo.svg" width="150" height="150" />


## Introduction

This guide walks you through enabling WebSocket (realtime) support in Faveo Helpdesk using **Laravel Reverb**, **Redis**, **Supervisor** and **Apache** (Nginx is also covered).

Reverb replaces the earlier **Socket.IO + Node.js** setup, so **Node.js is no longer required** on the server.

The following features depend on WebSockets:

- Live Chat
- Live ticket updates in the agent panel
- RMM live terminal and device status

This guide covers both:

- **Debian based systems**: Ubuntu, Debian
- **RedHat based systems**: RHEL, Alma Linux, Rocky Linux

Where the commands differ, each step has a separate block for each OS family. Run only the block that matches your server.

---

## Before You Start

Make sure the following are true:

- Faveo is installed at `/var/www/faveo`.
- Faveo is served over **HTTPS at the domain root**, for example `https://support.example.com`.
- You have `sudo` access to the server.

> **Good to know:** Reverb is already bundled with Faveo. There is nothing extra to download or install for it.

> **Sub-folder installs are not supported.** If Faveo is installed in a sub-folder (for example `https://example.com/helpdesk/public`), realtime features will not work out of the box. Browsers, the Live Chat widget and RMM agents always connect to `/app` at the **domain root**. In this case realtime works only if your web server forwards `/app` at the domain root to Reverb. The **System Health** page will show a warning for such installs.

### Names used on each OS

Some names differ between the two OS families. Keep this table handy:

| Item | Debian / Ubuntu | RedHat / Alma / Rocky |
|------|-----------------|-----------------------|
| Package manager | `apt` | `dnf` |
| Apache service | `apache2` | `httpd` |
| Redis service | `redis-server` | `redis` |
| Supervisor service | `supervisor` | `supervisord` |
| Supervisor config folder | `/etc/supervisor/conf.d/` (`.conf` files) | `/etc/supervisord.d/` (`.ini` files) |
| Web server user (Apache) | `www-data` | `apache` |
| Web server user (Nginx) | `www-data` | `nginx` |

### Quick overview of the steps

| Step | What you do |
|------|-------------|
| 1 | Enable the PHP Redis extension |
| 2 | Install and start Redis |
| 3 | Add the Reverb settings to `.env` |
| 4 | Configure Apache (or Nginx) to forward WebSocket traffic |
| 5 | Run Reverb with Supervisor |
| 6 | Restart the queue worker |
| 7 | Verify everything works |
| 8 | Remove the old Socket.IO setup (only if upgrading) |

---

## Step 1: Enable the PHP Redis Extension

Check whether the Redis extension is already enabled:

```
php -m | grep redis
```

If you see `redis` in the output, move on to Step 2. If nothing is shown, install it and restart the web server.

**Debian / Ubuntu:**

First check which PHP version Faveo runs on:

```
php -v
```

Install the Redis extension **for that exact version**. The example below is for PHP 8.4, the version used in the Faveo installation guides. Replace `8.4` if your version is different.

```
sudo apt install php8.4-redis
sudo systemctl restart php8.4-fpm
sudo systemctl restart apache2
```

> **Warning:** Do **not** run `sudo apt install php-redis` (without a version number) on Debian or Ubuntu. With the PHP repositories used by Faveo (`ppa:ondrej/php` and `packages.sury.org`), it installs the newest PHP release (for example PHP 8.5) and switches the server's `php` command to it. Faveo commands then fail with errors such as `Call to undefined function mb_split()`.
>
> If this has already happened, switch back to the correct version:
>
> ```
> sudo apt install php8.4-redis
> sudo update-alternatives --set php /usr/bin/php8.4
> ```

**RedHat / Alma / Rocky:**

```
sudo dnf install -y php-redis
sudo systemctl restart php-fpm
sudo systemctl restart httpd
```

> If you use Nginx, restart `nginx` instead of `apache2` / `httpd`.

---

## Step 2: Install and Start Redis Server

Install Redis and enable it to start on boot.

**Debian / Ubuntu:**

```
sudo apt update
sudo apt install redis-server
sudo systemctl enable --now redis-server
sudo systemctl status redis-server
```

**RedHat / Alma / Rocky 8 and 9:**

```
sudo dnf install -y redis
sudo systemctl enable --now redis
sudo systemctl status redis
```

> **RHEL 8 / 9 only:** if `dnf install -y redis` fails with `Unable to find a match: redis`, the RHEL AppStream repository is not available on the server (for example, the system is not registered with Red Hat). Use the Remi method from the version 10 block below instead, replacing `remi-release-10.rpm` with `remi-release-8.rpm` or `remi-release-9.rpm`.

**RedHat / Alma / Rocky 10:**

Version 10 no longer ships Redis in its own repositories, so a plain `dnf install redis` fails with `Unable to find a match: redis`. Install Redis from the **Remi modular repository** instead (the same method the Faveo installation script uses):

```
sudo dnf install -y epel-release
sudo dnf install -y https://rpms.remirepo.net/enterprise/remi-release-10.rpm
sudo dnf config-manager --set-enabled remi-modular
sudo dnf module reset redis -y
sudo dnf module enable -y redis:remi-8.0
sudo dnf install -y redis
sudo systemctl enable --now redis
sudo systemctl status redis
```

> On RHEL 10, if `dnf install -y epel-release` is not found, use: `sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm`. If the Remi repository is already installed (it is on servers set up with the Faveo installation guide), the `remi-release-10.rpm` line simply reports it as already installed.

You should see **active (running)** in the output. You can also run `redis-cli ping`, which should reply with `PONG`.

---

## Step 3: Configure Reverb in the `.env` File

This step is the same on all operating systems, except for the user name in step 3.3.

### 3.1 Generate the key and secret

Run the command below **twice**. The first value will be your app **key**, and the second will be your app **secret**. Save both somewhere safe.

```
openssl rand -hex 16
```

### 3.2 Add the Reverb settings

Open the Faveo `.env` file:

```
sudo nano /var/www/faveo/.env
```

Add the following block at the end of the file. Replace `<generated key>` and `<generated secret>` with the two values from step 3.1. `REVERB_APP_ID` can be any number.

```
REVERB_APP_ID=202627
REVERB_APP_KEY=<generated key>
REVERB_APP_SECRET=<generated secret>
REVERB_HOST=127.0.0.1
REVERB_PORT=8080
REVERB_SCHEME=http
REVERB_SERVER_HOST=0.0.0.0
REVERB_SERVER_PORT=8080
```

**What each setting means:**

| Setting | Purpose |
|---------|---------|
| `REVERB_APP_ID`, `REVERB_APP_KEY`, `REVERB_APP_SECRET` | Credentials shared by Faveo and the Reverb server. The **key** is public (it is sent to browsers). The **secret** must stay on the server. |
| `REVERB_HOST`, `REVERB_PORT`, `REVERB_SCHEME` | Where Faveo publishes events. Faveo talks to Reverb locally over plain HTTP, so keep these as `127.0.0.1`, `8080` and `http`. |
| `REVERB_SERVER_HOST`, `REVERB_SERVER_PORT` | The address and port the Reverb server listens on. |

> **Important:** Do **not** change `BROADCAST_DRIVER`. Faveo automatically selects Reverb for its realtime features.

### 3.3 Clear the cached configuration

So that Faveo reads the new values, run the command as your web server user.

**Debian / Ubuntu:**

```
cd /var/www/faveo
sudo -u www-data php artisan config:clear
```

**RedHat / Alma / Rocky** (use `nginx` instead of `apache` if you run Nginx):

```
cd /var/www/faveo
sudo -u apache php artisan config:clear
```

---

## Step 4: Configure the Web Server for WebSockets

**How it works:** Browsers connect to `wss://your-domain/app` on port **443**. The web server forwards those connections internally to Reverb on port **8080**. Because of this, **you do not need to open port 8080 in the firewall**.

Follow the section for your web server and OS.

### Option A: Apache

#### Debian / Ubuntu

**1. Enable the required modules and restart Apache:**

```
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_wstunnel
sudo a2enmod rewrite
sudo systemctl restart apache2
```

**2. Edit the SSL virtual host file:**

```
sudo nano /etc/apache2/sites-available/faveo-ssl.conf
```

Add the [Reverb proxy block](#reverb-proxy-block-for-apache) below **inside** the `<VirtualHost *:443>` section.

**3. Test the configuration and reload Apache:**

```
sudo apachectl configtest
sudo systemctl reload apache2
```

#### RedHat / Alma / Rocky

**1. Check the required modules are loaded.** On RedHat based systems the proxy and rewrite modules come with the `httpd` package and are usually loaded by default:

```
httpd -M | grep -E 'proxy_module|proxy_http_module|proxy_wstunnel_module|rewrite_module'
```

You should see all four modules. If any are missing, open `/etc/httpd/conf.modules.d/00-proxy.conf` (proxy modules) or `/etc/httpd/conf.modules.d/00-base.conf` (rewrite module), remove the `#` in front of the matching `LoadModule` line, and restart Apache:

```
sudo systemctl restart httpd
```

**2. Allow Apache to connect to Reverb (SELinux).** If SELinux is in **Enforcing** mode, Apache is blocked from forwarding traffic to port 8080. Check the mode with `getenforce`. If it shows `Enforcing`, run:

```
sudo setsebool -P httpd_can_network_connect 1
```

**3. Edit the SSL virtual host file:**

```
sudo nano /etc/httpd/conf.d/faveo-ssl.conf
```

> If you set up SSL with Certbot, the file may be named `/etc/httpd/conf.d/faveo-le-ssl.conf`. Use the file that contains your `<VirtualHost *:443>` section.

Add the [Reverb proxy block](#reverb-proxy-block-for-apache) below **inside** the `<VirtualHost *:443>` section.

**4. Test the configuration and reload Apache:**

```
sudo apachectl configtest
sudo systemctl reload httpd
```

#### Reverb proxy block for Apache

This block is the same on both OS families:

```
# Reverb WebSocket proxy
# Only WebSocket upgrade requests to /app/ are sent to Reverb.
# Normal HTTP requests continue to Faveo untouched.
RewriteEngine On
RewriteCond %{HTTP:Upgrade} websocket [NC]
RewriteCond %{HTTP:Connection} upgrade [NC]
RewriteRule ^/app/(.*) ws://127.0.0.1:8080/app/$1 [P,L]
```

`configtest` should return **Syntax OK** before you reload.

### Option B: Nginx

If your server runs Nginx instead of Apache, add the following **inside the HTTPS `server { }` block** of your Faveo site configuration:

- **Debian / Ubuntu:** usually `/etc/nginx/sites-available/faveo.conf`
- **RedHat / Alma / Rocky:** usually `/etc/nginx/nginx.conf` or a file in `/etc/nginx/conf.d/`

```
location /app {
    proxy_http_version 1.1;
    proxy_set_header Host $http_host;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_read_timeout 60m;
    proxy_pass http://127.0.0.1:8080;
}
```

**RedHat / Alma / Rocky only:** if SELinux is in **Enforcing** mode, allow Nginx to connect to Reverb:

```
sudo setsebool -P httpd_can_network_connect 1
```

Test the configuration and reload Nginx (same on both OS families):

```
sudo nginx -t
sudo systemctl reload nginx
```

---

## Step 5: Run Reverb with Supervisor

Supervisor keeps the Reverb server running in the background and restarts it automatically if it stops.

### Debian / Ubuntu

**1. Make sure Supervisor is installed:**

```
sudo apt install supervisor
```

**2. Create the Reverb configuration file:**

```
sudo nano /etc/supervisor/conf.d/faveo-reverb.conf
```

Paste the following content:

```
[program:faveo-reverb]
process_name=%(program_name)s
command=php /var/www/faveo/artisan reverb:start --host=0.0.0.0 --port=8080
directory=/var/www/faveo
autostart=true
autorestart=true
startretries=10
startsecs=3
stopwaitsecs=10
user=www-data
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/reverb.log
stdout_logfile_maxbytes=10MB
```

### RedHat / Alma / Rocky

**1. Make sure Supervisor is installed and running:**

```
sudo dnf install -y epel-release
sudo dnf install -y supervisor
sudo systemctl enable --now supervisord
```

**2. Create the Reverb configuration file:**

```
sudo nano /etc/supervisord.d/faveo-reverb.ini
```

Paste the following content. If you run Nginx, change `user=apache` to `user=nginx`.

```
[program:faveo-reverb]
process_name=%(program_name)s
command=php /var/www/faveo/artisan reverb:start --host=0.0.0.0 --port=8080
directory=/var/www/faveo
autostart=true
autorestart=true
startretries=10
startsecs=3
stopwaitsecs=10
user=apache
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/reverb.log
stdout_logfile_maxbytes=10MB
```

### Start Reverb (all OS)

**1. Load the new configuration and start Reverb:**

```
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start faveo-reverb
```

**2. Check that it is running:**

```
sudo supervisorctl status faveo-reverb
```

The status should show **RUNNING**.

---

## Step 6: Restart the Queue Worker

Queue workers read the `.env` file only when they start. Restart Horizon (or your queue worker program) so it picks up the new Reverb credentials. This command is the same on all OS:

```
sudo supervisorctl restart faveo-Horizon
```

> **Note:** Supervisor program names are case-sensitive. The Faveo Redis guides name the Horizon program `faveo-Horizon`. If yours has a different name, run `sudo supervisorctl status` to see the exact name and use that.

> **Remember:** Every time you change any `REVERB_` value in `.env`, restart **both** `faveo-reverb` and `faveo-Horizon`. A worker that still holds the old credentials silently drops every realtime event, and **no error is shown in the panel**.
>
> ```
> sudo supervisorctl restart faveo-reverb faveo-Horizon
> ```

---

## Step 7: Verify the Setup

Run through these three checks:

**1. Reverb is listening on port 8080:**

```
sudo ss -ltnp | grep 8080
```

You should see a line showing a process listening on port `8080`.

**2. Faveo System Health check:**

In Faveo, go to **Admin Panel > System Health** and find **WebSocket (Reverb) status**. It should read:

> The WebSocket (Reverb) connection is stable

**3. Browser connection:**

1. Open the agent panel in your browser.
2. Open **Developer Tools** (press `F12`) and go to the **Network** tab.
3. Filter by **WS**.
4. Refresh the page. A request to `/app/<key>` with status **101** means the browser is connected successfully.

🎉 WebSockets are now enabled in your Faveo Helpdesk.

---

## Step 8: Remove the Old Socket.IO Setup (Upgrades Only)

Skip this step on a fresh installation. If your server was previously configured using the older Socket.IO guide, clean up the parts that are no longer used:

1. **Remove the old Supervisor programs.** Delete the `faveo-websockets-subscribe` and `faveo-websockets-node` programs from the Supervisor config files:
    - **Debian / Ubuntu:** files in `/etc/supervisor/conf.d/`
    - **RedHat / Alma / Rocky:** files in `/etc/supervisord.d/`
2. **Remove the old proxy rules.** Delete the `/fc/` `ProxyPass`, `ProxyPassReverse` and `RewriteRule` lines from your Apache configuration file. (On Nginx, remove the `location /fc/ { ... }` block.)
3. **Apply the changes:**

    **Debian / Ubuntu:**

    ```
    sudo supervisorctl reread
    sudo supervisorctl update
    sudo systemctl reload apache2
    ```

    **RedHat / Alma / Rocky:**

    ```
    sudo supervisorctl reread
    sudo supervisorctl update
    sudo systemctl reload httpd
    ```

    > On Nginx, run `sudo systemctl reload nginx` instead of reloading Apache.

4. **Uninstall Node.js** if nothing else on the server uses it:
    - **Debian / Ubuntu:** `sudo apt remove nodejs`
    - **RedHat / Alma / Rocky:** `sudo dnf remove nodejs`

---

## Troubleshooting

| Problem | Cause and fix |
|---------|---------------|
| **Health check says Reverb is not configured** | `REVERB_APP_KEY`, `REVERB_HOST` or `REVERB_PORT` is missing from `.env`, or the configuration is cached. Complete [Step 3](#step-3-configure-reverb-in-the-env-file) and run `php artisan config:clear`. |
| **Health check says Reverb is configured but not running** | The `faveo-reverb` program is stopped or has failed. Run `sudo supervisorctl status faveo-reverb` and check `storage/logs/reverb.log`. |
| **Health check warns about a sub-folder** | Faveo is installed under a path such as `/helpdesk/public`. Forward `/app` at the domain root to Reverb, or install Faveo at the domain root. |
| **`faveo-reverb` shows `FATAL "Exited too quickly"`** | Another process is using port 8080, or the Supervisor user cannot read the Faveo folder. Free the port, or change `REVERB_SERVER_PORT`, `REVERB_PORT`, the Supervisor command and the proxy rule to the **same** new port. |
| **The `/app/` request fails in the browser with 404 or 400** | The proxy rule is missing, is outside the HTTPS virtual host, or `proxy_wstunnel` is not enabled. Repeat [Step 4](#step-4-configure-the-web-server-for-websockets). |
| **The `/app/` request fails with 503 (RedHat / Alma / Rocky)** | SELinux is blocking the web server from connecting to port 8080. Run `sudo setsebool -P httpd_can_network_connect 1`. |
| **`artisan` fails with `Call to undefined function mb_split()` (Debian / Ubuntu)** | `php-redis` was installed without a version number and switched the `php` command to a newer PHP release. Run `sudo apt install php8.4-redis` and `sudo update-alternatives --set php /usr/bin/php8.4`. See [Step 1](#step-1-enable-the-php-redis-extension). |
| **`dnf install redis` says `Unable to find a match` (RedHat / Alma / Rocky 10)** | Version 10 does not ship Redis in its own repositories. Enable the Remi `redis:remi-8.0` module first, as shown in [Step 2](#step-2-install-and-start-redis-server). |
| **`supervisorctl` says `no such process`** | The program name is wrong. Names are case-sensitive. Run `sudo supervisorctl status` to see the exact names. |
| **Realtime stopped after editing `.env`** | Reverb or the queue worker is still running with the old credentials, and the log shows `No matching application for ID`. Restart both: `sudo supervisorctl restart faveo-reverb faveo-Horizon`. |

### Useful commands

```
# Check Reverb status
sudo supervisorctl status faveo-reverb

# View the latest Reverb log entries
tail -n 50 /var/www/faveo/storage/logs/reverb.log

# Restart Reverb and the queue worker
sudo supervisorctl restart faveo-reverb faveo-Horizon
```

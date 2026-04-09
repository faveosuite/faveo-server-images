---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/alma-redis/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-04-09
last_modified_by: Mohammad_Asif
toc: true
title: Install and configure Redis, Supervisor and Worker for Faveo on Alma Linux
---

<img alt="Alma Linux Logo" src="https://upload.wikimedia.org/wikipedia/commons/0/0e/Almalinux_logo.png" width="200"  />

## Introduction

This document will list steps on how to install Redis for faveo.

We will install following dependencies in order to make Redis work:

- Redis
- PHP extension for Redis
- supervisor

## Install Redis

```sh
yum install redis -y
```

## Install PHP extension

```sh
yum install -y php-redis
```

## Start and Enable Redis

```sh
systemctl start redis
systemctl enable redis
```

You can check Redis’s status by running the following:

```sh
systemctl status redis.service
```

Once you’ve confirmed that Redis is indeed running, test the setup with this command:

```sh
redis-cli ping
```
This should print PONG as the response. If this is the case, it means you now have Redis running on your server and we can begin configuring it to enhance its security.

## Install and Configure Supervisor

```sh
yum install -y supervisor
```


## Start and Enable Supervisord

```
systemctl start supervisord
systemctl enable supervisord
```

Copy paste the below content in supervisor configuration.

```sh
nano /etc/supervisord.d/faveo-worker.ini
```

Change the directories according to your faveo configuration.

```sh

[program:faveo-Horizon]
process_name=%(program_name)s
command=php /var/www/faveo/artisan horizon
autostart=true
autorestart=true
user=apache
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/horizon-worker.log

```
## Restart the Supervisor to reread configuration

```sh
systemctl restart supervisord 
```


To check the Status use the below command
```sh
supervisorctl
```

systemctl status supervisord

## Enable Redis in Faveo
After Redis installation is complete, follow these [instructions](/docs/helper/enable-redis) to configure Redis with Faveo. 

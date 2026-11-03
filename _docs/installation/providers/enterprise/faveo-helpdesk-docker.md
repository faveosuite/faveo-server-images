---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/faveo-helpdesk-docker/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-10-06
last_modified_by: Sivakumar_C
toc: true
---
---
# <b>Deploying Faveo Helpdesk on Docker</b>   <!-- omit in toc -->
# Faveo Helpdesk on Docker - Installation Guide   <!-- omit in toc -->

<img src="https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4e/Docker_%28container_engine%29_logo.svg/960px-Docker_%28container_engine%29_logo.svg.png?utm_source=commons.wikimedia.org&utm_campaign=index&utm_content=thumbnail" alt="Docker" width="220"/>

This guide explains how to install **Faveo Helpdesk** (paid editions) on Docker with the installer **`faveo-run.sh`**: every way to run it, every option, what is required, what the installer does, and what happens when something goes wrong.

> Using the free **Community Edition**? It has its own script - see [Community Edition](#13-community-edition).

---

## Contents   <!-- omit in toc -->

1. [What the installer does](#1-what-the-installer-does)
2. [Requirements](#2-requirements)
3. [Required information (fields)](#3-required-information-fields)
4. [Download the installer](#4-download-the-installer)
5. [Ways to install](#5-ways-to-install)
6. [All options in detail](#6-all-options-in-detail)
7. [What is created on the server](#7-what-is-created-on-the-server)
8. [Wrong values - how the installer reacts](#8-wrong-values---how-the-installer-reacts)
9. [After the installation](#9-after-the-installation)
10. [Backup and restore](#10-backup-and-restore)
11. [Removing an installation](#11-removing-an-installation)
12. [Troubleshooting](#12-troubleshooting)
13. [Community Edition](#13-community-edition)
14. [Finish the setup in the browser](#14-finish-the-setup-in-the-browser)

---

## 1. What the installer does

One command takes a plain Linux server to a running Faveo Helpdesk:

- installs the tools it needs and **Docker** (if missing)
- creates the **SSL certificate** (Let's Encrypt, self-signed, or your paid certificate)
- downloads **Faveo Helpdesk** with your license
- builds and starts **5 containers**
- runs the **Faveo installation** (`php artisan install:faveo`) and **verifies your license**
- can later **back up** and **remove** the installation

Containers created for each installation (`<domain>` = your domain name):

| Container | Purpose |
|---|---|
| `<domain>-apache` | Web server with PHP - serves Faveo |
| `<domain>-mysql` | MySQL 8.4 database (not created when you use your own database server) |
| `<domain>-redis` | Cache and job queue |
| `<domain>-supervisor` | Background workers (queues, scheduled tasks, WebSocket) |
| `<domain>-meilisearch` | Search engine |

---

## 2. Requirements

| Requirement | Details |
|---|---|
| **Operating system** | 64-bit Linux - see the [supported operating systems](#21-supported-operating-systems) below. |
| **Processor** | x86_64 (Intel / AMD) or ARM64 (aarch64). 32-bit systems are not supported. |
| **Access** | Root, or a user with `sudo`. |
| **Internet** | Needed to download packages, Docker images and Faveo. |
| **Domain name** | A DNS A record pointing to the server's public IP. Required for Let's Encrypt; for self-signed / paid SSL any name works (test domains can use the hosts file). |
| **Ports** | 80 and 443 free (other ports possible with self-signed or paid SSL). Open them in the firewall / cloud security group. |
| **Docker** | Not required beforehand - the installer installs Docker Engine, Docker Compose and Docker Buildx for your OS. |
| **SELinux** | Can stay in *Enforcing* mode - handled automatically. |
| **Windows / macOS** | Not supported directly. On Windows use WSL2 with Ubuntu (for testing). |

### 2.1 Supported operating systems

⭐ **Recommended for production** - long-term support releases:

| Operating system | Versions | Docker installed from |
|---|---|---|
| ⭐ **AlmaLinux** | 8, 9, 10 | Docker official repository |
| ⭐ **Rocky Linux** | 8, 9, 10 | Docker official repository |
| ⭐ **Red Hat Enterprise Linux (RHEL)** | 8, 9, 10 *(10 needs an active Red Hat subscription)* | Docker official repository |
| ⭐ **Ubuntu LTS** | 22.04, 24.04, 26.04 | Docker official repository |
| ⭐ **Debian** | 12 (Bookworm), 13 (Trixie) | Docker official repository |

---

## 3. Required information (fields)

These five values are always needed. Missing ones are asked for; give them all on the command line to install without any question.

| Field | Option | Rules | Example | Where to get it |
|---|---|---|---|---|
| **Domain name** | `-d`, `--domain` | Letters, digits, `-` and `.` - no `https://`, no `_` | `helpdesk.example.com` | Your DNS provider |
| **Email** | `-e`, `--email` | A valid email address | `admin@example.com` | Your email - also used by Let's Encrypt for expiry notices |
| **License code** | `-l`, `--license` | Letters, digits and `-` (16 characters for license verification) | `ABC1D23EFJH50000` | [store.faveohelpdesk.com](https://store.faveohelpdesk.com) |
| **Order number** | `-o`, `--order` | Letters, digits and `-`; a leading `#` is removed | `45894483` | [store.faveohelpdesk.com](https://store.faveohelpdesk.com) |
| **SSL type** | `-s`, `--ssl` | `certbot`, `self-signed` or `paid-ssl` (or `A`, `B`, `C`) | `certbot` | Your choice - see [SSL](#62-ssl-certificate) |

Required **only in some cases**:

| Case | Required fields |
|---|---|
| `--ssl paid-ssl` | `--certfile`, `--keyfile`, `--cacertfile` (asked for if missing; required with `-y`) |
| Your own database server (`--db remote` or `--db-host`) | `--db-host`, `--db-admin-password` (asked for if missing; required with `-y`) |
| Remote database over SSL (`--db-ssl yes`) | `--db-ssl-ca` |

---

## 4. Download the installer

```sh
git clone https://github.com/faveosuite/faveo-helpdesk-docker-v2.git
cd faveo-helpdesk-docker-v2/faveo-helpdesk-docker
chmod +x faveo-run.sh
```

The installer uses the Dockerfiles and templates in this folder and **copies** them into the installation folder. This folder is never changed, so you can install several domains from it.

---

## 5. Ways to install

### A. Interactive - answer questions

```sh
sudo ./faveo-run.sh
```

The installer asks, one by one:

| Question | Purpose | Default (Enter) |
|---|---|---|
| Domain name | Address of the helpdesk | - |
| Email address | Admin / Let's Encrypt email | - |
| License code, Order number | Download and license verification | - |
| Release | `official`, `rc` or `beta` version of Faveo | official |
| Application environment | `production`, `development` or `testing` | production |
| SSL certificate | Let's Encrypt, self-signed or paid | - |
| Certificate files *(paid SSL only)* | Path, pasted PEM text or base64 | - |
| Enable WebSocket | Live updates in the browser | No |
| Database location | Local MySQL container or your own server | Local |
| Customize database name / user / password | Change the defaults | No |
| Installation path | Where the installation is created | `/opt/faveo/<domain>` |
| Custom ports | Shows the ports and whether they are free | No (80 / 443 / 9001) |
| Custom subnet | Docker network range | No (first free from 172.24.0.0/16) |

A wrong answer is explained and asked again - you get 3 tries. At the end a **summary** is shown and you confirm with **y**. Nothing is changed before that.

### B. One command, no questions

```sh
sudo ./faveo-run.sh -d helpdesk.example.com -e admin@example.com -l ABC1D23EFJH50000 -o 45894483 -s certbot --install-docker
```

When all [required fields](#3-required-information-fields) are given, the installer runs straight through - no questions and no confirmation. Any option you leave out uses its default. `--install-docker` lets it install Docker when the server does not have it.

---

## 6. All options in detail

Options can be combined in any order. `--option value` and `--option=value` both work.

### 6.1 Required

| Option | Purpose | Values | If wrong |
|---|---|---|---|
| `-d`, `--domain` | Domain of the helpdesk; also names the containers (`<domain>-apache` ...) | e.g. `helpdesk.example.com` | Stops: *"not a valid domain name"* |
| `-e`, `--email` | Admin / Let's Encrypt email | valid email | Stops: *"not a valid email address"* |
| `-l`, `--license` | Download Faveo and verify the license | letters, digits, `-` | Stops before anything is changed. A code that is valid but not 16 characters installs, but license verification is skipped |
| `-o`, `--order` | Download Faveo | letters, digits, `-` | Stops. A wrong (but valid-looking) license/order makes the **download fail** → automatic rollback |
| `-s`, `--ssl` | SSL certificate type | `certbot`, `self-signed`, `paid-ssl` / `A`, `B`, `C` | Stops: *"use certbot, self-signed or paid-ssl"* |

### 6.2 SSL certificate

| Type | Use it when | What happens | Needs |
|---|---|---|---|
| `certbot` (A) | Real domain reachable from the internet | Let's Encrypt certificate is requested; renewed weekly by cron; Apache reloads after renewal | Domain points to the server, ports **80 and 443** free and open (custom ports not allowed) |
| `self-signed` (B) | Testing, internal servers, custom ports | A certificate is generated; browsers show a warning. Import `ssl_copy/faveorootCA.crt` into browsers to trust it | Nothing |
| `paid-ssl` (C) | You bought a certificate | Your files are checked and installed | The three files below |

Paid SSL files - each value can be a **file path**, the **PEM text** itself, or the PEM **base64-encoded** (handy for automation):

| Option | Purpose | Alias |
|---|---|---|
| `--certfile` | Your certificate (`certificate.crt`) | `--ssl-cert` |
| `--keyfile` | Its private key (`private.key`) | `--ssl-key` |
| `--cacertfile` | CA bundle / intermediate chain (`ca_bundle.crt`) | `--ssl-ca` |

Checks before installing:

| Check | Result if it fails |
|---|---|
| Each file is a valid PEM certificate / key | **Stops** - *"not a valid file path or PEM certificate"* |
| The key matches the certificate | **Stops** - *"The private key does not match the certificate"* |
| Certificate not expired | Warning only |
| Certificate issued for the domain | Warning only |

### 6.3 Release, environment and features

| Option | Purpose | Values | Default |
|---|---|---|---|
| `-r`, `--release` | Which Faveo version to download | `official` (stable), `rc` (release candidate), `beta` | `official` |
| `--faveo-env` | Faveo application environment (`--env` of `install:faveo`). Alias `--faveoenv` | `production`, `development`, `testing` | `production` |
| `-w`, `--websocket` | Live updates: enables the WebSocket proxy in Apache and the WebSocket workers | `yes` / `no` (`y` / `n`) | `no` |
| `--skip-faveo-setup` | Do **not** run `install:faveo` and the license check - finish in the browser yourself ([section 14](#14-finish-the-setup-in-the-browser)) | - | off |

If the chosen release is not available for your license, the download fails and the installation is rolled back.

### 6.4 Installation folder

| Option | Purpose | Default |
|---|---|---|
| `-i`, `--install-dir` | Folder that holds the whole installation | `/opt/faveo/<domain>` |
| `-f`, `--force` | Allow a folder that is not empty | off |

- Missing folders are created (including parent folders). Relative paths and `~` work.
- **Refused** (asked again / stops): system folders such as `/`, `/opt`, `/home`, `/etc`, `/var`, `/usr`, `/tmp`, `/root`, a user's home folder itself, and Windows drives under WSL (`/mnt/c/...`).
- A folder that is **not empty**: interactively you are asked; with `-y` it stops unless `--force` is given. With `--force` the old content is **moved** to `<folder>.old-<date>` (not deleted) and put back if the installation fails.

### 6.5 Database - local MySQL container (default)

| Option | Purpose | Default | Rules |
|---|---|---|---|
| `--db` | `local` = MySQL 8.4 container on this server; `remote` = your own server | `local` | `local` / `remote` |
| `--db-name` | Database name | `faveo` | letters, digits, `_`, max 32 |
| `--db-user` | Database user | `faveo` | letters, digits, `_`, max 32 |
| `--db-password` | Password of that user | generated (20 characters) | 8-64 characters: letters, digits and `@ # % ^ * _ + = . , : ! ? -` |
| `--db-root-password` | MySQL root password | generated (20 characters) | same as above |

The database files are stored in the `mysql/` folder of the installation.

### 6.6 Database - your own MySQL / MariaDB server

Selected with `--db remote` or simply by giving `--db-host`. No MySQL container is created.

| Option | Purpose | Default |
|---|---|---|
| `--db-host` | Server hostname or IPv4 address | *(required)* |
| `--db-port` | Server port | `3306` |
| `--db-admin-user` | Account that can create databases and users | `root` |
| `--db-admin-password` | Its password | *(required)* |
| `--db-name` / `--db-user` / `--db-password` | Database and user that are **created** on the server | `faveo` / `faveo` / generated |
| `--db-ssl` | Encrypted connection | `no` |
| `--db-ssl-ca` | CA certificate of the server (path, PEM or base64) | *(required with `--db-ssl yes`)* |
| `--db-ssl-cert` / `--db-ssl-key` | Client certificate and key (optional; key needed with cert) | - |
| `--db-ssl-verify` | Check the server's hostname against its certificate | `yes` |

### 6.7 Ports and Docker network

| Option | Purpose | Default |
|---|---|---|
| `--http-port` | HTTP port on the server (redirects to HTTPS) | `80` |
| `--https-port` | HTTPS port on the server | `443` |
| `--supervisor-port` | Supervisor port, reachable **from this server only** (127.0.0.1); `none` = not published | `9001` |
| `--auto-ports` | If a port is busy, take the next free one automatically | off |
| `--subnet` | Docker network range, form `x.y.0.0/16` | first free from `172.24.0.0/16` |

- With **certbot** the ports must be 80 and 443 - other values stop the installer.
- With custom ports the site address becomes `https://<domain>:<https-port>`.
- A port that is **already in use**: interactively you are asked for another (a free one is suggested); with `-y` it stops and names a free port; with `--auto-ports` a free port is taken.
- A subnet that **overlaps** an existing network (another Docker network, your LAN or VPN route) is refused.

### 6.8 Backup and removal

| Option | Purpose |
|---|---|
| `--backup` | Back up an installation ([section 10](#10-backup-and-restore)) |
| `--backup-dir <path>` | Where backups are stored (default `<installation parent>/Backup`, e.g. `/opt/faveo/Backup`) |
| `--uninstall` | Remove an installation ([section 11](#11-removing-an-installation)) - alias `--rollback` |
| `-i <path>` / `-d <domain>` | Choose the installation for `--backup` / `--uninstall` without the list |

---

## 7. What is created on the server

Everything is inside the installation folder (default `/opt/faveo/<domain>`):

| File / folder | Content |
|---|---|
| `credentials.txt` | URL, license code, order number, database host / name / user / passwords, Meilisearch key (root only) |
| `FAVEO-DOCKER-COMMANDS.txt` | Ready-to-use commands for this installation and this OS - health checks, logs, artisan, workers, database, SSL, Docker service, Docker update, firewall, backup (no passwords inside) |
| `faveo-run.sh` | A copy of the installer - run `--backup`, `--uninstall` or `--help` from here, even if the repository folder is gone (new installations still start from the repository folder) |
| `.env` | Settings used by Docker Compose (root only) |
| `docker-compose.yml` | Container definitions |
| `Dockerfile/` | Image recipes (apache, supervisor; selfsign only for self-signed SSL) |
| `apache/000-default.conf` | Apache virtual host for your domain |
| `supervisor/` | Worker definitions (Horizon, scheduler, WebSocket) |
| `ssl_copy/` or `certbot/` | Certificates |
| `faveo/` | The Faveo application |
| `storage/` | Faveo storage |
| `mysql/` | Database files (local database) |
| `db_ssl/` | Remote database certificates (remote + SSL) |
| `redis/`, `meilisearch/` | Queue / cache and search data |
| `logs/` | Apache, Supervisor and installation logs (`faveo-install.log`) |

Outside the folder: the Docker network `<domain>-faveo`, the images `faveo-apache` / `faveo-supervisor`, and (Let's Encrypt only) a weekly renewal entry in root's crontab.

---

## 8. Wrong values - how the installer reacts

All values are checked **before anything is changed**. With options, every error is listed at once; interactively each wrong answer is asked again - you get 3 tries.

| Situation | Message (example) | Fix |
|---|---|---|
| Required field missing (no questions mode) | `--domain is required.` | Add the option |
| Invalid domain | `--domain: 'my_site' is not a valid domain name` | Letters, digits, `-`, `.` only |
| Invalid email | `--email: 'x@' is not a valid email address` | Use a full address |
| Invalid SSL type | `--ssl: use certbot, self-signed or paid-ssl` | |
| Let's Encrypt with other ports | `Let's Encrypt (certbot) needs HTTP port 80 and HTTPS port 443` | Use self-signed / paid-ssl, or ports 80/443 |
| Port in use | `Port 443 (HTTPS) is in use by apache2. Use --https-port 8443 (free) or add --auto-ports` | Free the port or choose another |
| Same port twice | `HTTP and HTTPS ports must be different` | |
| Bad subnet | `--subnet: use the form x.y.0.0/16` / `overlaps a network already used` | Choose another `/16` |
| Paid SSL key does not match | `The private key does not match the certificate` | Use the matching key |
| Bad certificate file | `--certfile: not a valid file path or PEM certificate` | Check the path / content |
| Bad DB name / password | `--db-password: 8-64 characters: letters, digits and ...` | Follow the rules in [6.5](#65-database---local-mysql-container-default) |
| Remote DB unreachable | `Could not connect to the database server db:3306: ...` | Host, port, firewall, admin password |
| Remote DB not empty | `Database 'faveo' on db is not empty` | Use another `--db-name` |
| System folder as install path | `Refusing to use '/opt' as the installation path` | Use a sub-folder |
| Folder not empty | `'/srv/faveo' is not empty. Use --force ...` | Another folder or `--force` |
| Docker missing (no questions) | `Docker / Docker Compose is missing ... Run again with --install-docker` | Add `--install-docker` |
| Unknown option | `Unknown option: --whatever` | See `--help` |
| Not root | `Please run as root: sudo ./faveo-run.sh ...` | Use `sudo` |

**If the installation fails** (or you press Ctrl+C), everything this run created is removed again: containers, network, images, the renewal cron entry and the installation folder. A folder replaced with `--force` is put back. You are asked first; with `-y` it happens automatically. Use `--keep-on-failure` to keep the files instead.

---

## 9. After the installation

### Open the site

1. Wait until the installer shows **SUCCESS** and **VERIFIED** (license).
2. Open **`https://<your domain>`** in your browser (custom port: `https://<your domain>:<port>`).
3. **Self-signed SSL:** the browser shows a warning - click *Advanced → Continue*, or import `ssl_copy/faveorootCA.crt` to remove it.
4. **Test domain** (not in public DNS): first add `<server IP> <your domain>` to the hosts file of your computer.

Site does not open? See [Troubleshooting](#12-troubleshooting).

### Useful commands

Run these in the installation folder (`cd /opt/faveo/<domain>`):

| Task | Command |
|---|---|
| Status of the containers | `docker compose ps` |
| Live logs | `docker compose logs -f` |
| Logs of one container | `docker compose logs -f faveo-apache` |
| Stop / start | `docker compose down` / `docker compose up -d` |
| Restart | `docker compose restart` |
| Shell in the app container | `docker exec -it <domain>-apache bash` |
| Clear Faveo caches | `docker exec -u www-data <domain>-apache php artisan optimize:clear` |

Many more ready-made commands are in **`FAVEO-DOCKER-COMMANDS.txt`**. Servers that only have the old standalone tool use `docker-compose` instead of `docker compose`.

Good to know:

- Containers **start automatically** after a reboot (Docker is enabled at boot).
- Let's Encrypt certificates **renew automatically** every week, and Apache reloads them.
- The Supervisor port is reachable only from the server itself.
- **Test domains** (not in public DNS): add `<server IP> <domain>` to the hosts file of the computer you browse from (`/etc/hosts`, or `C:\Windows\System32\drivers\etc\hosts`).
- **Self-signed**: import `ssl_copy/faveorootCA.crt` into your browser / OS to remove the warning.

---

## 10. Backup and restore

### Create a backup

```sh
sudo ./faveo-run.sh --backup                                           # choose from the list
sudo ./faveo-run.sh --backup -d helpdesk.example.com -y                # by domain, no questions
sudo ./faveo-run.sh --backup -i /opt/faveo/helpdesk.example.com --backup-dir /mnt/backups -y
```

The backup goes to `<backup-dir>/<domain>/<date_time>/` (default backup-dir: `/opt/faveo/Backup`, or next to your custom installation folder):

| File | Content |
|---|---|
| `database.sql.gz` | Database dump (local container or remote server). A stopped MySQL container is started for the dump and stopped again |
| `faveo-files.tar.gz` | `faveo/` and `storage/` |
| `config.tar.gz` | `.env`, `docker-compose.yml`, `credentials.txt`, `FAVEO-DOCKER-COMMANDS.txt`, Apache / Supervisor configuration, Dockerfiles, certificates |
| `SHA256SUMS` | Checksums to check the backup is not damaged: `sha256sum -c SHA256SUMS` |
| `README.txt` | Step-by-step restore commands for this backup |

- Free disk space is checked first. The backup folder must be outside the installation folder.
- The dump is verified. **A failed backup deletes its own folder and changes nothing else.**

### Restore

The `README.txt` in each backup has the exact commands. In short:

1. Create the folder and unpack: `tar xzf config.tar.gz && tar xzf faveo-files.tar.gz`
2. Local database: start MySQL (`docker compose up -d faveo-mysql`) and import `database.sql.gz` into it. Remote database: import it into your server.
3. Start everything: `docker compose up -d --build`

---

## 11. Removing an installation

```sh
sudo ./faveo-run.sh --uninstall                                        # choose from the list
sudo ./faveo-run.sh --uninstall --backup -i /opt/faveo/helpdesk.example.com -y   # back up, then remove
sudo ./faveo-run.sh --uninstall -i /opt/faveo/helpdesk.example.com -y           # remove without backup
```

How the installation is found: folders in `/opt/faveo/`, plus custom folders recorded by Docker on the containers. If the containers no longer exist, give the folder with `-i`.

The installer shows what will be deleted, asks **yes / no**, then offers a **backup** first.

| Removed | Kept |
|---|---|
| Containers and Docker network | A remote database (your data - drop it yourself if no longer needed) |
| The Faveo database **user** on a remote database server (needs the admin password) | |
| The installation folder (application, database files, certificates, logs, credentials) | Backups |
| Faveo images (if no other installation uses them) | Base images (`docker image prune -a` frees them) |
| Let's Encrypt renewal cron entry | Docker itself |

Safety: if the backup fails, **nothing is removed**; only folders created by this installer can be removed; system folders are never deleted.

---

## 12. Troubleshooting

| Problem | Cause | Solution |
|---|---|---|
| **Port 80 / 443 in use** | Another web server (Apache, nginx ...) is running | Stop it, or use `-s self-signed --http-port 8091 --https-port 8443`, or `--auto-ports` |
| **Let's Encrypt failed** | Domain does not point to the server, or port 80 is blocked | Check DNS (`ping <domain>`), open port 80/443 in the firewall and cloud security group |
| **Download failed** | Wrong license / order number, release not available for the license, or no internet | Check the values on store.faveohelpdesk.com; try `-r official` |
| **"The downloaded file is not a valid archive"** | License / order number not accepted | Check them |
| **Image build failed** | Network problem (retried 3 times) or unsupported PHP version | Check internet; keep the default PHP version |
| **Faveo installation FAILED: SSL certificate not found** | Faveo could not open its own `https://` address | Check `FAVEO-DOCKER-COMMANDS.txt` → *Site answers*; make sure the domain and certificate are correct |
| **License verification FAILED** | Message from the license server (e.g. *maximum number of installations reached*) | Free an installation slot on store.faveohelpdesk.com or contact Faveo; verify again (command in `FAVEO-DOCKER-COMMANDS.txt`) |
| **Browser cannot open the site** | Domain not pointing to the server, firewall, or custom port missing in the URL | Check DNS / hosts file, firewall, and use `https://<domain>:<port>` for custom ports |
| **Browser warns about the certificate** | Self-signed certificate | Expected - import `ssl_copy/faveorootCA.crt`, or use certbot / paid SSL |
| **Containers stopped after a reboot** | Docker not starting at boot | `FAVEO-DOCKER-COMMANDS.txt` → *Start at boot* |
| **Subnet clashes with LAN / VPN** | Docker network range already used | Reinstall with `--subnet 172.30.0.0/16` (any free `x.y.0.0/16`) |
| **"is not an installation created by this script"** | `--uninstall` / `--backup` pointed to another folder | Use the folder of an installation made by `faveo-run.sh` |

Useful commands for diagnosis:

```sh
./faveo-run.sh --help                              # OS, Docker, free ports, installations
cd /opt/faveo/<domain> && docker compose ps        # container status
docker compose logs --tail 100 faveo-apache        # web server / PHP errors
cat logs/faveo-install.log                         # Faveo setup and license output
```

---

## 13. Community Edition

The free Community Edition uses **`faveo-community-run.sh`**. It runs in this folder and keeps its files here.

```sh
chmod +x faveo-community-run.sh
sudo ./faveo-community-run.sh -domainname helpdesk.example.com -email admin@example.com -ssl A
```

| Option | Purpose | Required |
|---|---|---|
| `-domainname` | Domain pointing to the server | Yes |
| `-email` | Email for Let's Encrypt | Yes |
| `-ssl` | `A` = Let's Encrypt, `B` = self-signed, `C` = paid (you are asked for the certificate, key and CA bundle paths) | Yes |
| `-h`, `--help` | Help | - |

Passwords are shown at the end and saved in `credentials.txt` in this folder. Then [finish the setup in the browser](#14-finish-the-setup-in-the-browser).

---

## 14. Finish the setup in the browser

Only needed for the **Community Edition** or when you used `--skip-faveo-setup`.

1. Open `https://<your domain>` and follow the setup wizard.
2. On the database step, enter the details from `credentials.txt` (database host: `faveo-mysql`).
3. When the wizard is done, open the `.env` file in the `faveo/` folder and add this line:
   ```
   REDIS_HOST=faveo-redis
   ```
4. Restart the containers from the installation folder:
   ```sh
   docker compose down && docker compose up -d
   ```

---
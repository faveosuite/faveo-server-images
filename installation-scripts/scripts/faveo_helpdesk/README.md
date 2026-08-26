# Faveo Helpdesk Multi-OS Automated Installer

An enterprise-grade, automated Bash installation suite for deploying [Faveo Helpdesk](https://www.faveohelpdesk.com/) on Linux enterprise distributions. This installer handles the entire deployment pipeline—from OS verification and dependency provisioning to database orchestration, SSL/TLS termination, search engine setup, background queue worker configuration, and Faveo core application bootstrap.

---

## 📋 Table of Contents

1. [Architecture Overview](#-architecture-overview)
2. [Key Features](#-key-features)
3. [Supported Operating Systems & Matrix](#-supported-operating-systems--matrix)
4. [System Requirements & Prerequisites](#-system-requirements--prerequisites)
5. [Repository Structure](#-repository-structure)
6. [Installation & Usage](#-installation--usage)
   - [Method 1: Interactive Wizard Mode](#method-1-interactive-wizard-mode-recommended)
   - [Method 2: Unattended / Automated CLI Mode](#method-2-unattended--automated-cli-mode)
7. [Command-Line Arguments Reference](#-command-line-arguments-reference)
8. [Deployment Examples](#-deployment-examples)
9. [Technology Stack & Services Provisioned](#-technology-stack--services-provisioned)
10. [Post-Installation & Verification](#-post-installation--verification)
11. [Failure Recovery & Rollback Engine](#-failure-recovery--rollback-engine)
12. [Troubleshooting & FAQ](#-troubleshooting--faq)
13. [Maintainers & Support](#-maintainers--support)

---

## 🏗 Architecture Overview

The installation suite is split into a modular orchestrator and distribution-specific execution engines:

```
                  ┌───────────────────────────────┐
                  │           faveo.sh            │
                  │   (Root check, Shell verify,  │
                  │     OS detection & banner)    │
                  └───────────────┬───────────────┘
                                  │
         ┌────────────────────────┴────────────────────────┐
         │                                                 │
         ▼ (Debian / Ubuntu)                               ▼ (RHEL / Rocky / AlmaLinux / CentOS)
┌─────────────────────────────────┐               ┌─────────────────────────────────┐
│         debian_block.sh         │               │          rhel_block.sh          │
├─────────────────────────────────┤               ├─────────────────────────────────┤
│ • APT / Sury Repositories       │               │ • DNF / Remi / EPEL Modules     │
│ • Apache2 / Nginx (Debian paths)│               │ • Httpd / Nginx (RHEL paths)    │
│ • MySQL 8.0/8.4 / MariaDB 10/11 │               │ • MySQL 8.0/8.4 / MariaDB 10/11 │
│ • systemd / ufw integration     │               │ • SELinux / firewalld handling  │
└────────────────┬────────────────┘               └────────────────┬────────────────┘
                 │                                                 │
                 └────────────────────────┬────────────────────────┘
                                          │
                                          ▼
                     ┌─────────────────────────────────────────┐
                     │         Faveo Core Application          │
                     │  • PHP 8.4+ & IonCube Loader            │
                     │  • Redis & Supervisor Daemons           │
                     │  • Meilisearch Full-Text Engine         │
                     │  • NATS Discovery Server (Optional)     │
                     │  • Node.js 22.x & Puppeteer (Optional)  │
                     │  • Artisan CLI Auto-Installer           │
                     └─────────────────────────────────────────┘
```

1. **`faveo.sh` (Main Orchestrator)**:
   - Validates that the executing shell is native Bash and running with `root`/`sudo` privileges.
   - Detects the Linux distribution (`/etc/os-release` / `/etc/debian_version`) and validates OS major/minor compatibility.
   - Delegates installation arguments and environment variables to the respective engine (`debian_block.sh` or `rhel_block.sh`).

2. **`debian_block.sh` (Debian/Ubuntu Engine)**:
   - Integrates with Ondřej Surý / PPA repositories for modern PHP and Apache2/Nginx packages.
   - Handles `apt`-specific dependencies, `dpkg` packaging for `wkhtmltox`, and Debian service management.

3. **`rhel_block.sh` (RHEL-Family Engine)**:
   - Integrates with EPEL, Remi modular repositories, and CodeReady Builder (CRB / PowerTools).
   - Manages RHEL-specific intricacies (e.g., RHEL 10 modularity changes, Valkey/Redis modular streams, AppStream packages).
   - Configures SELinux (permissive transition for proxying) and `firewalld` port openings.

---

## 🚀 Key Features

- **Automated End-to-End Deployment**: Installs and tunes Web Servers, PHP runtime, Caching engines, Background workers, Database, and SSL certificates with zero manual file editing.
- **Dual Operating Modes**:
  - **Interactive Wizard**: Step-by-step guided prompt with validation loops and sane defaults.
  - **Unattended CLI**: Parameterized non-interactive flags suitable for CI/CD, Ansible, Terraform, and cloud-init scripts.
- **Intelligent Database Provisioning**:
  - Supports **Local** or **Remote** MySQL (8.0 / 8.4 LTS) and MariaDB (10.6 / 11.8).
  - Automatically fails over to alternate compatible SQL engines if a repository is unavailable on the target OS.
  - Full support for remote SSL-secured connections (`CA`, `Client Cert`, `Client Key`, and `Identity Verification`).
- **Modern Search Engine (Meilisearch)**: Automated download, systemd service creation, production security configuration, and master key generation.
- **Real-Time & Background Task Infrastructure**:
  - **Supervisor**: Manages Laravel Horizon queues, WebSocket servers, and NATS workers.
  - **Redis**: Low-latency caching and message broker.
  - **NATS Server**: Optional agent discovery & WebSocket broker on port `9235`.
  - **Node.js 22.x & Puppeteer**: Optional headless rendering engine for graphical asset reporting.
- **Automated SSL/TLS Lifecycle**:
  - **Let's Encrypt (Certbot)**: Automatic issuance and weekly renewal cron job configuration.
  - **Self-Signed SSL**: Elliptic Curve (prime256v1) root CA and domain cert creation with system trust store registration.
  - **Paid / Custom SSL**: File-based or base64-encoded certificate/key bundle ingestion.
- **Transactional Rollback Engine**: In the event of a fatal configuration or download failure, the installer cleans up installed packages, removes created system users, drops databases, purges repositories, and restores system state.

---

## 💻 Supported Operating Systems & Matrix

| Distribution Family | Version / Codename | Architecture | Supported Engines |
| :--- | :--- | :--- | :--- |
| **Ubuntu** | 20.04 LTS, 22.04 LTS, 24.04 LTS | `x86_64` / `amd64` | `debian_block.sh` |
| **Debian** | 11 (Bullseye), 12 (Bookworm), 13 (Trixie) | `x86_64` / `amd64` | `debian_block.sh` |
| **Red Hat Enterprise Linux (RHEL)** | 8.x, 9.x, 10.x | `x86_64` | `rhel_block.sh` |
| **Rocky Linux** | 8.x, 9.x, 10.x | `x86_64` | `rhel_block.sh` |
| **AlmaLinux** | 8.x, 9.x, 10.x | `x86_64` | `rhel_block.sh` |
| **CentOS Stream** | 8 / 9 | `x86_64` | `rhel_block.sh` |

---

## ⚙️ System Requirements & Prerequisites

### Minimum Hardware
- **CPU**: 4 vCPUs (4+ vCPUs recommended if Node.js/Puppeteer asset reports are enabled)
- **RAM**: 8 GB minimum (8+ GB recommended for production workloads with Meilisearch & Redis)
- **Disk Space**: 120 GB available SSD/NVMe storage and this depends on the data that accumalates in faveo.
- **Network**: Direct outbound access to ports 80 & 443 (package downloads, Let's Encrypt verification, etc..)

### Licensing & Domain Prerequisites
1. **Domain Name**: A fully qualified domain name (FQDN) with an `A` record pointing to the server's public IP address.(Also supports internal installation).
2. **Faveo License Key**: A 16-character license key obtained from [Faveo Billing Portal](https://billing.faveohelpdesk.com).
3. **Faveo Order Number**: An 8-character order identifier associated with your license.
4. **Elevated Privileges**: `root` or `sudo` access.
5. **Billing Access**: Server needs to have an active access to out billing and lincese portal domain's : (billing.faveohelpdesk.com & license.faveohelpdesk.com).

---

## 📁 Repository Structure

```
.
├── faveo.sh            # Main entry point & OS dispatcher
├── debian_block.sh     # Debian / Ubuntu provisioning module
├── rhel_block.sh       # RHEL / Rocky / AlmaLinux / CentOS provisioning module
└── README.md           # Documentation & usage guide
```

---

## 📥 Installation & Usage

### 1. Clone or Download the Repository

```bash
curl -sL "https://github.com/faveosuite/faveo-server-images/archive/refs/heads/master.tar.gz" \
  | tar -xz --strip-components=3 "faveo-server-images-master/installation-scripts/scripts/faveo_helpdesk"
cd faveo_heldpesk
chmod +x *
```

---

### Method 1: Interactive Wizard Mode (Recommended)

Run the main script with root privileges without arguments. The installer will present an interactive wizard:

```bash
sudo ./faveo.sh
```

#### What the wizard will prompt:
1. **Domain Name**: e.g., `support.example.com` (do not prefix with `https://`)
2. **Admin Email**: e.g., `admin@example.com` (used for Let's Encrypt and administrator alerts)
3. **License Code**: 16-character Faveo license
4. **Order Number**: 8-character Faveo order number
5. **Release Channel**: `1) Official (Stable)` (recommended), `2) RC`, or `3) Beta`
6. **Environment**: `1) Production` (recommended), `2) Development`, or `3) Testing`
7. **Meilisearch**: `Yes` (recommended for >100 tickets/day) or `No`
8. **NATS / Agent Discovery**: `Yes` or `No` (default: `No`)
9. **PHP Version**: `8.4` (default) or custom (`8.2`, `8.3`)
10. **Node.js & Puppeteer**: `Yes` (for asset graphical reports) or `No`
11. **SQL Server Engine**: `1) MySQL (8.0/8.4)` (default) or `2) MariaDB (10.6/11.8)`
12. **SQL Location**: `1) Local` (installed on server) or `2) Remote` (connect to RDS/existing DB)
13. **Web Server**: `1) Apache` or `2) Nginx`
14. **SSL/TLS Type**: `1) FreeSSL (Let's Encrypt)`, `2) Self-Signed`, or `3) Paid SSL`

---

### Method 2: Unattended / Automated CLI Mode

Pass arguments directly to `./faveo.sh` for non-interactive scripting:

```bash
sudo ./faveo.sh \
  --domain support.example.com \
  --email admin@example.com \
  --license ABCDEFGHIJKLMNOP \
  --order 12345678 \
  --webserver nginx \
  --ssl certbot \
  --sql mysql \
  --php 8.4 \
  --meili yes \
  --node yes \
  --nats no \
  --release official \
  --faveoenv production
```

---

## 🛠 Command-Line Arguments Reference

| CLI Option | Allowed Values | Default | Description |
| :--- | :--- | :--- | :--- |
| `--domain` | `string` (FQDN) | *Required* | Fully Qualified Domain Name for Faveo (e.g. `desk.example.com`) |
| `--email` | `email format` | *Required* | Administrative contact email address |
| `--license` | `16-char string` | *Required* | Faveo license serial key |
| `--order` | `8-char string` | *Required* | Faveo order identifier |
| `--webserver` | `apache` \| `nginx` | `apache` | HTTP web server software to install and configure |
| `--ssl` | `certbot` \| `self-signed` \| `paid-ssl` | `certbot` | SSL certificate provisioning method |
| `--sql` | `mysql` \| `mariadb` | `mysql` | Relational database management system |
| `--php` | `8.2`, `8.3`, `8.4` (or >= `8.2`) | `8.4` | PHP runtime version |
| `--release` | `official` \| `rc` \| `beta` | `official` | Faveo software release branch |
| `--faveoenv` | `production` \| `development` \| `testing` | `production` | Laravel application execution environment |
| `--meili` | `yes` \| `no` | `yes` | Install and configure Meilisearch full-text engine |
| `--node` | `yes` \| `no` | `no` | Install Node.js 22.x and Puppeteer for graphical reporting |
| `--nats` | `yes` \| `no` | `no` | Install NATS server for Agent network discovery |
| `--certfile` | `file path` \| `base64` \| `PEM` | *None* | Certificate path or PEM string (required if `--ssl paid-ssl`) |
| `--keyfile` | `file path` \| `base64` \| `PEM` | *None* | Private key path or PEM string (required if `--ssl paid-ssl`) |
| `--cacertfile` | `file path` \| `base64` \| `PEM` | *None* | CA bundle path or PEM string (required if `--ssl paid-ssl`) |
| `--sqlreser` | `yes` \| `no` | `no` | Set to `yes` if utilizing a remote database server |
| `--sqlhost` | `IP` \| `Hostname` | `localhost` | Remote database host address |
| `--sqlport` | `1-65535` | `3306` | Remote database port |
| `--sqlusername`| `string` | *None* | Remote database administrative user |
| `--sqlpassword`| `string` | *None* | Remote database administrative password |
| `--sqlsecure` | `yes` \| `no` | `no` | Enable SSL/TLS encryption for database traffic |
| `--sqlsslca` | `file path` \| `base64` \| `PEM` | *None* | MySQL SSL Certificate Authority file |
| `--sqlsslcert` | `file path` \| `base64` \| `PEM` | *None* | MySQL SSL client certificate file (optional) |
| `--sqlsslkey` | `file path` \| `base64` \| `PEM` | *None* | MySQL SSL client private key file (optional) |
| `--sqlsslverify`| `yes` \| `no` | `yes` | Verify SSL identity of the remote database server |
| `--help` | — | — | Display CLI usage reference and options list |

---

## 💡 Deployment Examples

### Example 1: Standard Production Setup with Nginx & Let's Encrypt
```bash
sudo ./faveo.sh \
  --domain helpdesk.mycompany.com \
  --email it-admin@mycompany.com \
  --license 1111222233334444 \
  --order 87654321 \
  --webserver nginx \
  --ssl certbot \
  --sql mysql \
  --php 8.4 \
  --meili yes \
  --release official \
  --faveoenv production
```

### Example 2: Enterprise Deployment with Remote AWS RDS MySQL & Custom Paid SSL
```bash
sudo ./faveo.sh \
  --domain support.enterprise.com \
  --email ops@enterprise.com \
  --license 5555666677778888 \
  --order 99887766 \
  --webserver apache \
  --ssl paid-ssl \
  --certfile /etc/ssl/certs/star_enterprise_com.crt \
  --keyfile /etc/ssl/private/star_enterprise_com.key \
  --cacertfile /etc/ssl/certs/enterprise_ca_bundle.crt \
  --sqlreser yes \
  --sqlhost rds-mysql.internal.enterprise.com \
  --sqlport 3306 \
  --sqlusername dbadmin \
  --sqlpassword "SuperSecretPass123" \
  --sqlsecure yes \
  --sqlsslca /etc/ssl/certs/rds-combined-ca-bundle.pem \
  --sqlsslverify yes \
  --php 8.4 \
  --meili yes \
  --node yes \
  --nats yes \
  --faveoenv production
```

### Example 3: Internal Staging Server with Self-Signed SSL & MariaDB
```bash
sudo ./faveo.sh \
  --domain faveo.local \
  --email staging@local.net \
  --license 9999888877776666 \
  --order 11223344 \
  --webserver nginx \
  --ssl self-signed \
  --sql mariadb \
  --php 8.4 \
  --meili no \
  --node no \
  --nats no \
  --release beta \
  --faveoenv development
```

---

## 🧰 Technology Stack & Services Provisioned

| Component | Software / Details | Configuration & Role |
| :--- | :--- | :--- |
| **Application Framework** | Laravel 11.x / PHP 8.4 | Deployed to `/var/www/faveo` |
| **PHP Runtime** | PHP-FPM (8.2 / 8.4+) | Tuned via `php.ini` (`memory_limit=256M`, `max_execution_time=360s`, `upload_max_filesize=100M`) |
| **PHP Extensions** | IonCube Loader, OPcache, Redis, Memcached, GD, MBString, XML, SOAP, IMAP, BCMath, GMP, Intl, Zip | Encrypted license verification & high-performance execution |
| **Web Server** | Apache 2.4 (`mpm_event` + `proxy_fcgi`) or Nginx | Handles HTTP/2, SSL termination, and reverse proxy for WebSockets (`/fc/`) and NATS (`/natsws`) |
| **Search Engine** | Meilisearch v1.x | Configured as systemd service with automated master key & dumps directory |
| **Cache & Queue Broker** | Redis Server | In-memory key-value cache and Laravel queue backend |
| **Process Manager** | Supervisor (`supervisord`) | Manages Horizon queue workers, WebSocket daemons, Node server, and NATS listeners |
| **Background Scheduler** | System Cron (`crontab`) | Executes `php artisan schedule:run` every minute under the web server user |
| **PDF Generation** | `wkhtmltopdf` / `wkhtmltox` | Headless HTML-to-PDF binary with font rendering dependencies |
| **Asset Graphing (Optional)**| Node.js 22.x & Puppeteer | Server-side chart rendering for IT asset management |
| **Agent Discovery (Optional)**| NATS Server v2.10 | Low-latency messaging for network discovery agents (Port 9235) |

---

## 📊 Post-Installation & Verification

Upon successful completion, the script prints an installation summary and creates a credential reference file:

```
╔══════════════════════════════════════════════════════╗
       Faveo Helpdesk Installation Summary             
╚══════════════════════════════════════════════════════╝
  URL:                   https://support.example.com
  Email:                 admin@example.com
  License Code:          ****************
  Order Number:          ********
  Release Selected:      official
  SQL Option:            mysql
  SQL Version Installed: 8.4.1
  PHP Version:           8.4
  Meilisearch Option:    yes
  Web Server:            nginx
  Node Option:           yes
  NATS Option:           no
  SSL Option:            certbot
  Database Username:     faveo
  Database Password:     <Randomly-Generated-Password>
  Meilisearch Key:       <Randomly-Generated-Master-Key>
  Faveo Login Username:  demo_admin
  Faveo Login Password:  demopass
  Faveo Environment:     production
╚══════════════════════════════════════════════════════╝
```

### 📄 Credentials Record
A copy of these installation details is automatically saved to:
```bash
cat ./credentials.txt
```

### 🔍 Verification Commands

Check the health of all backing services:

```bash
# Web Server
systemctl status nginx          # or systemctl status httpd / apache2

# PHP-FPM
systemctl status php*-fpm

# Database & Cache
systemctl status mysql          # or systemctl status mariadb
systemctl status redis          # or systemctl status redis-server

# Search & Supervisors
systemctl status meilisearch
systemctl status supervisor     # or systemctl status supervisord

# Horizon Queue Workers status
sudo -u www-data php /var/www/faveo/artisan horizon:status
```

---

## 🛡 Failure Recovery & Rollback Engine

The installation suite includes a self-healing rollback routine (`rollback()`). If any stage fails (such as an invalid domain DNS propagation, network dropout during package installation, failed database credentials, or incompatible PHP modules), the script triggers an automatic rollback:

1. **Service Teardown**: Stops and disables Meilisearch, NATS, Redis, Supervisor, Web Server, and PHP-FPM services.
2. **Package Purging**: Removes installed packages (`php-*`, `mysql-*`, `mariadb-*`, `httpd`/`apache2`, `nginx`, `nodejs`, `supervisor`, `redis`, `wkhtmltox`).
3. **Repository Cleanup**: Removes added third-party repository definitions (`remi*.repo`, `epel*.repo`, `mariadb*.repo`, `nodesource*`, Sury GPG keys) to keep the package manager clean.
4. **Database Cleanup**: Drops the `faveo` database and local `faveo` DB user if created locally.
5. **Storage Purge**: Deletes `/var/www/faveo`, log folders, temporary SSL keys, and crontabs.

---

## ❓ Troubleshooting & FAQ

### 1. Let's Encrypt / Certbot Fails
- **Cause**: Domain name DNS `A` record does not resolve to this server's public IP address, or port 80/443 is blocked.
- **Fix**: Verify DNS resolution using `dig +short yourdomain.com` and ensure your firewall/security group permits inbound traffic on ports 80 and 443.

### 2. SELinux Issues on RHEL / Rocky / AlmaLinux
- **Cause**: SELinux in `enforcing` mode can block Nginx/Apache reverse proxy sockets or PHP-FPM file writes.
- **Fix**: The RHEL module automatically sets SELinux to `permissive` in `/etc/selinux/config`. To check status, run `getenforce`.

### 3. Remote Database Connection Timed Out
- **Cause**: Cloud firewall / Security Group blocking inbound port 3306 on the remote host, or incorrect bind address (`bind-address = 127.0.0.1` on the DB host).
- **Fix**: Ensure the remote MySQL/MariaDB server allows incoming connections from this server's IP and uses `--sqlsecure yes` with valid CA certificates if required.

### 4. High Memory Consumption
- **Cause**: Running Meilisearch, Redis, Node.js Puppeteer, and Horizon workers simultaneously on a server with <4 GB RAM.
- **Fix**: Upgrade server memory or disable the optional Node.js (`--node no`) and Meilisearch (`--meili no`) features during installation.

---

## 👥 Maintainers & Support

- **Author**: Thirumoorthi Duraipandi
- **Email**: `thirumoorthi.duraipandi@faveohelpdesk.com`
- **Official Repository**: [faveosuite/faveo-server-images](https://github.com/faveosuite/faveo-server-images/)
- **Faveo Official Portal**: [https://www.faveohelpdesk.com](https://www.faveohelpdesk.com)
- **Knowledge Base & Documentation**: [Faveo Helpdesk Documentation](https://support.faveohelpdesk.com)

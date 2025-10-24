---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/redhat_mariadb_encryption/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-10-24
last_modified_by: Sivakumar
toc: true
title: Red Hat - MariaDB File Key Management Setup Guide
---
<img alt="Red Hat - MariaDB File Key Management Setup Guide" src="/docs/installation/providers/enterprise/AdvancedEncryptionEngine.png" width="200" />

## Introduction

This guide explains how to enable **File Key Management (FKM)** in **MariaDB** on **Red Hat Linux** to secure data at rest. It covers generating encryption keys, configuring MariaDB to use them, setting proper permissions and SELinux contexts, and verifying the setup. This ensures that your database files remain encrypted and protected from unauthorized access.

## Prerequisites

* **MariaDB Server 10.5+** installed
* Root or sudo privileges
* SELinux and systemd enabled
* MariaDB service running (`systemctl status mariadb`)

---

## Step 1: Create Encryption Directory and Keyfile

```bash
sudo mkdir -p /etc/mysql/encryption
cd /etc/mysql/encryption

# Generate 3 random encryption keys (IDs: 1, 2, 3)
for i in 1 2 3; do
    echo "$i;$(openssl rand -hex 32)" | sudo tee -a /etc/mysql/encryption/keyfile.txt
done

# Verify key file contents
cat /etc/mysql/encryption/keyfile.txt
```

**Example output:**

```
1;12ab45c67d8e90123456fabcdef78901234567890abcdef1234567890abcdef12
2;7890ab12cd34ef56123456789abcdef0123456789abcdef0123456789abcdef12
3;abcd1234567890ef1234567890abcdef1234567890abcdef1234567890abcd12
```

---

## Step 2: Secure the Keyfile

```bash
sudo chown mysql:mysql /etc/mysql/encryption/keyfile.txt
sudo chmod 600 /etc/mysql/encryption/keyfile.txt

# (Optional) Backup keyfile
sudo cp /etc/mysql/encryption/keyfile.txt /etc/mysql/encryption/keyfile.txt.backup
sudo chmod 600 /etc/mysql/encryption/keyfile.txt.backup
```

---

## Step 3: Edit MariaDB Configuration File

Edit the main configuration file:

```bash
sudo nano /etc/my.cnf.d/mariadb-server.cnf
```

Add the following under `[mysqld]`:

```ini
### Encryption Settings ###
plugin_load_add = file_key_management
file_key_management_filename = /etc/mysql/encryption/keyfile.txt
file_key_management_encryption_algorithm = AES_CTR

# Force immediate encryption state changes
innodb_encryption_rotate_key_age = 1
innodb_encryption_threads = 4
innodb_background_scrub_data_check_interval = 1
innodb_background_scrub_data_interval = 604800
```

---

## Step 4: Set SELinux Context (If Enforcing Mode)

```bash
sudo semanage fcontext -a -t mysqld_etc_t "/etc/mysql/encryption(/.*)?"
sudo restorecon -Rv /etc/mysql/encryption
```

If `semanage` is not available:

```bash
sudo yum install policycoreutils-python-utils -y
```

---

## Step 5: Restart MariaDB Service

```bash
sudo systemctl restart mariadb
sudo systemctl status mariadb
```

Check the logs for successful plugin load:

```bash
sudo tail -n 30 /var/log/mariadb/mariadb.log
```

You should **not** see any “failed to initialize key management” messages.

---

## Step 6: Verify Plugin Activation

Log in to MariaDB:

```bash
mysql -u root -p
```

Run:

```sql
SHOW PLUGINS;
```

**Expected Output:**

```
+-------------------------+---------+--------------------+--------------------------+---------+
| Name                    | Status  | Type               | Library                  | License |
+-------------------------+---------+--------------------+--------------------------+---------+
| file_key_management     | ACTIVE  | ENCRYPTION         | file_key_management.so   | GPL     |
+-------------------------+---------+--------------------+--------------------------+---------+
```

---
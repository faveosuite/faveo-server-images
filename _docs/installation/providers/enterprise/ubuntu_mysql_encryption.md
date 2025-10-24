---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/ubuntu_mysql_encryption/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-10-24
last_modified_by: Sivakumar
toc: true
title: Ubuntu - MySQL Keyring Component Setup Guide
---
<img alt="Ubuntu - MySQL Keyring Component Setup Guide" src="/docs/installation/providers/enterprise/AdvancedEncryptionEngine.png" width="200" />

## Introduction

This guide explains how to configure the **MySQL Keyring Component** on **Ubuntu** to securely manage encryption keys for data-at-rest protection. The Keyring Component stores encryption keys outside the database, enhancing security for InnoDB tables, redo logs, and temporary files.

## Step 1: Check MySQL Directory Variables

```sql
SHOW VARIABLES LIKE 'datadir';
-- Example Result: datadir => /var/lib/mysql/

SHOW VARIABLES LIKE 'plugin_dir';
-- Example Result: plugin_dir => /usr/lib/mysql/plugin/
```

## Step 2: Configure MySQL Server Component

```bash
cd /usr/sbin
nano mysqld.my
```

Add the following content:

```json
{
  "components": "file://component_keyring_file"
}
```

## Step 3: Configure Keyring Component in Plugin Directory

```bash
cd /usr/lib/mysql/plugin/
nano component_keyring_file.cnf
```

Add the following:

```json
{
  "path": "/var/lib/mysql-keyring/component_keyring_file",
  "read_only": false
}
```

## Step 4: Configure Keyring Component in Data Directory

```bash
cd /var/lib/mysql
nano component_keyring_file.cnf
```

Add the following:

```json
{
  "path": "/var/lib/mysql-keyring/component_keyring_file",
  "read_only": false
}
```

## Step 5: Set Directory Permissions

```bash
sudo mkdir -p /var/lib/mysql-keyring
sudo chown mysql:mysql /var/lib/mysql-keyring
sudo chmod 700 /var/lib/mysql-keyring
```

## Step 6: Restart MySQL Service

```bash
systemctl restart mysql
```

## Step 7: Configure AppArmor

```bash
sudo nano /etc/apparmor.d/usr.sbin.mysqld
```

Add the following lines to allow MySQL to access the keyring and server binaries:

```
# Allow execution of server binary
/usr/sbin/mysqld mr,
/usr/sbin/mysqld-debug mr,
/usr/sbin/mysqld.my r,    # add this line
```

## Step 8: Reload AppArmor Profile

```bash
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.mysqld
systemctl restart mysql
```

## Step 9: Verify Keyring Component

```sql
SELECT * FROM keyring_component_status WHERE 1;
```

Expected output:

```
+---------------------+-----------------------------------------------+
| STATUS_KEY          | STATUS_VALUE                                  |
+---------------------+-----------------------------------------------+
| Component_name      | component_keyring_file                        |
| Author              | Oracle Corporation                            |
| License             | GPL                                           |
| Implementation_name | component_keyring_file                        |
| Version             | 1.0                                           |
| Component_status    | Active                                        |
| Data_file           | /var/lib/mysql-keyring/component_keyring_file |
| Read_only           | No                                            |
+---------------------+-----------------------------------------------+
```
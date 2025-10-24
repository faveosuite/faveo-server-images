---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/windows_mariadb_encryption/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-10-24
last_modified_by: Sivakumar
toc: true
title: Windows - MariaDB File Key Management Setup Guide
---
<img alt="Windows - MariaDB File Key Management Setup Guide" src="/docs/installation/providers/enterprise/AdvancedEncryptionEngine.png" width="200" />

## Introduction

This guide provides step-by-step instructions to configure **File Key Management (FKM)** for **MariaDB** on **Windows**. The File Key Management plugin allows MariaDB to securely store encryption keys in a local key file, enabling **data-at-rest encryption** for tables, logs, and temporary files.

---

## **Step 1: Stop MariaDB Service**

```powershell
net stop mariadb
```

---

## **Step 2: Create Encryption Key Directory**

```powershell
mkdir "C:\Program Files\MariaDB 10.6\data\encryption"
```

---

## **Step 3: Generate Encryption Keys**

```powershell
$keyFile = "C:\Program Files\MariaDB 10.6\data\encryption\keyfile.txt"
Remove-Item $keyFile -ErrorAction SilentlyContinue

# Generate 3 random 256-bit keys
for ($i = 1; $i -le 3; $i++) {
    $randomBytes = New-Object byte[] 32
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($randomBytes)
    $hexKey = [BitConverter]::ToString($randomBytes).Replace('-', '')
    "$i;$hexKey" | Out-File -FilePath $keyFile -Append -Encoding ASCII -NoNewline
    if ($i -lt 3) { "`r`n" | Out-File -FilePath $keyFile -Append -Encoding ASCII -NoNewline }
}
```

Check keys:

```powershell
type "C:\Program Files\MariaDB 10.6\data\encryption\keyfile.txt"
```

---

## **Step 4: Configure `my.ini`**

```powershell
notepad "C:\Program Files\MariaDB 10.6\data\my.ini"
```

Add or update the following sections:

```ini
[mysqld]
datadir=C:/Program Files/MariaDB 10.6/data
port=3306
innodb_buffer_pool_size=1019M

# Encryption Configuration
plugin_load_add = file_key_management
file_key_management_filename = C:/Program Files/MariaDB 10.6/data/encryption/keyfile.txt

# Enable encryption
innodb_encrypt_tables = ON
innodb_encrypt_log = ON
innodb_encryption_threads = 4

# SSL Configuration
ssl-ca="C:/MySQL/ssl/ca.pem"
ssl-cert="C:/MySQL/ssl/server-cert.pem"
ssl-key="C:/MySQL/ssl/server-key.pem"
require_secure_transport=ON

[client]
port=3306
plugin-dir=C:/Program Files/MariaDB 10.6/lib/plugin
```
---

## **Step 5: Start MariaDB Service**

```powershell
net start mariadb
```
---

## **Step 6: Verify Encryption on Windows**

Inside the MariaDB prompt:

```sql
-- Check if the encryption plugin is active
SHOW PLUGINS;
```
**Expected output includes:**
```
+-----------------------+--------+------------+----------------------------+-------+
| Name                  | Status | Type       | Library                    | License |
+-----------------------+--------+------------+----------------------------+-------+
| file_key_management   | ACTIVE | ENCRYPTION | file_key_management.dll    | GPL    |
+-----------------------+--------+------------+----------------------------+-------+
```
---
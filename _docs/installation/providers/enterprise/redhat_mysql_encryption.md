---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/redhat_mysql_encryption/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-10-24
last_modified_by: Sivakumar
toc: true
title: Red Hat - MySQL Keyring Component Setup Guide
---
<img alt="Red Hat - MySQL Keyring Component Setup Guide" src="/docs/installation/providers/enterprise/AdvancedEncryptionEngine.png" width="200" />

## Introduction

This guide explains how to set up the **MySQL Keyring Component** on **Red Hat Linux** to securely manage encryption keys used for **data-at-rest encryption**. The Keyring Component allows MySQL to store encryption keys outside of database tables, improving security and compliance.

## Prerequisites

* MySQL 8.0+ installed
* Root or sudo access
* MySQL service running

---

## Step 1: Verify MySQL Configuration and Binary Location

```bash
# Connect to MySQL
mysql -u root -p

# In MySQL prompt:
SHOW VARIABLES LIKE 'datadir';
SHOW VARIABLES LIKE 'plugin_dir';
EXIT;

# Find MySQL binary location
sudo find /usr -name "mysqld" -type f 2>/dev/null
# Expected: /usr/libexec/mysqld (Red Hat specific)
```

**Expected Output:**

* `datadir` → `/var/lib/mysql/`
* `plugin_dir` → `/usr/lib64/mysql/plugin/`
* MySQL binary → `/usr/libexec/mysqld`

---

## Step 2: Create Keyring Directory Structure

```bash
sudo mkdir -p /var/lib/mysql-keyring
sudo chown mysql:mysql /var/lib/mysql-keyring
sudo chmod 750 /var/lib/mysql-keyring
```

---

## Step 3: Create Global Manifest File

> **CRITICAL:** Manifest file must be in the same directory as the MySQL binary.

```bash
cd /usr/libexec

sudo tee mysqld.my > /dev/null << 'EOF'
{
  "components": "file://component_keyring_file"
}
EOF

sudo chown mysql:mysql /usr/libexec/mysqld.my
sudo chmod 644 /usr/libexec/mysqld.my

# Set SELinux context
sudo chcon --reference=/usr/libexec/mysqld /usr/libexec/mysqld.my
```

---

## Step 4: Create Component Configuration File

```bash
cd /usr/lib64/mysql/plugin/

sudo tee component_keyring_file.cnf > /dev/null << 'EOF'
{
  "path": "/var/lib/mysql-keyring/component_keyring_file",
  "read_only": false
}
EOF

sudo chown mysql:mysql component_keyring_file.cnf
sudo chmod 644 component_keyring_file.cnf
```

---

## Step 5: Configure SELinux (Red Hat Specific)

```bash
sudo semanage fcontext -a -t mysqld_db_t "/var/lib/mysql-keyring(/.*)?" 2>/dev/null || true
sudo restorecon -Rv /var/lib/mysql-keyring

# Fallback if semanage is not available
sudo chcon -R --type=mysqld_db_t /var/lib/mysql-keyring 2>/dev/null || true
```

---

## Step 6: Verify File Structure

```bash
echo "=== Manifest File ==="
ls -la /usr/libexec/mysqld.my
cat /usr/libexec/mysqld.my

echo "=== Component Config File ==="
ls -la /usr/lib64/mysql/plugin/component_keyring_file.cnf
cat /usr/lib64/mysql/plugin/component_keyring_file.cnf

echo "=== Keyring Directory ==="
ls -la /var/lib/mysql-keyring/

echo "=== Component Library ==="
ls -la /usr/lib64/mysql/plugin/component_keyring_file.so
```

**Expected Output:**

* `/usr/libexec/mysqld.my` → `mysql:mysql`, 644
* `/usr/lib64/mysql/plugin/component_keyring_file.cnf` → `mysql:mysql`, 644
* `/var/lib/mysql-keyring/` → `mysql:mysql`, 750
* `/usr/lib64/mysql/plugin/component_keyring_file.so` exists

---

## Step 7: Restart MySQL Service

```bash
sudo systemctl restart mysqld
sudo systemctl status mysqld

# Check MySQL log for component loading
sudo tail -20 /var/log/mysql/mysqld.log
```

**Success indicators:**

* Manifest file read: `Manifest file '/usr/libexec/mysqld.my' is not read-only`
* No keyring-related errors
* Clean MySQL startup

---

## Step 8: Verify Keyring Component Installation

```bash
mysql -u root -p
```

**In MySQL, run:**

```sql

-- Check keyring component status
SELECT * FROM performance_schema.keyring_component_status;
```

**Expected Output:**

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
---
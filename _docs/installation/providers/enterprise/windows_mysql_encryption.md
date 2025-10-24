---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/windows_mysql_encryption/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-10-24
last_modified_by: Sivakumar
toc: true
title: Windows - MySQL Keyring Component Setup Guide
---
<img alt="Windows - MySQL Keyring Component Setup Guide" src="/docs/installation/providers/enterprise/AdvancedEncryptionEngine.png" width="200" />

## Introduction

This guide explains how to configure the **MySQL Keyring Component** on **Windows** to securely store and manage encryption keys used for **data-at-rest encryption**. The Keyring Component provides a secure, file-based method for MySQL to handle encryption keys outside the database, protecting sensitive data such as InnoDB tables, logs, and temporary files.

---

## **Step 1 – Create Keyring Folder and File**

```powershell
mkdir "C:\ProgramData\MySQL\MySQL Server 8.0\mysql-keyring" -Force
New-Item -Path "C:\ProgramData\MySQL\MySQL Server 8.0\mysql-keyring\component_keyring_file" -ItemType File -Force
```

---

## **Step 2 – Create Component Config File**

```powershell
notepad "C:\Program Files\MySQL\MySQL Server 8.0\lib\plugin\component_keyring_file.cnf"
```

Paste:

```json
{
  "path": "C:/ProgramData/MySQL/MySQL Server 8.0/mysql-keyring/component_keyring_file",
  "read_only": false
}
```

---

## **Step 3 – Create Server Manifest File**

```powershell
notepad "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqld.my"
```

Paste:

```json
{
  "components": "file://component_keyring_file"
}
```

---

## **Step 4 – Set Permissions**

```powershell
icacls "C:\ProgramData\MySQL\MySQL Server 8.0\mysql-keyring" /grant "NT SERVICE\MySQL80:(OI)(CI)F" /T
icacls "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqld.my" /grant "NT SERVICE\MySQL80:R"
icacls "C:\Program Files\MySQL\MySQL Server 8.0\lib\plugin\component_keyring_file.cnf" /grant "NT SERVICE\MySQL80:R"
```

---

## **Step 5 – Restart MySQL Service**

```powershell
net stop MySQL80
net start MySQL80
```

---

## **Step 6 – Verify Keyring Component**

```sql
SELECT * FROM performance_schema.keyring_component_status;
```

**Expected output includes:**
```
+---------------------+----------------------------------------------------------------------------+
| STATUS_KEY          | STATUS_VALUE                                                               |
+---------------------+----------------------------------------------------------------------------+
| Component_name      | component_keyring_file                                                     |
| Author              | Oracle Corporation                                                         |
| License             | GPL                                                                        |
| Implementation_name | component_keyring_file                                                     |
| Version             | 1.0                                                                        |
| Component_status    | Active                                                                     |
| Data_file           | C:/ProgramData/MySQL/MySQL Server 8.0/mysql-keyring/component_keyring_file |
| Read_only           | No                                                                         |
+---------------------+----------------------------------------------------------------------------+
```
---
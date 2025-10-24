---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/windows_mysql_ssl/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-10-24
last_modified_by: Sivakumar
toc: true
title: Windows - MySQL or MariaDB SSL Certificate Setup Guide
---
<img alt="Windows - MySQL or MariaDB SSL Certificate Setup Guide" src="/docs/installation/providers/enterprise/AdvancedEncryptionEngine.png" width="200" />

## Introduction

This guide provides step-by-step instructions to configure **SSL certificates for MySQL or MariaDB** on **Windows**, enabling secure encrypted connections between clients and the MySQL server. By creating a **Certificate Authority (CA)**, server, and client certificates, and configuring MySQL to use them, you ensure that data in transit is protected from interception or tampering.

---

## **Prerequisites**

* MySQL Server installed (e.g., MySQL 8.0)
* OpenSSL installed
* Administrative access to Windows
* Basic understanding of SSL certificates

---

## **Step 1: Create SSL Directory**

```powershell
New-Item -ItemType Directory -Path "C:\MySQL\ssl" -Force
cd "C:\MySQL\ssl"
```

---

## **Step 2: Generate Certificates**

### 2.1 CA Certificate

```powershell
openssl genrsa -out ca-key.pem 2048
openssl req -x509 -new -nodes -key ca-key.pem -sha256 -days 3650 -out ca.pem -subj "/C=IN/ST=TN/O=MyOrg/CN=MySQL-CA"
```

### 2.2 Server Certificate

```powershell
openssl genrsa -out server-key.pem 2048
openssl req -new -key server-key.pem -out server-req.pem -subj "/C=IN/ST=TN/O=MyOrg/CN=localhost"

@"
[ v3_req ]
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
IP.1 = 127.0.0.1
"@ | Out-File -Encoding ascii san.cnf

openssl x509 -req -in server-req.pem -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -days 3650 -sha256 -extfile san.cnf -extensions v3_req
```

### 2.3 Client Certificate

```powershell
openssl genrsa -out client-key.pem 2048
openssl req -new -key client-key.pem -out client-req.pem -subj "/C=IN/ST=TN/O=MyOrg/CN=MySQL-Client"
openssl x509 -req -in client-req.pem -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out client-cert.pem -days 3650 -sha256
```

---

## **Step 3: Set Windows Permissions**

### 3.1 Take Ownership of the SSL Folder

```powershell
takeown /F "C:\MySQL\ssl" /R /D Y
```

### 3.2 Grant MySQL Full Control

```powershell
icacls "C:\MySQL\ssl" /grant "NT SERVICE\MySQL80:(OI)(CI)F" /T
```

### 3.3 Allow Admin and IIS Read Access

```powershell
icacls "C:\MySQL\ssl" /grant "Administrators:(OI)(CI)F" /T
icacls "C:\MySQL\ssl" /grant "IIS_IUSRS:(R)" /T
```

### 3.4 Verify Permissions

```powershell
icacls "C:\MySQL\ssl"
```

Expected output:

```
C:\MySQL\ssl NT SERVICE\MySQL80:(OI)(CI)(F)
                Administrators:(OI)(CI)(F)
                IIS_IUSRS:(R)
```

---

## **Verify SSL Files**

Open **PowerShell** and run:

```powershell
Test-Path "C:\MySQL\ssl\ca.pem"
Test-Path "C:\MySQL\ssl\server-cert.pem"
Test-Path "C:\MySQL\ssl\server-key.pem"
```

**Expected output:**

```
True
True
True
```

> All True outputs confirm that the SSL files exist and are accessible by MySQL.

## **Step 4: Configure MySQL (`my.ini`)**

```ini
[mysqld]
ssl-ca="C:/MySQL/ssl/ca.pem"
ssl-cert="C:/MySQL/ssl/server-cert.pem"
ssl-key="C:/MySQL/ssl/server-key.pem"
require_secure_transport=ON

log_error="C:/ProgramData/MySQL/MySQL Server 8.0/Data/mysql_error.log"
```

> Use forward slashes `/` in Windows paths.

---

## **Step 5: Restart MySQL**

```powershell
Restart-Service MySQL80
```

* If MySQL fails to start, check:

```powershell
notepad "C:\ProgramData\MySQL\MySQL Server 8.0\Data\mysql_error.log"
```

---

## **Step 6: Verify SSL**

Open **Command Prompt or PowerShell** and run:

```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p -h 127.0.0.1 `
--ssl-ca="C:/MySQL/ssl/ca.pem" `
--ssl-cert="C:/MySQL/ssl/client-cert.pem" `
--ssl-key="C:/MySQL/ssl/client-key.pem"
```

Inside MySQL:

```sql
SHOW STATUS LIKE 'Ssl_cipher';
```

**Expected output:**

```
+---------------+------------------------+
| Variable_name | Value                  |
+---------------+------------------------+
| Ssl_cipher    | TLS_AES_256_GCM_SHA384 |
+---------------+------------------------+
```

```sql
SHOW VARIABLES LIKE '%ssl%';
```

**Expected output:**

```
+-------------------------+--------------------------------------+
| Variable_name           | Value                                |
+-------------------------+--------------------------------------+
| have_openssl            | YES                                  |
| have_ssl                | YES                                  |
| ssl_ca                  | C:/MySQL/ssl/ca.pem                  |
| ssl_capath              |                                      |
| ssl_cert                | C:/MySQL/ssl/server-cert.pem         |
| ssl_cipher              |                                      |
| ssl_crl                 |                                      |
| ssl_crlpath             |                                      |
| ssl_key                 | C:/MySQL/ssl/server-key.pem          |
+-------------------------+--------------------------------------+
```

---

## **Step 7: Require SSL for Users**

```sql
ALTER USER 'username'@'localhost' REQUIRE X509;
```

This enforces that `username` must connect using a **client certificate**.

---

### **Verify SSL Requirement**

```sql
SELECT User, Host, ssl_type FROM mysql.user;
```

**Expected output after `ALTER USER`:**

```
+----------+-----------+---------+
| User     | Host      | ssl_type|
+----------+-----------+---------+
| root     | localhost | ANY     |
| username | localhost | X509    |
+----------+-----------+---------+
```

---
## **Step 8: Application Connection Details**

* **Host**: **`127.0.0.1`** ← **Important**
* **SSL CA**: `C:/MySQL/ssl/ca.pem`
* **SSL Key**: `C:/MySQL/ssl/client-key.pem`
* **SSL Cert**: `C:/MySQL/ssl/client-cert.pem`

---
To continue with the **encryption setup**, click below:

- [Click here for Windows - MySQL Encryption Setup](/docs/installation/providers/enterprise/windows_mysql_encryption/)
- [Click here for Windows - MariaDB Encryption Setup](/docs/installation/providers/enterprise/windows_mariadb_encryption/)
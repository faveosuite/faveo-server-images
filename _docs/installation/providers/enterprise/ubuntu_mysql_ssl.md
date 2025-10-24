---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/ubuntu_mysql_ssl/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-10-24
last_modified_by: Sivakumar
toc: true
title: Ubuntu - MySQL or MariaDB SSL Certificate Setup Guide
---
<img alt="Ubuntu - MySQL or MariaDB SSL Certificate Setup Guide" src="/docs/installation/providers/enterprise/AdvancedEncryptionEngine.png" width="200" />

## Introduction

This guide explains how to configure **SSL certificates for MySQL or MariaDB** on **Ubuntu** to secure client-server communications. By creating a **Certificate Authority (CA)**, server, and client certificates, and configuring the database server to use them, you ensure that all connections are encrypted and protected from eavesdropping or tampering.

## Prerequisites

* MySQL or MariaDB server installed
* OpenSSL installed
* Root or sudo privileges

## Step 1: Create SSL Directory

```bash
sudo mkdir -p /etc/mysql/ssl
cd /etc/mysql/ssl
```

## Step 2: Generate CA Certificate

```bash
sudo openssl genrsa -out ca-key.pem 2048
sudo openssl req -x509 -new -nodes -key ca-key.pem -sha256 -days 3650 -out ca.pem \
-subj "/C=IN/ST=TN/O=MyOrg/CN=MySQL-CA" -addext "basicConstraints=CA:TRUE"
```

## Step 3: Generate Server Certificate

```bash
sudo openssl genrsa -out server-key.pem 2048
sudo openssl req -new -key server-key.pem -out server-req.pem -subj "/C=IN/ST=TN/O=MyOrg/CN=localhost"

cat > /etc/mysql/ssl/san.cnf <<EOF
[ v3_req ]
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
IP.1 = 127.0.0.1
EOF

sudo openssl x509 -req -in server-req.pem -CA ca.pem -CAkey ca-key.pem -CAcreateserial \
-out server-cert.pem -days 3650 -sha256 -extfile /etc/mysql/ssl/san.cnf -extensions v3_req
```

## Step 4: Generate Client Certificate

```bash
sudo openssl genrsa -out client-key.pem 2048
sudo openssl req -new -key client-key.pem -out client-req.pem -subj "/C=IN/ST=TN/O=MyOrg/CN=MySQL-Client"
sudo openssl x509 -req -in client-req.pem -CA ca.pem -CAkey ca-key.pem -CAcreateserial \
-out client-cert.pem -days 3650 -sha256
```

## Step 5: Set Permissions

### For MySQL server only

```bash
sudo chown mysql:mysql /etc/mysql/ssl/*.pem
sudo chmod 600 /etc/mysql/ssl/*.pem
```

### For web application access

```bash
sudo chmod 750 /etc/mysql/ssl
sudo chmod 640 /etc/mysql/ssl/*.pem
sudo chown mysql:www-data /etc/mysql/ssl/client-cert.pem
sudo chown mysql:www-data /etc/mysql/ssl/client-key.pem  
sudo chown mysql:www-data /etc/mysql/ssl/ca.pem
```

## Step 6: Configure MySQL / MariaDB

### For MySQL

Edit the MySQL configuration file:

```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

Add the following lines under `[mysqld]`:

```ini
[mysqld]
ssl-ca=/etc/mysql/ssl/ca.pem
ssl-cert=/etc/mysql/ssl/server-cert.pem
ssl-key=/etc/mysql/ssl/server-key.pem
require_secure_transport=ON
```

---

### For MariaDB

Edit the MariaDB configuration file:

```bash
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

Add the following lines under `[mysqld]`:

```ini
[mysqld]
ssl-ca=/etc/mysql/ssl/ca.pem
ssl-cert=/etc/mysql/ssl/server-cert.pem
ssl-key=/etc/mysql/ssl/server-key.pem
require_secure_transport=ON
```

---

After editing, **restart the database service**:

```bash
sudo systemctl restart mysql
```

## Step 7: Verify SSL

```bash
mysql -u root -p --ssl-ca=/etc/mysql/ssl/ca.pem \
--ssl-cert=/etc/mysql/ssl/client-cert.pem \
--ssl-key=/etc/mysql/ssl/client-key.pem

```
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
| ssl_ca                  | /etc/mysql/ssl/ca.pem                |
| ssl_capath              |                                      |
| ssl_cert                | /etc/mysql/ssl/server-cert.pem       |
| ssl_cipher              |                                      |
| ssl_crl                 |                                      |
| ssl_crlpath             |                                      |
| ssl_key                 | /etc/mysql/ssl/server-key.pem        |
+-------------------------+--------------------------------------+
```


## Step 8: Require SSL for Users

```sql
ALTER USER 'username'@'localhost' REQUIRE X509;
```

This enforces that `username` must connect using a **client certificate**.

---

### Verify SSL Requirement

```sql
SELECT User, Host, ssl_type FROM mysql.user;
```

**Expected output after ALTER USER:**

```
+----------+-----------+---------+
| User     | Host      | ssl_type|
+----------+-----------+---------+
| root     | localhost | ANY     |
| username | localhost | X509    |
+----------+-----------+---------+
```
### Application Connection Details

* **Host**: **`127.0.0.1`** ← **Important:** Use `127.0.0.1` instead of `localhost` to ensure SSL connections work properly.
* **SSL CA**: `/etc/mysql/ssl/ca.pem`
* **SSL Key**: `/etc/mysql/ssl/client-key.pem`
* **SSL Cert**: `/etc/mysql/ssl/client-cert.pem`

---
To continue with the **encryption setup**, click below:

- [Click here for Ubuntu - MySQL Encryption Setup](/docs/installation/providers/enterprise/ubuntu_mysql_encryption/)
- [Click here for Ubuntu - MariaDB Encryption Setup](/docs/installation/providers/enterprise/ubuntu_mariadb_encryption/)
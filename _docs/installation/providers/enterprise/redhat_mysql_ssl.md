---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/redhat_mysql_ssl/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-10-24
last_modified_by: Sivakumar
toc: true
title: Red Hat - MySQL or MariaDB SSL Setup Guide
---
<img alt="Red Hat - MySQL or MariaDB SSL Setup Guide" src="/docs/installation/providers/enterprise/AdvancedEncryptionEngine.png" width="200" />

## Introduction

This guide explains how to configure **SSL certificates for MySQL or MariaDB** on **RHEL/CentOS** to secure client-server communications. By creating a **Certificate Authority (CA)**, server, and client certificates, and configuring MySQL to use them, you ensure that all database connections are encrypted, protecting sensitive data in transit from eavesdropping or tampering.

## Prerequisites

* OpenSSL installed
* Root or sudo privileges
* Firewall configured for MySQL access (optional if connecting remotely)

---

## Step 1: Create SSL Directory

```bash
sudo mkdir -p /var/lib/mysql/ssl
sudo chown -R mysql:mysql /var/lib/mysql/ssl
cd /var/lib/mysql/ssl
```

---

## Step 2: Create Certificate Authority (CA)

Generate the CA private key:

```bash
sudo openssl genrsa -out ca-key.pem 2048
```

Generate the CA certificate:

```bash
sudo openssl req -x509 -new -nodes -key ca-key.pem -sha256 -days 3650 -out ca.pem \
-subj "/C=US/ST=CA/L=RedHat/O=MyOrg/CN=MySQL-CA" \
-addext "basicConstraints=CA:TRUE"
```

---

## Step 3: Create Server Certificate

Generate server private key:

```bash
sudo openssl genrsa -out server-key.pem 2048
```

Create server certificate signing request (CSR):

```bash
HOSTNAME=$(hostname -f)
sudo openssl req -new -key server-key.pem -out server-req.pem \
-subj "/C=US/ST=CA/L=RedHat/O=MyOrg/CN=${HOSTNAME}"
```

Create Subject Alternative Names (SAN) configuration:

```bash
SERVER_IP=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')

sudo tee /var/lib/mysql/ssl/san.cnf > /dev/null <<EOF
[ v3_req ]
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
DNS.2 = $(hostname -f)
DNS.3 = $(hostname -s)
IP.1 = 127.0.0.1
IP.2 = ${SERVER_IP}
EOF
```

Sign the server certificate with the CA:

```bash
sudo openssl x509 -req -in server-req.pem -CA ca.pem -CAkey ca-key.pem \
-CAcreateserial -out server-cert.pem -days 3650 -sha256 \
-extfile /var/lib/mysql/ssl/san.cnf -extensions v3_req
```

---

## Step 4: Create Client Certificate

Generate client private key:

```bash
sudo openssl genrsa -out client-key.pem 2048
```

Create client certificate signing request:

```bash
sudo openssl req -new -key client-key.pem -out client-req.pem \
-subj "/C=US/ST=CA/L=RedHat/O=MyOrg/CN=MySQL-Client"
```

Sign client certificate:

```bash
sudo openssl x509 -req -in client-req.pem -CA ca.pem -CAkey ca-key.pem \
-CAcreateserial -out client-cert.pem -days 3650 -sha256
```

---

## Step 5: Set File Permissions & SELinux Contexts

### For MySQL Server Access

```bash
sudo chown -R mysql:mysql /var/lib/mysql/ssl
sudo chmod 750 /var/lib/mysql/ssl
sudo chmod 600 /var/lib/mysql/ssl/*.pem
```

### For Web Application Access (Apache)

```bash
sudo chmod 750 /var/lib/mysql/ssl
sudo chmod 640 /var/lib/mysql/ssl/*.pem
sudo chown mysql:apache /var/lib/mysql/ssl/client-cert.pem
sudo chown mysql:apache /var/lib/mysql/ssl/client-key.pem
sudo chown mysql:apache /var/lib/mysql/ssl/ca.pem
```

### SELinux Context (RHEL/CentOS)

```bash
sudo semanage fcontext -a -t mysqld_db_t "/var/lib/mysql/ssl(/.*)?"
sudo restorecon -R /var/lib/mysql/ssl
ls -laZ /var/lib/mysql/ssl/
```

---

## Step 6: Configure MySQL SSL Settings

Create SSL configuration file:

```bash
sudo tee /etc/my.cnf.d/ssl.cnf > /dev/null <<EOF
[mysqld]
ssl-ca=/var/lib/mysql/ssl/ca.pem
ssl-cert=/var/lib/mysql/ssl/server-cert.pem
ssl-key=/var/lib/mysql/ssl/server-key.pem

# Bind to all interfaces (for remote connections)
bind-address=0.0.0.0

# Optional: Force SSL for all connections (enable after testing)
# require_secure_transport=ON
EOF
```

Restart MySQL:

```bash
sudo systemctl restart mysqld
sudo systemctl status mysqld
```

---

## Step 7: Configure Firewall

```bash
sudo firewall-cmd --permanent --add-service=mysql
sudo firewall-cmd --reload
sudo firewall-cmd --list-all
```

---

## Step 8: Verify SSL Connection

```bash
mysql -u root -p --ssl-ca=/var/lib/mysql/ssl/ca.pem \
--ssl-cert=/var/lib/mysql/ssl/client-cert.pem \
--ssl-key=/var/lib/mysql/ssl/client-key.pem
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
---
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

## Step 9: Require SSL for Users

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

---

## Step 10: Configure Applications (Web Access - Apache)

* **Host**: **`127.0.0.1`** ← **Important:** Use `127.0.0.1` instead of `localhost` to ensure SSL connections work properly.
* **SSL CA**: `/var/lib/mysql/ssl/ca.pem`
* **SSL Key**: `/var/lib/mysql/ssl/client-key.pem`
* **SSL Cert**: `/var/lib/mysql/ssl/client-cert.pem`

---
To continue with the **encryption setup**, click below:

- [Click here for Red Hat - MySQL Encryption Setup](/docs/installation/providers/enterprise/redhat_mysql_encryption/)
- [Click here for  Red Hat - MariaDB Encryption Setup](/docs/installation/providers/enterprise/redhat_mariadb_encryption/)
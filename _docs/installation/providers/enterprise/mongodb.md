---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/mongodb/
last_modified_at: 2026-11-20
last_modified_by: Sivakumar
toc: true
title: Installing MongoDB for Faveo Helpdesk (Elea AI Assistant)
---

<img alt="MongoDB" src="https://www.svgrepo.com/show/331488/mongodb.svg" width="150" height="150" />


## Introduction

This guide walks you through installing **MongoDB 9.0 Community Edition** and preparing it for Faveo Helpdesk.

### Elea AI Assistant

<img alt="Elea AI Assistant" src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/GUI-images/elea-avatar.svg" width="80" height="80" />

MongoDB is used **only by the Elea AI Assistant plugin**. All core helpdesk data (tickets, users, settings and so on) stays in MySQL.

Elea stores **vector embeddings** in MongoDB. These power AI (meaning-based) search: Elea finds the content that best matches a customer's question and passes it to the AI, so replies are based on your own documentation and not invented.

| Collection | What it stores |
|------------|----------------|
| `elea_crawler_content_vector` | Embeddings of crawled website and knowledge-base content (Elea Data Sources) |
| `elea_agent_transfer_vector` | Embeddings used by AI agents for transfer and handoff decisions |

**Why MongoDB and not MySQL?**

- **Vector search:** MongoDB can store embeddings and run similarity queries. MySQL has no native vector index.
- **Flexible documents:** Each embedding holds chunk text, a source URL, metadata and a large array of numbers, which suits a document database.
- **Bulk indexing:** Crawling and re-indexing write many records without bloating the helpdesk database.
- **Isolation:** Heavy AI indexing does not slow down ticket operations. MongoDB can even run on a separate server.

This guide covers both:

- **Debian based systems**: Ubuntu, Debian
- **RedHat based systems**: RHEL, Alma Linux, Rocky Linux

Where the commands differ, each step has a separate block for each OS family. Run only the block that matches your server. Windows servers are covered in a [separate section](#windows-servers).

---

## Before You Start

Make sure the following are true:

- Your server runs one of the supported operating systems listed below (64-bit).
- You have `sudo` access to the server.
- Faveo Helpdesk is installed and working.

> **Good to know:** MongoDB is **optional**. You only need it if you use the Elea AI Assistant. Without MongoDB, Faveo shows a warning for the Elea knowledge-base features and everything else works normally.

### Supported operating systems

| OS family | Supported versions |
|-----------|--------------------|
| Ubuntu | 22.04 LTS (Jammy), 24.04 LTS (Noble) |
| Debian | 12 (Bookworm), 13 (Trixie) |
| RHEL / Alma Linux / Rocky Linux | 8, 9, 10 |
| Windows | Windows Server 2022 |

### Names used on each OS

Some names differ between the two OS families. Keep this table handy:

| Item | Debian / Ubuntu | RedHat / Alma / Rocky |
|------|-----------------|-----------------------|
| Package manager | `apt` | `dnf` |
| Repository file | `/etc/apt/sources.list.d/mongodb-org-9.0.list` | `/etc/yum.repos.d/mongodb-org-9.0.repo` |
| MongoDB service | `mongod` | `mongod` |
| Configuration file | `/etc/mongod.conf` | `/etc/mongod.conf` |
| Default port | `27017` | `27017` |
| Firewall tool | `ufw` | `firewalld` |
| PHP MongoDB extension package (PHP 8.4) | `php8.4-mongodb` | `php-pecl-mongodb2` |
| Apache service | `apache2` | `httpd` |
| PHP-FPM service (PHP 8.4) | `php8.4-fpm` | `php-fpm` |

### Quick overview of the steps

| Step | What you do |
|------|-------------|
| 1 | Add the MongoDB repository |
| 2 | Install MongoDB |
| 3 | Start MongoDB and enable it on boot |
| 4 | Create an administrator user |
| 5 | Create the Faveo (Elea) database user |
| 6 | Enable authentication |
| 7 | Test the login |
| 8 | Allow remote connections (only if MongoDB is on a separate server) |
| 9 | Install the PHP MongoDB extension on the Faveo server |
| 10 | Connect Faveo to MongoDB |
| 11 | Verify everything works |

---

## Step 1: Add the MongoDB Repository

### Debian / Ubuntu

**1. Install the required tools and import the MongoDB signing key:**

```
sudo apt-get update
sudo apt-get install -y gnupg curl

curl -fsSL https://pgp.mongodb.com/server-9.asc | \
  sudo gpg -o /usr/share/keyrings/mongodb-server-9.gpg \
  --dearmor
```

**2. Add the repository.** Run **only the one line** that matches your OS version.

**Ubuntu 24.04 (Noble):**

```
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-9.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/9.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-9.0.list
```

**Ubuntu 22.04 (Jammy):**

```
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-9.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/9.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-9.0.list
```

**Debian 13 (Trixie):**

```
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-9.gpg ] https://repo.mongodb.org/apt/debian trixie/mongodb-org/9.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-9.0.list
```

**Debian 12 (Bookworm):**

```
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-9.gpg ] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/9.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-9.0.list
```

> **Not sure which version you have?** Run `cat /etc/os-release` and look at `VERSION_CODENAME`.

### RedHat / Alma / Rocky

Create the repository file. Run **only the block** that matches your OS version.

**Version 8:**

```
sudo tee /etc/yum.repos.d/mongodb-org-9.0.repo << 'EOF'
[mongodb-org-9.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/8/mongodb-org/9.0/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-9.asc
EOF
```

**Version 9:**

```
sudo tee /etc/yum.repos.d/mongodb-org-9.0.repo << 'EOF'
[mongodb-org-9.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/9.0/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-9.asc
EOF
```

**Version 10:**

```
sudo tee /etc/yum.repos.d/mongodb-org-9.0.repo << 'EOF'
[mongodb-org-9.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/10/mongodb-org/9.0/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-9.asc
EOF
```

> **Not sure which version you have?** Run `cat /etc/os-release` and look at `VERSION_ID`.

---

## Step 2: Install MongoDB

This installs the MongoDB server (`mongod`), the MongoDB shell (`mongosh`) and the related tools.

**Debian / Ubuntu:**

```
sudo apt-get update
sudo apt-get install -y mongodb-org
```

**RedHat / Alma / Rocky:**

```
sudo dnf install -y mongodb-org
```

Check the installed version:

```
mongod --version
```

You should see `db version v9.0.x`.

---

## Step 3: Start MongoDB and Enable It on Boot

This step is the same on all operating systems:

```
sudo systemctl enable --now mongod
sudo systemctl status mongod
```

You should see **active (running)** in the output.

---

## Step 4: Create an Administrator User

The administrator user manages the whole MongoDB server (backups, monitoring, other databases and users). Create it **before** enabling authentication.

**1. Open the MongoDB shell:**

```
mongosh
```

**2. Switch to the `admin` database and create the user:**

```
use admin
```

```
db.createUser({
  user: "admin",
  pwd: passwordPrompt(),
  roles: [ { role: "root", db: "admin" } ]
})
```

Enter a strong password when prompted. You should see `{ ok: 1 }`.

> **Why `passwordPrompt()`?** It asks for the password instead of having you type it in the command, so the password is not saved in the shell history.

Stay in the MongoDB shell for the next step.

---

## Step 5: Create the Faveo (Elea) Database User

**1. Switch to the Faveo database:**

```
use faveo-elea
```

**2. Create the user:**

```
db.createUser({
  user: "faveo-elea",
  pwd: passwordPrompt(),
  roles: [ { role: "dbOwner", db: "faveo-elea" } ]
})
```

Enter a strong password when prompted and **save it somewhere safe**. You will need it in [Step 10](#step-10-connect-faveo-to-mongodb).

The `dbOwner` role gives this user full control of the `faveo-elea` database **only**. It cannot access any other database.

**3. Check the user was created:**

```
db.getUsers()
```

**4. Exit the shell:**

```
exit
```

> **Good to know:** You do not need to create the `faveo-elea` database yourself. Faveo creates it, with its collections, automatically after you connect it in [Step 10](#step-10-connect-faveo-to-mongodb). Until then, it will not appear in `show dbs`. This is normal.

---

## Step 6: Enable Authentication

By default MongoDB allows anyone on the server to connect without a password. This step turns on password protection.

**1. Open the MongoDB configuration file:**

```
sudo nano /etc/mongod.conf
```

**2. Find this line:**

```
#security:
```

Replace it with:

```
security:
  authorization: enabled
```

> **Important:** Use **two spaces** (not a tab) before `authorization`. Do not add a second `security:` line. Either mistake stops MongoDB from starting.

**3. Restart MongoDB and check it is running:**

```
sudo systemctl restart mongod
sudo systemctl status mongod
```

You should see **active (running)** in the output.

---

## Step 7: Test the Login

**1. Log in as the Faveo user** (you will be asked for the password):

```
mongosh --username "faveo-elea" --password --authenticationDatabase "faveo-elea" "mongodb://127.0.0.1:27017/faveo-elea"
```

**2. Confirm the login inside the shell:**

```
db.runCommand({ connectionStatus: 1 })
```

The output should show `user: 'faveo-elea'` and `ok: 1`. Type `exit` to leave.

**3. Log in as the administrator** to confirm that account works too:

```
mongosh --username "admin" --password --authenticationDatabase "admin"
```

---

## Step 8: Allow Remote Connections (Optional)

**Skip this step if MongoDB runs on the same server as Faveo.**

By default MongoDB only accepts connections from the same server (`127.0.0.1`). If Faveo runs on a different server, follow the steps below.

**1. Open the MongoDB configuration file:**

```
sudo nano /etc/mongod.conf
```

**2. In the `net:` section, add the MongoDB server's private IP address to `bindIp`:**

```
net:
  port: 27017
  bindIp: 127.0.0.1,<MongoDB server private IP>
```

**3. Restart MongoDB:**

```
sudo systemctl restart mongod
```

**4. Allow port 27017 in the firewall only from the Faveo server.** Replace `<Faveo server IP>` with the IP address of your Faveo server.

**Debian / Ubuntu:**

```
sudo ufw allow from <Faveo server IP> to any port 27017 proto tcp
```

**RedHat / Alma / Rocky:**

```
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="<Faveo server IP>" port port="27017" protocol="tcp" accept'
sudo firewall-cmd --reload
```

> **Security warning:** Never open port 27017 to the whole internet. Allow only the Faveo server's IP address.

---

## Step 9: Install the PHP MongoDB Extension

Faveo is a PHP application, so PHP needs the **MongoDB extension** to talk to MongoDB. Run this step on the **Faveo server** (if MongoDB is on a separate server, it does not need PHP).

The commands below are for **PHP 8.4**, the PHP version used by Faveo.

**1. Check whether the extension is already enabled:**

```
php -m | grep mongodb
```

If you see `mongodb` in the output, move on to [Step 10](#step-10-connect-faveo-to-mongodb). If nothing is shown, install it.

**2. Install the extension.**

**Debian / Ubuntu:**

```
sudo apt update
sudo apt install -y php8.4-mongodb
```

**RedHat / Alma / Rocky** (PHP 8.4 from the Remi repository):

```
sudo dnf install -y php-pecl-mongodb2
```

> **Good to know:** These packages come from the same repository you used to install PHP 8.4 (the Ondřej Surý repository on Debian / Ubuntu, the Remi repository on RedHat / Alma / Rocky). If the package is not found, check that PHP 8.4 was installed from that repository.

**3. Restart the web server and PHP-FPM** so they load the extension.

**Debian / Ubuntu:**

```
sudo systemctl restart apache2
```

> If you use PHP-FPM, also run `sudo systemctl restart php8.4-fpm`. If you use Nginx, restart `nginx` instead of `apache2`.

**RedHat / Alma / Rocky:**

```
sudo systemctl restart php-fpm
sudo systemctl restart httpd
```

> If you use Nginx, restart `nginx` instead of `httpd`.

**4. Restart the queue worker.** Queue workers load PHP extensions only when they start. This command is the same on all OS:

```
sudo supervisorctl restart faveo-Horizon
```

> **Note:** Supervisor program names are case-sensitive. If yours has a different name, run `sudo supervisorctl status` to see the exact name and use that.

**5. Confirm the extension is loaded:**

```
php -m | grep mongodb
php -r 'echo "MongoDB extension version: " . phpversion("mongodb") . PHP_EOL;'
```

You should see `mongodb` and a version number. It must be **2.5 or newer**, because Faveo's MongoDB library requires it.

> **RedHat / Alma / Rocky:** install `php-pecl-mongodb2`, not `php-pecl-mongodb`. The Remi repository offers both, but `php-pecl-mongodb` is the older 1.x extension and does not work with Faveo.

---

## Step 10: Connect Faveo to MongoDB

**1.** Log in to Faveo as an administrator and go to **Admin > System and maintenance > Services > MongoDB** (the **MongoDB Settings** page).

**2.** Fill in the form:

| Field | What to enter |
|-------|---------------|
| **Name** | Optional. A label for this connection, for example `Elea MongoDB`. |
| **Database** | `faveo-elea` |
| **MongoDB URI** | The connection string shown below, with your password from [Step 5](#step-5-create-the-faveo-elea-database-user). |
| **Use Atlas** | Leave **off**. Turn it on only if you use MongoDB Atlas (cloud-hosted) instead of the server installed in this guide. |
| **Status** | **On** (enabled). |

**MongoDB URI** format:

```
mongodb://faveo-elea:<password>@127.0.0.1:27017/faveo-elea?authSource=faveo-elea
```

If MongoDB runs on a separate server, replace `127.0.0.1` with that server's IP address.

> **Important:** Keep `?authSource=faveo-elea` at the end. The `faveo-elea` user was created in the `faveo-elea` database, so without it MongoDB rejects the login.

> **Password with special characters?** If your password contains `@`, `:`, `/`, `?`, `#` or `%`, it must be URL-encoded in the connection string. For example, `@` becomes `%40`.

**3.** Click **Test connection**. You should see **Connected to MongoDB successfully.**

**4.** Click **Save**. Faveo checks the connection again before saving, and refuses to save an enabled configuration that cannot connect.

The first time Elea needs MongoDB, Faveo automatically creates its collections (`elea_crawler_content_vector` and `elea_agent_transfer_vector`) and their indexes. You do not need to create anything by hand. The **Last migrated** value on the MongoDB Settings page shows when this happened.

---

## Step 11: Verify the Setup

Run through these checks:

**1. MongoDB is running:**

```
sudo systemctl status mongod
```

The status should show **active (running)**.

**2. MongoDB is listening on port 27017:**

```
sudo ss -ltnp | grep 27017
```

You should see a line showing `mongod` listening on port `27017`.

**3. The PHP MongoDB extension is loaded (on the Faveo server):**

```
php -m | grep mongodb
```

You should see `mongodb` in the output.

**4. Faveo can connect:**

In Faveo, open the Elea AI Assistant **Data Sources** or **AI Agent** page. The **MongoDB configuration is required** warning and the **Configure MongoDB** button should no longer be shown.

🎉 MongoDB is now ready for the Elea AI Assistant in your Faveo Helpdesk.

---

## Windows Servers

MongoDB 9.0 supports **Windows 11** and **Windows Server 2022** (64-bit). Windows 10 and Windows Server 2019 are not supported.

**1. Install MongoDB** using the official MSI installer. Follow the official guide:

[Install MongoDB Community Edition on Windows](https://www.mongodb.com/docs/v9.0/tutorial/install-mongodb-on-windows/)

During setup, keep **Install MongoD as a Service** selected. Also install the MongoDB Shell (`mongosh`) from the [MongoDB Shell download page](https://www.mongodb.com/try/download/shell) if it is not already installed.

**2. Create the users.** Open **Command Prompt**, run `mongosh`, and follow [Step 4](#step-4-create-an-administrator-user) and [Step 5](#step-5-create-the-faveo-elea-database-user) exactly as written.

**3. Enable authentication.** Open the configuration file as Administrator:

```
C:\Program Files\MongoDB\Server\9.0\bin\mongod.cfg
```

Add the same `security:` block shown in [Step 6](#step-6-enable-authentication), save the file, then restart the service from **Command Prompt (Run as Administrator)**:

```
net stop MongoDB
net start MongoDB
```

**4. Install the PHP MongoDB extension** on the Faveo server:

1. Download the `php_mongodb.dll` package that matches **PHP 8.4**, your architecture (**x64**) and thread safety (**NTS** or **TS**) from the [MongoDB PHP driver releases page](https://github.com/mongodb/mongo-php-driver/releases). Run `php -i | findstr "Thread"` to check thread safety.
2. Copy `php_mongodb.dll` into the `ext` folder of your PHP installation.
3. Add this line to your `php.ini` file:

    ```
    extension=mongodb
    ```

4. Restart IIS (or your web server) and confirm with `php -m | findstr mongodb`.

**5.** Continue with [Step 7](#step-7-test-the-login) and [Step 10](#step-10-connect-faveo-to-mongodb).

---

## Troubleshooting

| Problem | Cause and fix |
|---------|---------------|
| **`NO_PUBKEY` or GPG error during `apt-get update`** | The signing key was not imported. Repeat [Step 1](#step-1-add-the-mongodb-repository) from the beginning. |
| **`Unable to locate package mongodb-org`** | The repository line does not match your OS version. Check with `cat /etc/os-release` and add the correct line from [Step 1](#step-1-add-the-mongodb-repository). |
| **MongoDB does not start after enabling authentication** | There is a mistake in `/etc/mongod.conf`, usually a tab instead of spaces or a duplicate `security:` line. Fix the file as shown in [Step 6](#step-6-enable-authentication) and check the log with `sudo journalctl -u mongod -n 50 --no-pager`. |
| **`Authentication failed`** | The password is wrong or the authentication database is wrong. The `faveo-elea` user must log in with `--authenticationDatabase "faveo-elea"`, and the admin user with `--authenticationDatabase "admin"`. |
| **`faveo-elea` database not shown in `show dbs`** | This is normal until Faveo is connected in [Step 10](#step-10-connect-faveo-to-mongodb) and Elea is used for the first time. Faveo then creates the database and its collections automatically. |
| **Test connection says `MongoDB refused the user name or password`** | The password in the MongoDB URI is wrong, contains special characters that are not URL-encoded, or `?authSource=faveo-elea` is missing from the end of the URI. |
| **Faveo says `Enter a valid MongoDB connection string`** | The MongoDB URI must start with `mongodb://` (or `mongodb+srv://` for Atlas). Use the format shown in [Step 10](#step-10-connect-faveo-to-mongodb). |
| **`Class "MongoDB\Driver\Manager" not found` or `mongodb extension is not loaded`** | The PHP MongoDB extension is missing, or the web server / queue worker was not restarted after installing it. Repeat [Step 9](#step-9-install-the-php-mongodb-extension). |
| **`php -m` shows `mongodb` but Faveo still cannot use it** | The command line and the web server use different PHP versions or `php.ini` files. Make sure the extension is installed for **PHP 8.4**, then restart the web server, PHP-FPM and `faveo-Horizon`. |
| **`Unable to locate package php8.4-mongodb` / `No match for argument: php-pecl-mongodb2`** | PHP 8.4 was not installed from the Ondřej Surý repository (Debian / Ubuntu) or the Remi repository (RedHat / Alma / Rocky). Add the same repository used to install PHP 8.4 and try again. |
| **Faveo still shows the MongoDB warning** | MongoDB is stopped, the PHP extension is not loaded, or the details on the **MongoDB Settings** page are wrong. Check `sudo systemctl status mongod`, run `php -m \| grep mongodb`, and re-check the values from [Step 10](#step-10-connect-faveo-to-mongodb). Faveo remembers the connection result for about 15 seconds, so wait a moment and reload the page. |
| **Faveo on another server cannot connect (connection refused or timeout)** | `bindIp` does not include the server's private IP, or the firewall blocks port 27017. Repeat [Step 8](#step-8-allow-remote-connections-optional). |
| **MongoDB is not running after a server reboot** | The service is not enabled on boot. Run `sudo systemctl enable --now mongod`. |

### Useful commands

```
# Check MongoDB status
sudo systemctl status mongod

# Restart MongoDB
sudo systemctl restart mongod

# View the latest MongoDB log entries
sudo journalctl -u mongod -n 50 --no-pager

# Check MongoDB server and shell versions
mongod --version
mongosh --version

# Check MongoDB is listening on port 27017
sudo ss -ltnp | grep 27017

# Check the PHP MongoDB extension is loaded
php -m | grep mongodb
```

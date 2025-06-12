---
layout: single
type: docs
permalink: /docs/helpers/ssh-key/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-06-12
last_modified_by: Mohammad_Asif
toc: true
title: "SSH Key Authentication Setup Guide"
---


<img src="https://lcdung.top/wp-content/uploads/2016/10/Create-SSH-Key.png" alt="" style=" width:600px ; height:170px ">

---

# Introduction
SSH keys are a secure and convenient method to log in to remote systems without needing to enter a password each time. Instead of using a password, a pair of cryptographic keys *(a public key and a private key)* are used to authenticate the user.

## Why Use SSH Key Authentication?
- **Improved Security:** SSH keys are more secure than passwords.

- **Convenience:** You don’t need to type the password every time.

- **Automation:** Useful for automated scripts and tools that need to connect to remote servers.

## Generate an SSH Key on a Linux Server/Machine

To Create a SSH Key Pair run the following command inside the <code><b>/var/www/</b></code> directory:
```
cd /var/www
ssh-keygen -t rsa -b 4096
```
When prompted, just press Enter to accept the default file name and set a password of your choice.

## Configure Key Permissions and Location for www-data

Run the following commands:

```
sudo mkdir -p /var/www/.ssh
sudo chown www-data:www-data /var/www/.ssh
sudo chmod 700 /var/www/.ssh
```

Copy generated SSH keys to /var/www/.ssh:

```
sudo cp /root/.ssh/id_rsa /var/www/.ssh/id_rsa
sudo cp /root/.ssh/id_rsa.pub /var/www/.ssh/id_rsa.pub
```

Set ownership and permissions:

```
sudo chown www-data:www-data /var/www/.ssh/id_rsa /var/www/.ssh/id_rsa.pub
sudo chmod 600 /var/www/.ssh/id_rsa
sudo chmod 644 /var/www/.ssh/id_rsa.pub
```


### Why are we storing the SSH key under <code><b>/var/www/</b></code>?
When we perform scanning using API requests, the permissions are executed under the <code><b>www-data</b></code> **user** (not <code><b>root</b></code> or a specific user like <code><b>asif</b></code>). If the key pair is stored under <code><b>/home/asif/.ssh</b></code>, it leads to **permission errors** because the www-data user cannot access that location.

To avoid these errors, we generate and store the SSH keys under <code><b>/var/www/</b></code> and set the correct ownership and permissions for the <code><b>www-data</b></code> user.

---
---

## Copy SSH Public Key to Target Devices
To connect to other devices without password prompts, we must store the public key on those devices.


### For Linux/Mac Devices:

- Open the authorized keys file:

```
nano ~/.ssh/authorized_keys
```

- Paste your public key (from <code><b>/var/www/.ssh/id_rsa.pub</b></code>) into the file. 
Ensure no extra spaces or line breaks are added.

- Set correct permissions:

```
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

- Ensure SSH server accepts key-based login:

```
sudo nano /etc/ssh/sshd_config
```

Make sure the following line exists and is not commented out:

```
PubkeyAuthentication yes
```

- Then restart the SSH service:

- For Linux:

```
sudo systemctl restart ssh
```
- For Mac:

```
sudo launchctl stop com.openssh.sshd
sudo launchctl start com.openssh.sshd
```

### For Windows Devices:

- Ensure SSH Server is installed
  - [Follow this guide](/docs/helper/enable-ssh/)

- Create the authorized keys file using below powershell command:

```
New-Item -Path "C:\ProgramData\ssh\administrators_authorized_keys" -ItemType File -Force
notepad "C:\ProgramData\ssh\administrators_authorized_keys"
```

- Paste your public key (from <code><b>/var/www/.ssh/id_rsa.pub</b></code>) into the file and save.

- Set file permissions by the below powershell commands:

```
icacls "C:\ProgramData\ssh\administrators_authorized_keys" /inheritance:r
icacls "C:\ProgramData\ssh\administrators_authorized_keys" /grant "Administrators:F"
icacls "C:\ProgramData\ssh\administrators_authorized_keys" /grant "SYSTEM:F"
```

```
icacls "C:\ProgramData\ssh" /inheritance:r
icacls "C:\ProgramData\ssh" /grant "Administrators:F"
icacls "C:\ProgramData\ssh" /grant "SYSTEM:F"
```

- Ensure key authentication is enabled:

```
notepad C:\ProgramData\ssh\sshd_config
```

Make sure the line below exists and is uncommented:

```
PubkeyAuthentication yes
```

- Restart the SSH service:

```
Restart-Service sshd
```


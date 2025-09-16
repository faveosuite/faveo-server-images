---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/windows-apache-ssl/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-07-11
last_modified_by: Mohammad_Asif
toc: true
title: Install Self-Signed SSL for Faveo on Windows
---
<style>p>code, a>code, li>code, figcaption>code, td>code {background: #dedede;}</style>


<img alt="Windows" src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Windows_logo_and_wordmark_-_2021.svg/250px-Windows_logo_and_wordmark_-_2021.svg.png" width="200"  />


## <strong>Introduction</strong>

This document will list how to install Self-Signed SSL certificates on Windows servers.

- We will be using the tool OpenSSL for creating a Self-Signed SSL certificate on a windows machine.

- The OpenSSL is an open-source library that provides cryptographic functions and implementations. 

- OpenSSL is a defacto library for cryptography-related operations and is used by a lot of different applications. 

- OpenSSL is provided as a library and application. 

- OpenSSL provides functions and features like SSL/TLS, SHA1, Encryption, Decryption, AES, etc.

Before proceeding with the SSL installation Load the following modules for SSL in httpd.conf
```
LoadModule ssl_module modules/mod_ssl.so
Include conf/extra/httpd-ssl.conf
LoadModule socache_shmcb_module modules/mod_socache_shmcb.so
```

## <strong>Setting up OpenSSL for Windows</strong>

With the below commands we can install OpenSSL on the windows server:

Open SSL is not available for windows in .exe format the easiest way to install is by using a third-party software CHOCOLATEY.

Install “Chocolatey” a package management software for windows by using the below command.

Open Powershell.exe with Administrator Privilege, Paste the below command and hit enter

```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```
It may ask for permission please select yes for all and when the installation is over then enter the below command.

Open the command prompt with Administrator privilege and enter the below command to install OpenSSL.

```
choco install openssl 
```
It will prompt and ask for *yes* give *yes* and wait till the installation gets done.

## <strong>Steps</strong>

- Create OpenSSL Configuration File
- Generate Certificate and Private Key
- Export to .pfx format for IIS
- Install the Certificate

### <strong>Create OpenSSL Configuration File </strong>
Create a directory named <code><b>SSL</b></code> say at *C:\SSL\* or on any directory.

Create a file <code><b>openssl.cnf</b></code> inside the <code><b>SSL</b></code> directory created above and save the below content to the file.

```
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_req

[dn]
C = IN
ST = Karnataka
L = Banglore
O = Faveo
OU = IT
CN = faveo-helpdesk.local

[v3_req]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = faveo-helpdesk.local
```
> **Note:** Please provide the below details according to your need:

<code><b>C = IN
ST = Karnataka
L = Banglore
O = Faveo
OU = IT
CN = faveo-helpdesk.local
DNS.1 = faveo-helpdesk.local</b></code>

### <strong>Generate Certificate and Private Key</strong>

Open the command prompt from the SSL Directory and run the below command which will create the certificate and the private key.

```
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout private.key -out faveo.crt -config openssl.cnf -extensions v3_req
```

### <strong>Compiling the created certificate and key file as .pfx file</strong>

As windows need the certificate file in .pfx format which will contain the both certificate and the key file, so we need to convert the created files to .pfx format, this can be done with the below command.

```
openssl pkcs12 -export -inkey private.key -in faveo.crt -out faveo.pfx
```

The above command will create a .pfx file with the name *faveo.pfx* in the SSL directory.

### <strong>Installing the SSL certificate</strong>

- The installation of the SSL certificate is simple in windows machines we need to double click on the *faveo.pfx* file that we created from the above step which will open the certificate installation wizard.

    ![windows](https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/certificateinstallation.png?raw=true)

- Click on install certificates and all the settings to be left default and once the installation is successful it will prompt the installation is successful.

- Once the Certificate is installed we need to add the faveorootCA.crt file content to the cacert.pem file which will be in the below location:

```
C:\php
```

- After adding that we need to edit the host file which will be in this location

```
(C:\Windows\System32\drivers\etc)
```

- And add the below line by replacing the 'yourdomain' with the domain that we used to create the server SSL certificate.

```
127.0.0.1            yourdomain
```

- if the above is done we need to edit the php.ini file which is found inside the PHP root directory. Uncomment and add the location of cacert.pem to "openssl.cafile" like.

```
openssl.cafile = "C:\php\cacert.pem"
```

- Edit the <code><b>C:\Apache24\conf\extra\httpd-ssl.conf</b></code> file, search for *<VirtualHost _default_:443>* 
- Turn SSL Engine on & add the certificate paths respectively as shown below:

```
SSLEngine on
SSLCertificateFile "C:\SSL\faveolocal.crt"
SSLCertificateKeyFile "C:\SSL\private.key"
SSLCACertificateFile "C:\SSL\faveorootCA.crt"
```


The certificate is installed successfully, since this is a self-signed certificate the browser will show not valid since the faveo consider's the server-side SSL certificates in the probe page Domain SSL will be valid.



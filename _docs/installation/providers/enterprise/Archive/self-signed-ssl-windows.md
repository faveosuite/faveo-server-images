---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/self-signed-ssl-windows/
redirect_from:
  - /theme-setup/
last_modified_at: 2021-12-12
last_modified_by: Mohammad_Asif
toc: true
title: Install Self-Signed SSL for Faveo on Windows
---

<img alt="Windows" src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Windows_logo_and_wordmark_-_2021.svg/250px-Windows_logo_and_wordmark_-_2021.svg.png" width="200"  />


## <strong>Introduction</strong>

This document will list how to install Self-Signed SSL certificates on Windows servers.

- We will be using the tool OpenSSL for creating a Self-Signed SSL certificate in a windows machine.

- The OpenSSL is an open-source library that provides cryptographic functions and implementations. 

- OpenSSL is a defacto library for cryptography-related operations and is used by a lot of different applications. 

- OpenSSL is provided as a library and application. 

- OpenSSL provides functions and features like SSL/TLS, SHA1, Encryption, Decryption, AES, etc.

## <strong>Setting up OpenSSL for Windows</strong>

With the below commands we can install OpenSSL in the windows server:

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
It will prompt and ask for 'yes' give 'yes' and wait till the installation gets done.

## <strong>Steps</strong>

- Generate a private key for the CA (Certificate Authority).
- Generate a certificate signing request for the CA.
- Generate a root certificate.
- Create a private key for the certificate.
- Create a certificate signing request.
- Create a certificate and sign it with the CA private key.
- Compiling the created certificate and key file as a .pfx file.
- Installing the SSL certificate.

### <strong>Generate a private key for the CA</strong>

Create a directory named SSL under the desktop or on any directory, the following commands will create the SSL files those files will be saved in the directory which we create.

- Open Command Prompt from the SSL directory that we created,
- Run the below command to create a Private key for the rootCA this command will save a file name faveoroot.key in the SSL folder.

```
openssl ecparam -out faveoroot.key -name prime256v1 -genkey
```

### <strong>Generate a certificate signing request for the CA</strong>

- From the command prompt run the below command which will create a CSR (certificate signing request) for the Root CA.

```
openssl req -new -sha256 -key faveoroot.key -out faveoroot.csr
```
- The above command will ask for the below information if needed you can provide them or you can just hit enter and skip them but it is recommended to give the meaningful details.

    - Country Name.
    - State Name.
    - Organization.
    - Common name (Leave this as blank or provide the company domain not the faveo domain).
    - Email address.

- The above command will save a file in the name faveoroot.csr in the SSL directory.

### <strong>Generate a root certificate</strong>

- The below command will create the Root CA certificate which we will use to sign the SSL certificates.


```
openssl x509 -req -sha256 -days 3650 -in faveoroot.csr -signkey faveoroot.key -out faveorootCA.crt
```

- The above command will create a file and save it as faveorootCA.crt in the SSL directory.

### <strong>Create a private key for the certificate</strong>

- The below command will create a private key file for the server SSL certificate.

```
openssl ecparam -out private.key -name prime256v1 -genkey
```

- The above command will save a key file with the name private.key for the server SSL certificate.

### <strong>Create a certificate signing request for the server SSL</strong>

- The below command will create a Certificate Signing Request for the Server SSL.

```
openssl req -new -sha256 -key private.key -out faveolocal.csr
```

- It will ask for the details as below we should give the details as shown below.

    - Country Name.
    - State Name.
    - Organization.
    - Common name (Here please provide the Domain or the IP through which you need to access faveo).
    - Email address.
- The rest can be left blank and after this is completed it will create the CSR file and save it with the name faveolocal.csr in the SSL directory.

### <strong>Create a certificate and sign it with the CA private key</strong>

- The below command will create the server SSL certificate which is signed by the Root CA that we created above.

```
openssl x509 -req -in faveolocal.csr -CA  faveorootCA.crt -CAkey faveoroot.key -CAcreateserial -out faveolocal.crt -days 3650 -sha256 
```
- The above command will create a server SSL file and save it in the name faveolocal.crt, this certificate will be valid for 3650 days that is ten years.

### <strong>Compiling the created certificate and key file as .pfx file</strong>

- As windows need the certificate file in .pfx format which will contain the both certificate and the key file and the CA file for the installation, so we need to convert the created files to .pfx format, this can be done with the below command.

```
openssl pkcs12 -export -out cert.pfx -inkey private.key -in faveolocal.crt -certfile faveorootCA.crt
```

- The above command will create a .pfx file with the name cert.pfx in the SSL directory.

### <strong>Installing the SSL certificate</strong>

- The installation of the SSL certificate is simple in windows machines we need to double click on the cert.pfx file that we created from the above step which will open the certificate installation wizard.

    ![windows](https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/certificateinstallation.png?raw=true)

- Click on install certificates and all the settings to be left default and once the installation is successful it will prompt the installation is successful.

- Once the Certificate is installed we need to add the faveorootCA.crt file content to the cacert.pem file which will be in the below location:

```
C:\php8.2
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
openssl.cafile = "C:\php8.2\cacert.pem"
```

- After updating the above, the last part is to add bindings for the SSL.
- As shown below open the IIS manager and click on the site and on the right pane select Bindings.

  ![windows](https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/bindings.jpeg?raw=true)

- As shown below there will be a prompt, there select Add option.

  ![windows](https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/portadd.jpeg?raw=true)

- As shown below change the HTTP to HTTPS and add the domain name in the Hostname section and select the SSL certificate which we installed and click OK.

  ![windows](https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/bindingwithdomain.png?raw=true)

The certificate is installed successfully, since this is a self-signed certificate the browser will show not valid since the faveo considers the server-side SSL certificates in the probe page Domain SSL will be valid.

**Note:** If the SSL certificate is not shown in the Bindings tab then follow the below steps:

- Open IIS manager and go to *Server Certificates*, double click on it a new tab will appear.

 <img src="https://raw.githubusercontent.com/ladybirdweb/faveo-server-images/master/_docs/installation/providers/enterprise/windows-images/servercertificates.png" alt="" style=" width:580px ; height:330px ">

- Click on *Import*, a small tab will open, click on three dots and navigate to the *cert.pfx* file, select the *cert.pfx file* and enter the password if the certicate is password protected, then click on *OK*, the SSL certificate will be exported.

 <img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/windows-images/certificateadd.png?raw=true" alt="" style=" width:580px ; height:330px ">

- Now add Bindings for the certificate as shown as shown above.

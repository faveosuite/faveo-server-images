---
layout: single
type: docs
permalink: /docs/helpers/server-hardening/apache-hardening
redirect_from:
  - /theme-setup/
last_modified_at: 2024-09-17
last_modified_by: Mohammad_Asif
toc: true
title: "Apache Hardening for Security Implications"
---

<img alt="Apache" src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7ZgLOdo0TtCe4GOWoPmYEhyXY-ax2iILAzizZbFomQl-K7PNJh-i_Q8syiwIlR0Bfw1A&usqp=CAU" width="180"/>

The web server has a crucial role in web-based applications. Since most of us leave it to the default configuration, it can leak sensitive data regarding the web server.

By applying numerous configuration tweaks we can make Apache withstand malicious attacks up to a limit. Following are some Apache web server hardening tips that you can incorporate to improve security.

 - [<strong>1. Hide Web Server Details</strong>](#1Hide-Web-Server-Details)
 - [<strong>2. Disable HTTP Trace Method</strong>](#2Disable-HTTP-Trace-Method)
 - [<strong>3. Disable Directory Listing</strong>](#3Disable-Directory-Listing)
 - [<strong>4. Click Jacking defense with X-Frame Options</strong>](#4Click-Jacking-defense-with-X-Frame-Options)
 - [<strong>5. Basic XSS Protection</strong>](#5Basic-XSS-Protection)
 - [<strong>6. Enable HttpOnly and Secure Flag</strong>](#6Enable-HttpOnly-and-Secure-Flag)
 - [<strong>7. Disable ETag</strong>](#7Disable-ETag)
 - [<strong>8. Enable HTTP/2 Protocol</strong>](#8Enable-HTTP/2-Protocol)
 - [<strong>9. Set Referrer Policy</strong>](#9Set-Referrer-Policy)
 - [<strong>10. Set Permissions Policy</strong>](#10Set-Permissions-Policy)
 - [<strong>11. Enforce HSTS (HTTP Strict Transport Security)</strong>](#11Enforce-HSTS-(HTTP-Strict-Transport-Security))
---


 <a id="1Hide-Web-Server-Details" name="1Hide-Web-Server-Details"></a>

### <strong>1. Hide Web Server Details</strong>

One of the first things to be taken care of is hiding the server version banner.

The default apache configuration will expose the server version. This information might help an attacker gain a greater understanding of the systems in use and potentially develop further attacks targeted at the specific version of the server.

Follow the below steps to hide the server version.


Edit your Apache server configuration file using Nano.

- For RHEL Based Systems:
```
nano /etc/httpd/conf/httpd.conf
```

- For Debian Based Systems:
```
nano /etc/apache2/conf-enabled/security.conf
```


Scroll down to the “ServerTokens” section where you’ll probably see multiple lines commented out (beginning with “#”) stating “ServerTokens” and different options. Change the uncommented line, likely “ServerTokens OS”, or comment out the line and create a new line to hide the Apache version and OS from HTTP headers:
```
ServerTokens Prod
```

The next section down should be the “ServerSignature” section. Turning this off hides the information from server-generated pages (e.g. Internal Server Error).
```
ServerSignature Off
```

Exit the file and save changes.
```
Ctrl + x
```

Restart Apache.

- For RHEL Based Systems:
```
systemctl restart httpd
```

- For Debian Based Systems:
```
systemctl restart apache2
```

The ServerTokens Prod and ServerSignature Off directives hide the server version and detailed information from server-generated pages and HTTP headers.

ServerTokens Prod: This hides the version of Apache and other information to make it harder for attackers to exploit known vulnerabilities.

ServerSignature Off: This hides the Apache version and other details on server-generated pages, reducing the information available to potential attackers.

---

 <a id="2Disable-HTTP-Trace-Method" name="2Disable-HTTP-Trace-Method"></a>

### <strong>2. Disable HTTP Trace Method</strong>

Apache versions newer than 1.3.34 and 2.0.55 (or newer) can use the variable TraceEnable to enable or disable. By default, it is enabled. TraceEnable Off causes Apache to return a 403 FORBIDDEN error to the client.

To disable HTTP TRACE/TRACK methods in Apache follow the below steps:

Edit your Apache server configuration file using Nano.

- For RHEL Based Systems:
```
nano /etc/httpd/conf/httpd.conf
```
- For Debian Based Systems:
```
nano /etc/apache2/conf-enabled/security.conf
```

Search for TraceEnable On, change this option to off
```
TraceEnable off
```

Exit the file and save changes.
```
Ctrl + x
```

Restart Apache.

- For RHEL Based Systems:
```
systemctl restart httpd
```
- For Debian Based Systems:
```
systemctl restart apache2
```

TraceEnable Off: The TraceEnable Off directive disables the HTTP TRACE method, which can be used in cross-site tracing attacks.

---

 <a id="3Disable-Directory-Listing" name="3Disable-Directory-Listing"></a>

### <strong>3. Disable Directory Listing</strong>

Directory listing is a web server function that displays the directory contents when there is no index file in a specific website directory. It is dangerous to leave this function turned on for the web server because it leads to information disclosure.

You can add -Indexes to Options directive in Apache's configuration file to fully disable directory listing, or add the same -Indexes option into Directory configuration to disable the feature per-directory.

Edit your Apache server configuration file using Nano.

- For RHEL Based Systems:
```
nano /etc/httpd/conf/httpd.conf
```
- For Debian Based Systems:
```
nano /etc/apache2/apache2.conf
```

Find the below section:
```

<Directory /var/www/>
        Options Indexes FollowSymLinks
</Directory>

```

Change Options Indexes FollowSymLinks to below:
```
Option -Indexes +FollowSymlinks
```

Exit the file and save changes.
```
Ctrl + x
```

Restart Apache.

For RHEL Based Systems:
```
systemctl restart httpd
```
For Debian Based Systems:
```
systemctl restart apache2
```

Options -Indexes +FollowSymLinks: The Options -Indexes +FollowSymLinks directive in the <Directory> section disables directory listingand allows symbolic links, which prevents information disclosure when no index file is present.

---

 <a id="4Click-Jacking-defense-with-X-Frame-Options" name="4Click-Jacking-defense-with-X-Frame-Options"></a>

### <strong>4. Click Jacking defense with X-Frame Options</strong>

Clickjacking is an attack that tricks a user into clicking a webpage element which is invisible or disguised as another element. This can cause users to unwillingly download malware, visit malicious web pages, provide credentials or sensitive information etc online.

X-Frame-Options allows content publishers to prevent their own content from being used in an invisible frame by attackers.

Edit your Apache server configuration file using Nano.

- For RHEL Based Systems:
```
nano /etc/httpd/conf/httpd.conf
```
- For Debian Based Systems:
```
nano /etc/apache2/conf-enabled/security.conf
```

Now add the following entry to file:
```
Header always append X-Frame-Options SAMEORIGIN
```
Exit the file and save changes.
```
Ctrl + x
```

Restart Apache.
- For RHEL Based Systems:
```
systemctl restart httpd
```
- For Debian Based Systems:
```
systemctl restart apache2
```

Header set X-Frame-Options "SAMEORIGIN": The Header set X-Frame-Options "SAMEORIGIN" directive prevents your content from being framed and potentially clickjacked. This prevents clickjacking attacks by only allowing your site to be framed by pages from the same origin.

---

 <a id="5Basic-XSS-Protection" name="5Basic-XSS-Protection"></a>

### <strong>5. Basic XSS Protection</strong>

The X-XSS-Protection header is designed to enable the cross-site scripting (XSS) filter built into modern web browsers. This is usually enabled by default, but using it will enforce it. It is supported by Internet Explorer 8+, Chrome, Edge, Opera, and Safari. 

Edit your Apache server configuration file using Nano.
- For RHEL Based Systems:
```
nano /etc/httpd/conf/httpd.conf
```
- For Debian Based Systems:
```
nano /etc/apache2/conf-enabled/security.conf
```

The recommended configuration is to set this header to the following value, which will enable the XSS protection and instruct the browser to block the response in the event that a malicious script has been inserted from user input instead of sanitizing.
```
Header set XSS-Protection "1;mode=block"
```

Exit the file and save changes.
```
Ctrl + x
```

Restart Apache.

- For RHEL Based Systems:
```
systemctl restart httpd
```
- For Debian Based Systems:
```
systemctl restart apache2
```

Header set XSS-Protection "1; mode=block": The Header set XSS-Protection "1; mode=block" directive enables the browser's XSS protection and instructs it to block rather than sanitize the page. This enables cross-site scripting (XSS) protection in browsers and instructs them to block the page if an XSS attack is detected.

---

  <a id="6Enable-HttpOnly-and-Secure-Flag" name="6Enable-HttpOnly-and-Secure-Flag"></a>

### <strong>6. Enable HttpOnly and Secure Flag</strong>

Cross-site scripting (XSS) attacks are often aimed at stealing session cookies.  Therefore, a method of protecting cookies from such theft was devised: a flag that tells the web browser that the cookie can only be accessed through HTTP – the HttpOnly flag.

The Secure flag is used to declare that the cookie may only be transmitted using a secure connection (SSL/HTTPS). If this cookie is set, the browser will never send the cookie if the connection is HTTP. This flag prevents cookie theft via man-in-the-middle attacks.

Note that this flag can only be set during an HTTPS connection. If it is set during an HTTP connection, the browser ignores it.

Follow the below steps:

Enable the required Apache modules.
```
a2enmod rewrite
```
```
a2enmod headers
```

Edit the Apache configuration file for the website.
```
nano /etc/apache2/apache2.conf
```

If your website supports only HTTP, Add the following lines at the end of the file.
```
Header edit Set-Cookie ^(.*)$ $1;HttpOnly
```

If your website supports only HTTPS, Add the following lines at the end of the file.
```
Header edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure
```

Exit the file and save changes.
```
Ctrl + x
```

6. Restart Apache.

- For RHEL Based Systems:
```
systemctl restart httpd
```
- For Debian Based Systems:
```
systemctl restart apache2
```

Header edit Set-Cookie ^(.*)$ "$1;HttpOnly;Secure": The Header edit Set-Cookie ^(.*)$ "$1; HttpOnly; Secure" directive ensures that cookies are marked as HttpOnly and Secure, protecting them from client-side scripts and ensuring they are only sent over HTTPS.

<p class="notice--warning">
Note: This has been handled on code level so we will not add it to the final conf file.
</p>

---

  <a id="7Disable-ETag" name="7Disable-ETag"></a>

### <strong>7. Disable ETag</strong>

The FileETag None directive disables the generation of ETag headers, which can expose information about the inode, size, and modification date of files on your server. Disabling ETag improves privacy and security.

Edit your Apache server configuration file using Nano.

- For RHEL Based Systems:
```
nano /etc/httpd/conf/httpd.conf
```
- For Debian Based Systems:
```
nano /etc/apache2/conf-enabled/security.conf
```

Add the following line:
```
FileETag None
```

Save and exit the file:
```
Ctrl + x
```

Restart Apache.

- For RHEL Based Systems:
```
systemctl restart httpd
```
- For Debian Based Systems:
```
systemctl restart apache2
```

FileETag None: The FileETag None directive disables ETag headers, which can help prevent revealing server-side information and reduce cache-related issues.

---

  <a id="8Enable-HTTP/2-Protocol" name="8Enable-HTTP/2-Protocol"></a>

### <strong>8. Enable HTTP/2 Protocol</strong>

The Protocols h2 http/1.1 directive enables the HTTP/2 protocol, which provides significant performance improvements over HTTP/1.1.

Edit your Apache server configuration file using Nano.

- For RHEL Based Systems:
```
nano /etc/httpd/conf/httpd.conf
```
- For Debian Based Systems:
```
nano /etc/apache2/conf-enabled/security.conf
```

Add the following line:
```
Protocols h2 http/1.1
```

Save and exit the file:
```
Ctrl + x
```

Restart Apache.

- For RHEL Based Systems:
```
systemctl restart httpd
```
- For Debian Based Systems:
```
systemctl restart apache2
```

Protocols h2 http/1.1: The Protocols h2 http/1.1 directive enables HTTP/2 for improved performance and compatibility.

---

  <a id="9Set-Referrer-Policy" name="9Set-Referrer-Policy"></a>

### <strong>9. Set Referrer Policy</strong>

The Referrer-Policy header controls how much referrer information should be included with requests. The strict-origin policy ensures that only the origin is sent as the referrer when navigating from HTTPS to HTTP.

Edit your Apache server configuration file using Nano.

- For RHEL Based Systems:
```
nano /etc/httpd/conf/httpd.conf
```
- For Debian Based Systems:
```
nano /etc/apache2/conf-enabled/security.conf
```

Add the following line:
```
Header always set Referrer-Policy "strict-origin"
```

Save and exit the file:
```
Ctrl + x
```

Restart Apache.

- For RHEL Based Systems:
```
systemctl restart httpd
```
- For Debian Based Systems:
```
systemctl restart apache2
```

Header always set Referrer-Policy "strict-origin": The Header always set Referrer-Policy "strict-origin" directive controls the amount of referrer information sent with requests enhancing privacy and security.

---

  <a id="10Set-Permissions-Policy" name="10Set-Permissions-Policy"></a>

### <strong>10. Set Permissions Policy</strong>

The Permissions-Policy header allows you to control which browser features can be used within your site. This enhances security by restricting access to potentially harmful features.

Edit your Apache server configuration file using Nano.

- For RHEL Based Systems:
```
nano /etc/httpd/conf/httpd.conf
```
- For Debian Based Systems:
```
nano /etc/apache2/conf-enabled/security.conf
```

Add the following line:
```
Header always set Permissions-Policy "geolocation=(), midi=(), sync-xhr=(), microphone=(), camera=(), magnetometer=(), gyroscope=(), fullscreen=(self), payment=()"
```

Save and exit the file:
```
Ctrl + x
```

Restart Apache.

- For RHEL Based Systems:
```
systemctl restart httpd
```
- For Debian Based Systems:
```
systemctl restart apache2
```

The Header always set Permissions-Policy "geolocation=(), midi=(), sync-xhr=(), microphone=(), camera=(), magnetometer=(), gyroscope=(), fullscreen=(self), payment=()" directive restricts browser features that can be used within your site. This restricts various browser features like geolocation and camera access to improve security.

---

  <a id="11Enforce-HSTS-(HTTP-Strict-Transport-Security)" name="11Enforce-HSTS-(HTTP-Strict-Transport-Security)"></a>

### <strong>11. Enforce HSTS (HTTP Strict Transport Security)</strong>

HSTS tells browsers to only communicate with your site over HTTPS, preventing protocol downgrade attacks.


Edit your Apache server configuration file using Nano.

- For RHEL Based Systems:
```
nano /etc/httpd/conf/httpd.conf
```
- For Debian Based Systems:
```
nano /etc/apache2/conf-enabled/security.conf
```

Add the following line:


`<If "%{HTTPS} == 'on'">
  Header always set Strict-Transport-Security "max-age=31536000; includeSubdomains"
</If>`

Save and exit the file:
```
Ctrl + x
```

Restart Apache.

- For RHEL Based Systems:
```
systemctl restart httpd
```
- For Debian Based Systems:
```
systemctl restart apache2
```

The Header always set Strict-Transport-Security "max-age=31536000; includeSubdomains" directive ensures that browsers only communicate with your site over HTTPS.

---

## Apache Virtual Host Configuration for Security Hardening

Here is the combined configuration for RHEL-based and Debian-based systems, summarized from all 11 points, to be placed in the virtual host configuration files. Here we are directly making changing in a single virtual host file for a particular website.

### Enabling and Applying Configuration:

- For RHEL-based Systems:
  
Edit or create the site-specific configuration file:
```
nano /etc/httpd/conf.d/faveo-ssl.conf
```

- For Debian-based Systems:
  
Edit or create the site-specific configuration file:
```
nano /etc/apache2/sites-available/faveo-ssl.conf
```

### Add the Configuration (Virtual Host File)

```

<IfModule mod_ssl.c>
  FileETag None
  ServerTokens Prod
  ServerSignature Off
  TraceEnable Off
  Protocols h2 http/1.1

  #Security Headers
  Header set X-Frame-Options "SAMEORIGIN"
  Header set XSS-Protection "1; mode=block"
  Header always set Referrer-Policy "strict-origin"
  Header always set Permissions-Policy "geolocation=(), midi=(), sync-xhr=(), microphone=(), camera=(), magnetometer=(), gyroscope=(), fullscreen=(self), payment=()"
#  Header edit Set-Cookie ^(.*)$ "$1;HttpOnly;Secure"
  <If "%{HTTPS} == 'on'">
    Header always set Strict-Transport-Security "max-age=31536000; includeSubdomains"
  </If>

  <VirtualHost *:443>
    ServerName example.com
    DocumentRoot /var/www/html

    <Directory /var/www/html>
      Options -Indexes +FollowSymLinks
      AllowOverride All
      Require all denied

      <RequireAll>
        Require ip 192.168.1.0/24
        Require ip 10.20.30.40.0/24 60.70.80.90 100.200.300.400                # Multiple IPs can be added
      </RequireAll>
    </Directory>
    
    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined

    <Location "/server-status">
      SetHandler server-status
      Require local
    </Location>

    Include /etc/apache2/options-ssl-apache.conf
    SSLCertificateFile /etc/apache2/sites-available/ssl/your-certificate.crt
    SSLCertificateKeyFile /etc/apache2/sites-available/ssl/your-private.key
    SSLCertificateChainFile /etc/apache2/sites-available/ssl/your-ca-cert.crt
  </VirtualHost>
</IfModule>

```


### Restart Apache.

- For RHEL Based Systems:
```
systemctl restart httpd
```

- For Debian Based Systems:
```
systemctl restart apache2
```

AllowOverride All: This allows the use of .htaccess files for directory-specific configuration.

Require all denied / <RequireAll>...Require ip...</RequireAll>: This restricts access to your site to specific IP addresses, enhancing security by limiting who can connect.
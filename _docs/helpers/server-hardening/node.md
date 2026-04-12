---
layout: single
type: docs
permalink: /docs/helpers/node
redirect_from:
  - /theme-setup/
last_modified_at: 20246-04-12
last_modified_by: Mohammad_Asif
toc: true
title: "Installing Node.js and Puppeteer for Faveo's Graphical Reports"
---
<img alt="node" src="https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Node.js_logo.svg/3840px-Node.js_logo.svg.png" width="100"  />

This guide provides instructions to install the required Node.js packages and Puppeteer to enable the graphical reports feature in Faveo Helpdesk on Debian-based servers, RHEL-based servers, and Windows servers.

- [<strong>1. Debian-Based Servers</strong>](#1-debian-based-servers)
- [<strong>2. RHEL-Based Servers</strong>](#2-rhel)
- [<strong>3. Windows Servers</strong>](#3-windows-servers)



<a id="1-debian-based-servers" name="1-debian-based-servers"></a>

### <strong>1. Debian-Based Servers</strong>


Add NodeSource Repository
```
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
```

Update Package List
```
sudo apt update
```

Install Node.js
```
sudo apt install nodejs -y
```

Install Puppeteer
```
sudo npm install --location=global --unsafe-perm puppeteer@^17
```

Install Required Dependencies
```
sudo apt-get install -y gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget libgbm-dev libxshmfence-dev
```

Adjust Permissions
```
sudo chmod -R o+rx /usr/lib/node_modules/puppeteer/.local-chromium
```

<a id="2-rhel-based-servers" name="2-rhel-based-servers"></a>

### <strong>2. RHEL-Based Servers</strong>

Add NodeSource Repository
```
curl -fsSL https://rpm.nodesource.com/setup_20.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
```

Install Node.js
```
sudo yum install -y nodejs
```

Install Puppeteer
```
sudo npm install --location=global --unsafe-perm puppeteer@^17
```

Install Required Dependencies
```
sudo dnf install -y gconf-service alsa-lib atk cairo cups-libs dbus expat fontconfig gbm gcc gconf2 gdk-pixbuf2 glib2 gtk3 nspr pango pangocairo libstdc++ xorg-x11-server-Xorg xorg-x11-xcb xcb-util xorg-x11-utils xorg-x11-server-utils libXScrnSaver ca-certificates liberation-fonts libappindicator libnss3 lsb-release xdg-utils wget
```

Adjust Permissions
```
sudo chmod -R o+rx /usr/lib/node_modules/puppeteer/.local-chromium
```

<a id="3-windows-servers" name="3-windows-servers"></a>

### <strong>3. Windows Servers</strong>

Install Node.js
- Download the Node.js installer from the <a href="https://nodejs.org/en" target="_blank" rel="noopener">official Node.js website</a>.

- Run the installer and follow the on-screen instructions.

Install Puppeteer
- Open Command Prompt as Administrator and run the following command:
```
npm install --location=global --unsafe-perm puppeteer@^17
```

Adjust Permissions 
- Puppeteer should automatically download Chromium; if needed, adjust permissions on the installed Chromium directory.

## Conclusion:
This guide ensures that Faveo Helpdesk has the necessary packages installed for generating graphical reports across different operating systems. Make sure to follow the instructions corresponding to your server's OS for a smooth installation.
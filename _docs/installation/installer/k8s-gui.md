---
layout: single
type: docs
permalink: /docs/installation/installer/k8s-gui/
redirect_from:
  - /theme-setup/
last_modified_at: 2020-06-09
toc: true
title: "Faveo Web GUI Installer"
---

Faveo comes with a web-based installer to help and guide you through the installation process. While the installer provides step by step guide during the installation, it's important and helpful to have general knowledge about Web servers, PHP and MySQL.

Before getting started make sure your server meets following [minimum requirement](/docs/system-requirement/requirement/) required to install and use Faveo

<a id="getting-started" name="getting-started"></a>
## Getting Started

Download the latest version of Faveo from [https://store.faveohelpdesk.com](https://store.faveohelpdesk.com) and upload the .zip files in the folder/directory on your server.

Faveo Community version can also be downloaded directly from [Github](https://github.com/ladybirdweb/faveo-helpdesk)

Basic knowledge of using FTP is an added advantage at this stage. If you don't know how to use FTP, we would recommend you read the documentation supplied with your FTP client and learn the basics of uploading and setting permissions on files. 

You can get the installer by simply browsing the Faveo URL (Faveo Hosted URL). Faveo installation script will attempt to auto-detect paths and any permission issues. By following the given instructions, you can complete the installation and basic setup in a web browser. If the installation spots any configuration errors then it will not allow you to continue until the errors are corrected.

<a id="step1" name="step1"></a>
### Step 1: Server Requirements

The installer will perform the system requirement test and if it spots any errors then it will not allow you to continue until all the requirements are met. When all your server checklists are configured correctly it displays as “Enabled” and you click on the Continue button to move on with the installation process.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/GUI-images/probe-page.png?raw=true" alt="" />
    
<a id="step2" name="step2"></a>
### Step 2: License Agreement

Accept the License Agreement and click on Continue to proceed with the installation.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/GUI-images/license.png?raw=true" alt="" />

<a id="step3" name="step3"></a>    
### Step 3: Database Setup

Establish the database connection by providing the database details.

Fill the Database Name, Database username, and password in the specified boxes like below.
<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/GUI-images/Db-normal.png?raw=true" alt="" />

If you need to use SSL for a secured connection to the DB, click on the click here option and you can add the SSL details on the respective feilds like below.
<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/GUI-images/db-ssl.png?raw=true" alt="" />

Click on the Continue button. If the given database details are valid it will show the “Database connection successful” message as below. If any error message is received refill the details and retry the connection of the database.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/GUI-images/Db-complition.png?raw=true" alt="" />


<a id="step4" name="step4"></a>
### Step 4: Locale Information

Provide the system locale information as system login details and system language, system time.
<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/GUI-images/user-create.png?raw=true" alt="" />

And we have an option to change queue, storage drive and enviornment to redis as shown in below snaps.

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/GUI-images/RDS-cache.png?raw=true" alt="" />

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/GUI-images/environment-options.png?raw=true" alt="" />

<a id="step5" name="step5"></a>
### Step 5: License Key

Product License Key: Provide the license key received for the purchased product and click on the Continue button. Refer the link [How to get the product license key?](/docs/helpers/license-key)

<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/GUI-images/license-code.jpg?raw=true" alt="" />
    
Congratulations! Faveo is installed and operational!

<a id="step6" name="step6"></a>
### Step 6: Start using Faveo

Go to the browser and hit the Faveo URL to login and start using faveo
<img src="https://github.com/ladybirdweb/faveo-server-images/blob/master/_docs/installation/providers/enterprise/GUI-images/faveo-login.png?raw=true" alt="" />

**Note:** Installer performs basic configuration, required to get Faveo up and running. Further configuration is required post-install, to make the system fully functional like
- Email configuration

Faveo can be also installed via a [CLI](/docs/installation/installer/cli) installer. 

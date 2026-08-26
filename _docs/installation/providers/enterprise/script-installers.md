---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/script-installers/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-08-25
toc: true
---

# Faveo Helpesk Installation via Scripts <!-- omit in toc -->

## Installing Faveo Helpdesk via Bash Script for:
- Ubuntu 22.04, 24.04
- Debian 11, 12, 13
- RHEL 8, 9, 10
- Rocky 8, 9, 10
- Alma 8, 9, 10

Prerequisites:
- "curl" and "tar" tools installed.
- sudo or root user privileges.

* [View folder on GitHub](https://github.com/faveosuite/faveo-server-images/tree/master/scripts/installation-scripts/faveo_helpdesk) or run the command below to download the scripts directly:
 
```sh
curl -sL "https://github.com/faveosuite/faveo-server-images/archive/refs/heads/master.tar.gz" \
  | tar -xz --strip-components=3 "faveo-server-images-master/scripts/installation-scripts/faveo_helpdesk"
```

Once the Folder is downlaoded to the faveo server provide executable permission to the script.
```
cd faveo_heldpesk
chmod +x *
```
Excecute the script.
```
sudo ./faveo.sh
```
When prompted please enter the required details and please select the required options Interactively.
```
root@faveo:/home/faveo/faveo_helpdesk# sudo ./faveo.sh 

                                                              ███████╗ █████╗ ██╗   ██╗███████╗ ██████╗
                                                              ██╔════╝██╔══██╗██║   ██║██╔════╝██╔═══██╗
                                                              █████╗  ███████║██║   ██║█████╗  ██║   ██║
                                                              ██╔══╝  ██╔══██║╚██╗ ██╔╝██╔══╝  ██║   ██║
                                                              ██║     ██║  ██║ ╚████╔╝ ███████╗╚██████╔╝
                                                              ╚═╝     ╚═╝  ╚═╝  ╚═══╝  ╚══════╝ ╚═════╝
                                                              
                                                              ██╗  ██╗███████╗██╗     ██████╗ ██████╗ ███████╗███████╗██╗  ██╗
                                                              ██║  ██║██╔════╝██║     ██╔══██╗██╔══██╗██╔════╝██╔════╝██║ ██╔╝
                                                              ███████║█████╗  ██║     ██████╔╝██║  ██║█████╗  ███████╗█████╔╝
                                                              ██╔══██║██╔══╝  ██║     ██╔═══╝ ██║  ██║██╔══╝  ╚════██║██╔═██╗
                                                              ██║  ██║███████╗███████╗██║     ██████╔╝███████╗███████║██║  ██╗
                                                              ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝


 Checking OS compatibility for Faveo Helpdesk... 
[Detected OS] :  Ubuntu 24.04.3 LTS 
Faveo Helpdesk Compatibility Check:  [OK] 
 Enter the following details required by the Faveo Helpdesk Installation. 
 Domain Name [For Faveo Installation without https://]: test.test.com
 Email [Valid email address for Server Side Installation]: test@yahoo.com
 License Code (16 chars) This can be obtained from [https://billing.faveohelpdesk.com]: 5856545251525356    
 Order Number (8 chars) This can be obtained from [https://billing.faveohelpdesk.com]: 87654321

 Select the release type for installation:
 1) Official (stable - recommended)
 2) RC (Release Candidate)
 3) Beta (testing)
 Enter 1/2/3 [default: 1]: 
 You selected: official 

 Select the Faveo application environment:
 1) Production (default)
 2) Development
 3) Testing
 Enter 1/2/3 [default: 1]: 
 You selected: production 

 Faveo has a search module for high data size (example: above 100 tickets per day), Please select 'Yes' if the expected data size is high enough. [Default : Y].
 Enter (y/Yes) for Yes or (n/No) for No [default: y]: 
 You selected: yes 

 If you wish to use Agent Software with Faveo, select Yes or No. Default is No.
 Enter (y/yes) to install or (n/no) to skip Network Discovery dependencies [default: n]: 
 You selected: no 

 Faveo currently supports PHP 8.4.
 You may choose your preferred PHP version (e.g., 8.2, 8.4, x.x). Default is 8.4.
 Enter PHP version [default: 8.4]: 
 You have selected PHP version 8.4 

 Faveo supports Graphical Reports for Assets. This feature uses higher server resources.
 Currently, Faveo supports Node.js 22.x.
 If the server specs are >= 4 vCPU and 8 GB RAM, you may install it. Default is (Yes).
 Enter (y/yes) to install or (n/no) to skip [default : y]: 
 You selected: yes 
                                       
 Select your preferred SQL server [MySQL or MariaDB].
 Supported versions: MySQL 8.0/8.4 and MariaDB 10.6/11.8 only.
 If your chosen engine has no supported version for this OS/release,
 the script will automatically try the other engine instead.
 (1) - MySQL (default) 
 (2) - MariaDB 
                                 
 Enter 1 for MySQL or 2 for MariaDB [default: 1]: 
 You selected: mysql 
                                       
 Where should the SQL server be? 
 (1) - Install mysql locally on this server (default) 
 (2) - Use an existing remote SQL server 
 Enter 1 for local or 2 for remote [default: 1]: 
                                       
 Select your preferred web server [Apache or Nginx].
 (1) - Apache (default)
 (2) - Nginx 
                                 
 Enter 1 for Apache or 2 for Nginx: 1
 You selected: apache Webserver 
                                       
 Select your preferred SSL certificates for Faveo Helpdesk.
 (1) - FreeSSL from Letsencrypt 
 (2) - Self-Signed SSL 
 (3) - Paid SSL 
 Please select an option [1,2,3]: 1
 You have selected Lets Encrypt Free SSL 

╔══════════════════════════════════════════════════════╗
       Faveo Installation Summary                      
╚══════════════════════════════════════════════════════╝
  Domain:               test.test.com
  Email:                test@yahoo.com
  License Code:         5856545251525356
  Order Number:         87654321
  ──────────────────────────────────────────────────────
  Release:              official
  Environment:          production
  Meilisearch:          yes
  NATS:                 no
  PHP Version:          8.4
  Node.js:              yes
  SQL Server:           mysql
  SQL Location:         Local (installed on this server)
  Web Server:           apache
  SSL Type:             certbot
╚══════════════════════════════════════════════════════╝
Continue ( y / n )? 

```

At the end script will prompt the summary of the installation and if there is any error encountered while installation the script will automatically does roll back and clears the server.

<b>Note:</b> If the script fails please reach us at https://support.faveohelpdesk.com and create a ticket and we will help you fix and install Faveo Helpdesk.
```






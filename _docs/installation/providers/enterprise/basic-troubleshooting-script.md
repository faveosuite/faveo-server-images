---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/basic-troubleshooting-script/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-06-20
last_modified_by: Thirumoorthi Duraipandi
toc: true
title: Faveo Basic Troubleshooting via Scripts
---

<img alt="Troubleshoot" src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ2rxwH6YebmlMEZtIJSwDUehm2GRIMcwJalQ&s" width="200"  />


## Troubleshooting Faveo Helpdesk via Bash Script for:
- Debian-based servers
- RHEL-based servers

## Introduction
The script is designed to ensure that all essential services and configurations on the Faveo-installed server are functioning correctly. It helps validate system components, identify configuration or connectivity issues, and maintain a stable and healthy Faveo Helpdesk environment and it will log the output to a file named <code><b>faveo-check.log</b></code> in the same directory where the script is present. This file will be rotated every time the script is executed.

This script includes the following diagnostic checks:

- **SSL Check:**
Verifies SSL certificate validity for the domain.

- **System Info:** 
Displays OS, uptime, memory usage, CPU, and disk statistics.

- **Service Version and Status:**
Shows version and status of services like Apache, MySQL, PHP, PHP-FPM, Redis, etc.

- **Faveo Info:** 
Displays Faveo APP_URL, plan, and version.

- **Cron Jobs:** 
Lists all active cron jobs for www-data and root users.

- **Supervisor Jobs:** 
Checks the status of Supervisor Jobs.

- **Logged-in Users:** 
Displays currently logged-in (SSH) system users.

- **Billing Connection:**
Tests connection to the Faveo billing server.

- **Root-Owned Files in Faveo Directory:** 
Lists files/folders owned by root that may cause permission issues.

- **Check if Required Ports are Open:** 
Confirms if ports like 80, 443, 3306 and 6379 are listening.

- **Firewall Check:** 
Checks status of firewall (e.g., UFW) and its rules.

---

## Prerequisites:

- **wget**   tool installed.
- **sudo** or **root** user privilege

## How to execute the script:

- To download the script, **[Click here](/installation-scripts/FaveoInstallationScripts/basic-troubleshoot.sh)** or run the wget command below.
```sh
wget http://raw.githubusercontent.com/faveosuite/faveo-server-images/refs/heads/master/installation-scripts/FaveoInstallationScripts/basic-troubleshoot.sh
```

- Once the file is downloaded to the faveo server, we have to give the script executable permissions. To do this, run the command below inside the directory where the script is present.
```
chmod +x basic-troubleshoot.sh
```
- To execute the script, run the command below from the directory where the script is present.
```
sudo ./basic-troubleshoot.sh
```

- Once the script is executed, it will prompt for the  faveo root directory, which is necessary for the script to work.
- It will prompt like below:
```
Enter Faveo root directory path (e.g., /var/www/faveo) /var/www/faveo is the default press enter to use the default value:
```

- If your Faveo root directory is the default as below, just press Enter:
```
/var/www/faveo
```
- Otherwise, enter the correct path manually.

Example:
```
/var/www/html/faveo
```
- Next, select any Option from the Menu. You will be prompted to select one from the following:

Example:
```
Select an option to run:
1) Run all checks
2) SSL Check
3) System Info
4) Service Status
5) Faveo Info
6) Cron Jobs
7) Supervisor Jobs
8) Logged-in Users
9) Billing Connection
10) Root-Owned Files in Faveo Directory
11) Check if Required Ports are Open
12) Firewall check
0) Exit
Enter your choice [0-12]:
```

- Option **1** is to check all information at once, select option **1** to see full diagnostic output in sequence.
- If you want to run a single specific check instead of all, select the relevant option by passing option number **2 to 12** from the menu when prompted.  [Click here for more details and steps to fix issues](###single-specific-check)

---

### To Run all checks

- If selected option is **(1) Run all checks**, it will prompt and run as below:

Example Output:
```
root@Faveo:/home/faveo/script# ./basic-troubleshoot.sh

                                        _______ _______ _     _ _______ _______
                                       (_______|_______|_)   (_|_______|_______)
                                        _____   _______ _     _ _____   _     _
                                       |  ___) |  ___  | |   | |  ___) | |   | |
                                       | |     | |   | |\ \ / /| |_____| |___| |
                                       |_|     |_|   |_| \___/ |_______)\_____/

                              _     _ _______ _       ______ ______  _______  ______ _     _
                             (_)   (_|_______|_)     (_____ (______)(_______)/ _____|_)   | |
                              _______ _____   _       _____) )     _ _____  ( (____  _____| |
                             |  ___  |  ___) | |     |  ____/ |   | |  ___)  \____ \|  _   _)
                             | |   | | |_____| |_____| |    | |__/ /| |_____ _____) ) |  \ \
                             |_|   |_|_______)_______)_|    |_____/ |_______|______/|_|   \_)
```
```
Enter Faveo root directory path (e.g., /var/www/faveo) /var/www/faveo is the default press enter to use the default value: <<< enter if root directory is different from default>>>
Select an option to run:
1) Run all checks
2) SSL Check
3) System Info
4) Service Status
5) Faveo Info
6) Cron Jobs
7) Supervisor Jobs
8) Logged-in Users
9) Billing Connection
10) Root-Owned Files in Faveo Directory
11) Check if Required Ports are Open
12) Firewall check
0) Exit
Enter your choice [0-12]: 1
Welcome to Faveo
Date: Thursday 19 June 2025 11:18:54 AM IST
--------------------------------------------------
Faveo APP_URL from .env: faveo.helpdesk.com
Enter domain for SSL check (leave empty to use APP_URL):
```

- The script will automatically read the <code><b>APP_URL</b></code> from the <code><b>.env</b></code> file inside the faveo root directory, passed in the beginning of the script, you can use the <code><b>APP_URL</b></code>  by pressing <code><b>Enter</b></code> or can use a different domain without <code><b>https://</b></code>, for example <code><b>example.faveohelpdesk.com</b></code>.


- After entering, it will contiue with the script and will show information like *SSL validation, System Info, Service Status, Faveo Application Info, Cron Jobs* (takes 5–10 sec), *Supervisor Jobs, Logged-in Users via SSH, Billing Connection Check, Root-Owned Files/Folders inside the Faveo directory, Port Availability Check*. It will prompt for additional ports if needed enter custom ports separated by comma, if not, just press *Enter*. After entering, it will display *Port Availability* and *Firewall Check* like below.

```
No domain entered. Using APP_URL domain: faveo.helpdesk.com
SSL Check for: faveo.helpdesk.com
SSL is Valid

System Info:
Distro: Ubuntu 22.04.5 LTS
Kernel: 6.8.0-60-generic
Uptime: up 1 hour, 54 minutes
Load Avg: 1.22 0.92 0.97
vCPU Cores: 8
Memory: 8.0Gi used / 15Gi
Disk: 170G used / 320G (57%)

Service Status:
apache2: active (Since: Thu 2025-06-19 09:24:44 IST)
apache2 version: Server version: Apache/2.4.63 (Ubuntu)

httpd version: Server version: Apache/2.4.63 (Ubuntu)

mysql: active (Since: Thu 2025-06-19 09:24:50 IST)
mysql version: mysql  Ver 8.0.42 for Linux on x86_64 (MySQL Community Server - GPL)

mariadb version: mysql  Ver 8.0.42 for Linux on x86_64 (MySQL Community Server - GPL)

redis: active (Since: Thu 2025-06-19 09:24:43 IST)
redis version: Redis server v=6.0.16 sha=00000000:0 malloc=jemalloc-5.2.1 bits=64 build=a3fdef44459b3ad6

redis-server: active (Since: Thu 2025-06-19 09:24:43 IST)
redis-server version: Redis server v=6.0.16 sha=00000000:0 malloc=jemalloc-5.2.1 bits=64 build=a3fdef44459b3ad6

supervisord version: Not found or not applicable

supervisor: active (Since: Thu 2025-06-19 09:24:43 IST)
supervisor version: Not found or not applicable

php8.2-fpm: active (Since: Thu 2025-06-19 09:24:43 IST)
php8.2-fpm version:

php version: 8.2.24

cron: active (Since: Thu 2025-06-19 09:24:43 IST)
cron version: Not found or not applicable

crond version: Not found or not applicable

meilisearch: active (Since: Thu 2025-06-19 09:24:43 IST)
meilisearch version: meilisearch 1.14.0

nginx version: basic-troubleshoot.sh: line 162: nginx: command not found

node version: v22.16.0

npm version: 10.9.2

csf version:

Faveo Application Info:
URL: https://faveo.helpdesk.com
Plan: Faveo Enterprise Pro
Version: v9.4.1

Cron Jobs:
Cron jobs for user: www-data
* * * * * /usr/bin/php /var/www/faveo/artisan schedule:run 2>&1
artisan commands found:
* * * * * /usr/bin/php /var/www/faveo/artisan schedule:run 2>&1
Estimating last run time from system logs:
Jun 19 11:14:01 Faveo CRON[80731]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
Jun 19 11:15:01 Faveo CRON[81560]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
Jun 19 11:16:01 Faveo CRON[82303]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
Jun 19 11:17:01 Faveo CRON[83040]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
Jun 19 11:18:01 Faveo CRON[83801]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
Jun 19 11:19:01 Faveo CRON[84840]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)

Cron jobs for user: root
None

Supervisor Jobs:
faveo-Horizon                    RUNNING   pid 4060, uptime 1:54:24

Logged-in Users:
2

Billing Connection Check:
Billing connection is working.

Root-Owned Files/Folders in Faveo Directory:
No files/folders owned by root found.
```

---

- When it comes to <code><b>Port Availability Check</b></code>, it will prompt the user for custom ports, if any. Please enter the port number separated by a comma. The default ports in the script are <code><b>80, 443, 3306, 6379</b></code>.

- Once entered, it will continue like below:

```
Port Availability Check:
Enter any additional ports to check (comma-separated, or press Enter to skip):

Checking Port 80 (HTTP)
Port 80 is open internally (listening).

Checking Port 6379 (Redis)
Port 6379 is open internally (listening).

Checking Port 443 (HTTPS)
Port 443 is open internally (listening).

Checking Port 3306 (MySQL)
Port 3306 is open internally (listening).

Firewall Check:
UFW is installed.
Status: inactive


--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

- This script's output will be logged to <code><b>faveo-check.log</b></code> inside the same directory where the script is present.

---

### Single Specific Check

- To run a single specific check instead of all, select the relevant option number from the menu when prompted.

- You will be prompted to select one of the following, where you can select options from <code><b>2 to 12</b></code>, which will run the corresponding checks:
```
Select an option to run:
1) Run all checks
2) SSL Check
3) System Info
4) Service Status
5) Faveo Info
6) Cron Jobs
7) Supervisor Jobs
8) Logged-in Users
9) Billing Connection
10) Root-Owned Files in Faveo Directory
11) Check if Required Ports are Open
12) Firewall check
0) Exit
Enter your choice [0-12]:
```

---

#### SSL Validation Check:
- Enter <code><b>2</b></code> to check SSL Validity.

- This is used to verify if the faveo server's SSL is valid inside the server.

Example Output:
```
root@Faveo:/home/faveo/script# ./basic-troubleshoot.sh
                                        _______ _______ _     _ _______ _______
                                       (_______|_______|_)   (_|_______|_______)
                                        _____   _______ _     _ _____   _     _
                                       |  ___) |  ___  | |   | |  ___) | |   | |
                                       | |     | |   | |\ \ / /| |_____| |___| |
                                       |_|     |_|   |_| \___/ |_______)\_____/

                              _     _ _______ _       ______ ______  _______  ______ _     _
                             (_)   (_|_______|_)     (_____ (______)(_______)/ _____|_)   | |
                              _______ _____   _       _____) )     _ _____  ( (____  _____| |
                             |  ___  |  ___) | |     |  ____/ |   | |  ___)  \____ \|  _   _)
                             | |   | | |_____| |_____| |    | |__/ /| |_____ _____) ) |  \ \
                             |_|   |_|_______)_______)_|    |_____/ |_______|______/|_|   \_)
```
```
Enter Faveo root directory path (e.g., /var/www/faveo) /var/www/faveo is the default press enter to use the default value: <<< enter if root directory is different from default>>>

Select an option to run:
1) Run all checks
2) SSL Check
3) System Info
4) Service Status
5) Faveo Info
6) Cron Jobs
7) Supervisor Jobs
8) Logged-in Users
9) Billing Connection
10) Root-Owned Files in Faveo Directory
11) Check if Required Ports are Open
12) Firewall check
0) Exit
Enter your choice [0-12]: 2

Welcome to Faveo
Date: Thursday 19 June 2025 01:03:37 PM IST
--------------------------------------------------
Faveo APP_URL from .env: faveo.helpdesk.com
Enter domain for SSL check (leave empty to use APP_URL):
```


- The script will automatically read the <code><b>APP_URL</b></code> from the <code><b>.env</b></code> file inside faveo root directory passed in while the script is executed, you can use the <code><b>APP_URL</b></code> by pressing <code><b>Enter</b></code> or can use a different domain without <code><b>https://</b></code> for example <code><b>example.faveohelpdesk.com</b></code> after this the output will continue like below.
```
No domain entered. Using APP_URL domain: faveo.helpdesk.com
SSL Check for: faveo.helpdesk.com
SSL is Valid
--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

- This script's output will be logged to <code><b>faveo-check.log</b></code> inside the same directory where the script is present.

 - To fix, please click here and follow the steps [Click here](https://docs.faveohelpdesk.com/docs/installation/providers/enterprise/ssl-error/). If the issue persists, please reach (**support@faveohelpdesk.com***)

---

#### System Info Check:
- Enter <code><b>3</b></code> to check System Info.

- It displays information on System OS, uptime, memory, CPU, disk, and Server resource consumption.

Example Output

```
root@Faveo:/home/faveo/script# ./basic-troubleshoot.sh
                                        _______ _______ _     _ _______ _______
                                       (_______|_______|_)   (_|_______|_______)
                                        _____   _______ _     _ _____   _     _
                                       |  ___) |  ___  | |   | |  ___) | |   | |
                                       | |     | |   | |\ \ / /| |_____| |___| |
                                       |_|     |_|   |_| \___/ |_______)\_____/

                              _     _ _______ _       ______ ______  _______  ______ _     _
                             (_)   (_|_______|_)     (_____ (______)(_______)/ _____|_)   | |
                              _______ _____   _       _____) )     _ _____  ( (____  _____| |
                             |  ___  |  ___) | |     |  ____/ |   | |  ___)  \____ \|  _   _)
                             | |   | | |_____| |_____| |    | |__/ /| |_____ _____) ) |  \ \
                             |_|   |_|_______)_______)_|    |_____/ |_______|______/|_|   \_)
```
```
Enter Faveo root directory path (e.g., /var/www/faveo) /var/www/faveo is the default press enter to use the default value: <<< enter if root directory is different from default>>>

Select an option to run:
1) Run all checks
2) SSL Check
3) System Info
4) Service Status
5) Faveo Info
6) Cron Jobs
7) Supervisor Jobs
8) Logged-in Users
9) Billing Connection
10) Root-Owned Files in Faveo Directory
11) Check if Required Ports are Open
12) Firewall check
0) Exit
Enter your choice [0-12]: 3
Welcome to Faveo
Date: Thursday 19 June 2025 1:00:54 PM IST
--------------------------------------------------
System Info:
Distro: Ubuntu 22.04.5 LTS
Kernel: 6.8.0-60-generic
Uptime: up 3 hours, 45 minutes
Load Avg: 0.92 0.72 0.86
vCPU Cores: 8
Memory: 9.2Gi used / 15Gi
Disk: 170G used / 320G (57%)
--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

- This script's output will be logged to <code><b>faveo-check.log</b></code> inside the same directory where the script is present.

 - If there is any issue, please reach (**support@faveohelpdesk.com***)

---

#### Service status and version check:
- This check will check the status and uptime of services that are necessary for faveo to work.

- Enter <code><b>4</b></code> to check Service Status and Service Version

- Shows version and status of services like Apache, MySQL, PHP, PHP-FPM, Redis, etc.

Example Output:
```
root@Faveo:/home/faveo/script# ./basic-troubleshoot.sh
                                        _______ _______ _     _ _______ _______
                                       (_______|_______|_)   (_|_______|_______)
                                        _____   _______ _     _ _____   _     _
                                       |  ___) |  ___  | |   | |  ___) | |   | |
                                       | |     | |   | |\ \ / /| |_____| |___| |
                                       |_|     |_|   |_| \___/ |_______)\_____/

                              _     _ _______ _       ______ ______  _______  ______ _     _
                             (_)   (_|_______|_)     (_____ (______)(_______)/ _____|_)   | |
                              _______ _____   _       _____) )     _ _____  ( (____  _____| |
                             |  ___  |  ___) | |     |  ____/ |   | |  ___)  \____ \|  _   _)
                             | |   | | |_____| |_____| |    | |__/ /| |_____ _____) ) |  \ \
                             |_|   |_|_______)_______)_|    |_____/ |_______|______/|_|   \_)
```
```
Enter Faveo root directory path (e.g., /var/www/faveo) /var/www/faveo is the default press enter to use the default value: <<< enter if root directory is different from default>>>

Select an option to run:
1) Run all checks
2) SSL Check
3) System Info
4) Service Status
5) Faveo Info
6) Cron Jobs
7) Supervisor Jobs
8) Logged-in Users
9) Billing Connection
10) Root-Owned Files in Faveo Directory
11) Check if Required Ports are Open
12) Firewall check
0) Exit
Enter your choice [0-12]: 4
Welcome to Faveo
Date: Thursday 19 June 2025 1:10:54 PM IST
--------------------------------------------------
Service Status:
apache2: active (Since: Thu 2025-06-19 09:24:44 IST)
apache2 version: Server version: Apache/2.4.63 (Ubuntu)

httpd version: Server version: Apache/2.4.63 (Ubuntu)

mysql: active (Since: Thu 2025-06-19 09:24:50 IST)
mysql version: mysql  Ver 8.0.42 for Linux on x86_64 (MySQL Community Server - GPL)

mariadb version: mysql  Ver 8.0.42 for Linux on x86_64 (MySQL Community Server - GPL)

redis: active (Since: Thu 2025-06-19 09:24:43 IST)
redis version: Redis server v=6.0.16 sha=00000000:0 malloc=jemalloc-5.2.1 bits=64 build=a3fdef44459b3ad6

redis-server: active (Since: Thu 2025-06-19 09:24:43 IST)
redis-server version: Redis server v=6.0.16 sha=00000000:0 malloc=jemalloc-5.2.1 bits=64 build=a3fdef44459b3ad6

supervisord version: Not found or not applicable

supervisor: active (Since: Thu 2025-06-19 09:24:43 IST)
supervisor version: Not found or not applicable

php8.2-fpm: active (Since: Thu 2025-06-19 09:24:43 IST)
php8.2-fpm version:

php-fpm version:

cron: active (Since: Thu 2025-06-19 09:24:43 IST)
cron version: Not found or not applicable

crond version: Not found or not applicable

meilisearch: active (Since: Thu 2025-06-19 09:24:43 IST)
meilisearch version: meilisearch 1.14.0

nginx version: basic-troubleshoot.sh: line 162: nginx: command not found

node version: v22.16.0

npm version: 10.9.2

csf version:

--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

- This script's output will be logged to <code><b>faveo-check.log</b></code> inside the same directory where the script is present.

 - To fix, we can try the following command. If the issue persists, please reach (**support@faveohelpdesk.com***)
```
systemctl restart <<<service name here>>>
```

---

#### Faveo Info Check
- This check is used to check Faveo-related information.
- Enter <code><b>5</b></code> to check Faveo Info

Displays Faveo APP_URL, plan, and version

Example Output:
```
root@Faveo:/home/faveo/script# ./basic-troubleshoot.sh
                                        _______ _______ _     _ _______ _______
                                       (_______|_______|_)   (_|_______|_______)
                                        _____   _______ _     _ _____   _     _
                                       |  ___) |  ___  | |   | |  ___) | |   | |
                                       | |     | |   | |\ \ / /| |_____| |___| |
                                       |_|     |_|   |_| \___/ |_______)\_____/

                              _     _ _______ _       ______ ______  _______  ______ _     _
                             (_)   (_|_______|_)     (_____ (______)(_______)/ _____|_)   | |
                              _______ _____   _       _____) )     _ _____  ( (____  _____| |
                             |  ___  |  ___) | |     |  ____/ |   | |  ___)  \____ \|  _   _)
                             | |   | | |_____| |_____| |    | |__/ /| |_____ _____) ) |  \ \
                             |_|   |_|_______)_______)_|    |_____/ |_______|______/|_|   \_)
```
```
Enter Faveo root directory path (e.g., /var/www/faveo) /var/www/faveo is the default press enter to use the default value: <<< enter if root directory is different from default>>>

Select an option to run:
1) Run all checks
2) SSL Check
3) System Info
4) Service Status
5) Faveo Info
6) Cron Jobs
7) Supervisor Jobs
8) Logged-in Users
9) Billing Connection
10) Root-Owned Files in Faveo Directory
11) Check if Required Ports are Open
12) Firewall check
0) Exit
Enter your choice [0-12]: 5
Welcome to Faveo
Date: Thursday 19 June 2025 1:15:04 PM IST
--------------------------------------------------
Faveo Application Info:
URL: https://example.faveohelpdesk.com
Plan: Faveo Enterprise Pro
Version: v1234..
--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

- This script output will be logged to <code><b>faveo-check.log</b></code> inside the same directory where the script is present.

---


#### Cron Jobs Check
- This check is used to see cron-related data for faveo-related crons.

- Enter <code><b>6</b></code> to check Cron Jobs with the last few run time logs (takes 5–10 sec)

Example Output:
```
root@Faveo:/home/faveo/script# ./basic-troubleshoot.sh
                                        _______ _______ _     _ _______ _______
                                       (_______|_______|_)   (_|_______|_______)
                                        _____   _______ _     _ _____   _     _
                                       |  ___) |  ___  | |   | |  ___) | |   | |
                                       | |     | |   | |\ \ / /| |_____| |___| |
                                       |_|     |_|   |_| \___/ |_______)\_____/

                              _     _ _______ _       ______ ______  _______  ______ _     _
                             (_)   (_|_______|_)     (_____ (______)(_______)/ _____|_)   | |
                              _______ _____   _       _____) )     _ _____  ( (____  _____| |
                             |  ___  |  ___) | |     |  ____/ |   | |  ___)  \____ \|  _   _)
                             | |   | | |_____| |_____| |    | |__/ /| |_____ _____) ) |  \ \
                             |_|   |_|_______)_______)_|    |_____/ |_______|______/|_|   \_)
```
```
Enter Faveo root directory path (e.g., /var/www/faveo) /var/www/faveo is the default press enter to use the default value: <<< enter if root directory is different from default>>>

Select an option to run:
1) Run all checks
2) SSL Check
3) System Info
4) Service Status
5) Faveo Info
6) Cron Jobs
7) Supervisor Jobs
8) Logged-in Users
9) Billing Connection
10) Root-Owned Files in Faveo Directory
11) Check if Required Ports are Open
12) Firewall check
0) Exit
Enter your choice [0-12]: 6
Welcome to Faveo
Date: Thursday 19 June 2025 1:14:30 PM IST
--------------------------------------------------
Cron Jobs:
Cron jobs for user: www-data
* * * * * /usr/bin/php /var/www/faveo/artisan schedule:run 2>&1
artisan commands found:
* * * * * /usr/bin/php /var/www/faveo/artisan schedule:run 2>&1
Estimating last run time from system logs:
Jun 19 13:44:02 Faveo CRON[179717]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
Jun 19 13:45:01 Faveo CRON[180511]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
Jun 19 13:46:01 Faveo CRON[181271]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
Jun 19 13:47:01 Faveo CRON[181997]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
Jun 19 13:48:01 Faveo CRON[182718]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
Jun 19 13:49:01 Faveo CRON[183467]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)

Cron jobs for user: root
None

--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

- This script's output will be logged to <code><b>faveo-check.log</b></code> inside the same directory where the script is present.

 - To fix, try the steps below. If the issue persists, please reach (**support@faveohelpdesk.com***)

 - If the cron is not there, follow <a href="https://docs.faveohelpdesk.com" target="_blank" rel="noopener">**https://docs.faveohelpdesk.com**</a> and select your OS there and follow the cron jobs section in the installation steps.

---

#### Supervisor jobs Check
- This check is used to see if all supervisor jobs are configured and running as expected for faveo

- Enter <code><b>7</b></code> to check the Supervisor jobs running status

Example Output:
```
root@Faveo:/home/faveo/script# ./basic-troubleshoot.sh
                                        _______ _______ _     _ _______ _______
                                       (_______|_______|_)   (_|_______|_______)
                                        _____   _______ _     _ _____   _     _
                                       |  ___) |  ___  | |   | |  ___) | |   | |
                                       | |     | |   | |\ \ / /| |_____| |___| |
                                       |_|     |_|   |_| \___/ |_______)\_____/

                              _     _ _______ _       ______ ______  _______  ______ _     _
                             (_)   (_|_______|_)     (_____ (______)(_______)/ _____|_)   | |
                              _______ _____   _       _____) )     _ _____  ( (____  _____| |
                             |  ___  |  ___) | |     |  ____/ |   | |  ___)  \____ \|  _   _)
                             | |   | | |_____| |_____| |    | |__/ /| |_____ _____) ) |  \ \
                             |_|   |_|_______)_______)_|    |_____/ |_______|______/|_|   \_)
```
```
Enter Faveo root directory path (e.g., /var/www/faveo) /var/www/faveo is the default press enter to use the default value: <<< enter if root directory is different from default>>>

Select an option to run:
1) Run all checks
2) SSL Check
3) System Info
4) Service Status
5) Faveo Info
6) Cron Jobs
7) Supervisor Jobs
8) Logged-in Users
9) Billing Connection
10) Root-Owned Files in Faveo Directory
11) Check if Required Ports are Open
12) Firewall check
0) Exit
Enter your choice [0-12]: 7
Welcome to Faveo
Date: Thursday 19 June 2025 1:20:04 PM IST
--------------------------------------------------
--------------------------------------------------
Supervisor Jobs:
faveo-Horizon                    RUNNING   pid 4060, uptime 4:28:25

--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

- This script's output will be logged to <code><b>faveo-check.log</b></code> inside the same directory where the script is present.

 - To fix, we can try the following command. If the issue persists, please reach (**support@faveohelpdesk.com***) or run the below command.
```
supervisorctl restart all
```

---

#### Logged in Users check
- This is used to check how many users are currently logged in to the server via SSH

- Enter <code><b>8</b></code> to check SSH Logged-in Users

Example Output:
```
root@Faveo:/home/faveo/script# ./basic-troubleshoot.sh
                                        _______ _______ _     _ _______ _______
                                       (_______|_______|_)   (_|_______|_______)
                                        _____   _______ _     _ _____   _     _
                                       |  ___) |  ___  | |   | |  ___) | |   | |
                                       | |     | |   | |\ \ / /| |_____| |___| |
                                       |_|     |_|   |_| \___/ |_______)\_____/

                              _     _ _______ _       ______ ______  _______  ______ _     _
                             (_)   (_|_______|_)     (_____ (______)(_______)/ _____|_)   | |
                              _______ _____   _       _____) )     _ _____  ( (____  _____| |
                             |  ___  |  ___) | |     |  ____/ |   | |  ___)  \____ \|  _   _)
                             | |   | | |_____| |_____| |    | |__/ /| |_____ _____) ) |  \ \
                             |_|   |_|_______)_______)_|    |_____/ |_______|______/|_|   \_)
```
```
Enter Faveo root directory path (e.g., /var/www/faveo) /var/www/faveo is the default press enter to use the default value: <<< enter if root directory is different from default>>>

Select an option to run:
1) Run all checks
2) SSL Check
3) System Info
4) Service Status
5) Faveo Info
6) Cron Jobs
7) Supervisor Jobs
8) Logged-in Users
9) Billing Connection
10) Root-Owned Files in Faveo Directory
11) Check if Required Ports are Open
12) Firewall check
0) Exit
Enter your choice [0-12]: 8
Welcome to Faveo
Date: Thursday 19 June 2025 1:22:04 PM IST
--------------------------------------------------
Logged-in Users:
2

--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```
- This script's output will be logged to <code><b>faveo-check.log</b></code> inside the same directory where the script is present.

---

#### Billing connection
- This check will check the curl connection between the faveo server and billing.faveohelpdesk.com, faveo needs this to validate the license and faveo updates, etc..

- Enter <code><b>9</b></code> to check Faveo Billing Connection

Example Output:
```
root@Faveo:/home/faveo/script# ./basic-troubleshoot.sh
                                        _______ _______ _     _ _______ _______
                                       (_______|_______|_)   (_|_______|_______)
                                        _____   _______ _     _ _____   _     _
                                       |  ___) |  ___  | |   | |  ___) | |   | |
                                       | |     | |   | |\ \ / /| |_____| |___| |
                                       |_|     |_|   |_| \___/ |_______)\_____/

                              _     _ _______ _       ______ ______  _______  ______ _     _
                             (_)   (_|_______|_)     (_____ (______)(_______)/ _____|_)   | |
                              _______ _____   _       _____) )     _ _____  ( (____  _____| |
                             |  ___  |  ___) | |     |  ____/ |   | |  ___)  \____ \|  _   _)
                             | |   | | |_____| |_____| |    | |__/ /| |_____ _____) ) |  \ \
                             |_|   |_|_______)_______)_|    |_____/ |_______|______/|_|   \_)
```
```
Enter Faveo root directory path (e.g., /var/www/faveo) /var/www/faveo is the default press enter to use the default value: <<< enter if root directory is different from default>>>

Select an option to run:
1) Run all checks
2) SSL Check
3) System Info
4) Service Status
5) Faveo Info
6) Cron Jobs
7) Supervisor Jobs
8) Logged-in Users
9) Billing Connection
10) Root-Owned Files in Faveo Directory
11) Check if Required Ports are Open
12) Firewall check
0) Exit
Enter your choice [0-12]: 9
Welcome to Faveo
Date: Thursday 19 June 2025 1:25:08 PM IST
--------------------------------------------------
Billing Connection Check:
Billing connection is working.


--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

- This script's output will be logged to <code><b>faveo-check.log</b></code> inside the same directory where the script is present.

 - To fix, we can try following the steps. If the issue persists, please reach (**support@faveohelpdesk.com***)

 - Try whitelisting this domain in your firewall, <code><b>billing.faveohelpdesk.com</b></code>.

---

#### Root-Owned Files check
- This check will check if any files are owned by root users inside the faveo root directory.

- Enter <code><b>10</b></code> to check Root-Owned Files in Faveo Directory

Example Output:
```
root@Faveo:/home/faveo/script# ./basic-troubleshoot.sh
                                        _______ _______ _     _ _______ _______
                                       (_______|_______|_)   (_|_______|_______)
                                        _____   _______ _     _ _____   _     _
                                       |  ___) |  ___  | |   | |  ___) | |   | |
                                       | |     | |   | |\ \ / /| |_____| |___| |
                                       |_|     |_|   |_| \___/ |_______)\_____/

                              _     _ _______ _       ______ ______  _______  ______ _     _
                             (_)   (_|_______|_)     (_____ (______)(_______)/ _____|_)   | |
                              _______ _____   _       _____) )     _ _____  ( (____  _____| |
                             |  ___  |  ___) | |     |  ____/ |   | |  ___)  \____ \|  _   _)
                             | |   | | |_____| |_____| |    | |__/ /| |_____ _____) ) |  \ \
                             |_|   |_|_______)_______)_|    |_____/ |_______|______/|_|   \_)
```
```
Enter Faveo root directory path (e.g., /var/www/faveo) /var/www/faveo is the default press enter to use the default value: <<< enter if root directory is different from default>>>

Select an option to run:
1) Run all checks
2) SSL Check
3) System Info
4) Service Status
5) Faveo Info
6) Cron Jobs
7) Supervisor Jobs
8) Logged-in Users
9) Billing Connection
10) Root-Owned Files in Faveo Directory
11) Check if Required Ports are Open
12) Firewall check
0) Exit
Enter your choice [0-12]: 10
Welcome to Faveo
Date: Thursday 19 June 2025 1:30:04 PM IST
--------------------------------------------------
Root-Owned Files/Folders in Faveo Directory:
No files/folders owned by root found.


--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

- This indicates that there are no root owned files found the faveoo root directory.

Example Output  (Root-Owned Files in Faveo Directory (Issue))
```
root@Faveo:/home/faveo/script# ./basic-troubleshoot.sh
                                        _______ _______ _     _ _______ _______
                                       (_______|_______|_)   (_|_______|_______)
                                        _____   _______ _     _ _____   _     _
                                       |  ___) |  ___  | |   | |  ___) | |   | |
                                       | |     | |   | |\ \ / /| |_____| |___| |
                                       |_|     |_|   |_| \___/ |_______)\_____/

                              _     _ _______ _       ______ ______  _______  ______ _     _
                             (_)   (_|_______|_)     (_____ (______)(_______)/ _____|_)   | |
                              _______ _____   _       _____) )     _ _____  ( (____  _____| |
                             |  ___  |  ___) | |     |  ____/ |   | |  ___)  \____ \|  _   _)
                             | |   | | |_____| |_____| |    | |__/ /| |_____ _____) ) |  \ \
                             |_|   |_|_______)_______)_|    |_____/ |_______|______/|_|   \_)
```
```
Enter Faveo root directory path (e.g., /var/www/faveo) /var/www/faveo is the default press enter to use the default value: <<< enter if root directory is different from default>>>

Select an option to run:
1) Run all checks
2) SSL Check
3) System Info
4) Service Status
5) Faveo Info
6) Cron Jobs
7) Supervisor Jobs
8) Logged-in Users
9) Billing Connection
10) Root-Owned Files in Faveo Directory
11) Check if Required Ports are Open
12) Firewall check
0) Exit
Enter your choice [0-12]: 10
Welcome to Faveo
Date: Thursday 19 June 2025 1:31:02 PM IST
--------------------------------------------------
Root-Owned Files/Folders in Faveo Directory:
The following items are owned by root:
/var/www/faveo/bootstrap
/var/www/faveo/bootstrap/cache
/var/www/faveo/bootstrap/cache/.gitignore
/var/www/faveo/bootstrap/cache/packages.php
/var/www/faveo/bootstrap/cache/services.php
/var/www/faveo/bootstrap/app.php
/var/www/faveo/bootstrap/autoload.php
/var/www/faveo/storage
/var/www/faveo/storage/debugbar
/var/www/faveo/storage/debugbar/.gitignore
/var/www/faveo/storage/logs
/var/www/faveo/storage/logs/.gitignore
/var/www/faveo/storage/framework
/var/www/faveo/storage/framework/cache
/var/www/faveo/storage/framework/cache/ec
/var/www/faveo/storage/framework/cache/ec/ff
/var/www/faveo/storage/framework/cache/ec/ff/ecffb309874da7e47b1214d6d10704f86a011afd
/var/www/faveo/storage/framework/cache/3a
/var/www/faveo/storage/framework/cache/3a/d1
/var/www/faveo/storage/framework/cache/3a/d1/3ad1fe5763fe6b9bec0a3b5d65d7bc21a47fb6fa
/var/www/faveo/storage/framework/cache/3b
/var/www/faveo/storage/framework/cache/3b/0f
/var/www/faveo/storage/framework/cache/3b/0f/3b0f92f916e4c88725b9dec8b8660187d9db458c
/var/www/faveo/storage/framework/cache/.gitignore
/var/www/faveo/storage/framework/cache/c4
/var/www/faveo/storage/framework/cache/c4/ca
/var/www/faveo/storage/framework/cache/c4/ca/c4ca0a81abf6e7054b095951a267d4644e82f773
/var/www/faveo/storage/framework/cache/6c
/var/www/faveo/storage/framework/cache/6c/c4
/var/www/faveo/storage/framework/cache/6c/c4/6cc4c5c421b9926ff0e1d615b50acd0354cda171
/var/www/faveo/storage/framework/cache/e1
/var/www/faveo/storage/framework/cache/e1/15
/var/www/faveo/storage/framework/cache/e1/15/e11523c5ff23fc1600aca2d8ee5adb542c5ce4b3
/var/www/faveo/storage/framework/views
/var/www/faveo/storage/framework/views/1577e048ef1518d750e5ce1a8465ab0a.php
/var/www/faveo/storage/framework/views/cbc69d7628b7d63f2c7f45f383a8a2ec.php
/var/www/faveo/storage/framework/views/9ee12cbe9019ffa581bbee531368b6cb.php
--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

- This indicates that this list of files and directories is incorrectly owned by root.

- These folders must be owned by the web server user *(usually www-data)* to allow the application to read and write logs, cache, and perform scheduled tasks etc..

 - To fix, we can try the following command. If the issue persists, please reach (**support@faveohelpdesk.com***) or run the below command.

```
chown -R www-data:www-data <<<Enter the faveo root directory here>>>
```

- This script output will be logged to <code><b>faveo-check.log</b></code> inside the same directory where the script is present.

---

#### Required Ports are Open Check

- This Check is to check whether the ports are open internally and the services are listening on the port.

- Enter <code><b>11</b></code> to check if Required Ports are Open for Faveo.

- The script will automatically check commonly required Faveo ports: 80 (HTTP), 443 (HTTPS), 3306 (MySQL), and 6379 (Redis)

- To check additional ports or custom ports, enter them as comma-separated values when prompted

```
Enter any additional ports to check (comma-separated, or press Enter to skip):
```

Example Output:
```
root@Faveo:/home/faveo/script# ./basic-troubleshoot.sh
                                        _______ _______ _     _ _______ _______
                                       (_______|_______|_)   (_|_______|_______)
                                        _____   _______ _     _ _____   _     _
                                       |  ___) |  ___  | |   | |  ___) | |   | |
                                       | |     | |   | |\ \ / /| |_____| |___| |
                                       |_|     |_|   |_| \___/ |_______)\_____/

                              _     _ _______ _       ______ ______  _______  ______ _     _
                             (_)   (_|_______|_)     (_____ (______)(_______)/ _____|_)   | |
                              _______ _____   _       _____) )     _ _____  ( (____  _____| |
                             |  ___  |  ___) | |     |  ____/ |   | |  ___)  \____ \|  _   _)
                             | |   | | |_____| |_____| |    | |__/ /| |_____ _____) ) |  \ \
                             |_|   |_|_______)_______)_|    |_____/ |_______|______/|_|   \_)
```
```
Enter Faveo root directory path (e.g., /var/www/faveo) /var/www/faveo is the default press enter to use the default value: <<< enter if root directory is different from default>>>

Select an option to run:
1) Run all checks
2) SSL Check
3) System Info
4) Service Status
5) Faveo Info
6) Cron Jobs
7) Supervisor Jobs
8) Logged-in Users
9) Billing Connection
10) Root-Owned Files in Faveo Directory
11) Check if Required Ports are Open
12) Firewall check
0) Exit
Enter your choice [0-12]: 11
Welcome to Siva-LWS
Date: Thursday 19 June 2025 02:07:19 PM IST
--------------------------------------------------
Port Availability Check:
Enter any additional ports to check (comma-separated, or press Enter to skip):
```

- When it comes to <code><b>Port Availability Check</b></code>, it will prompt the user for custom ports, if any. Please enter the port number separated by a comma. The default ports in the script are <code><b>80, 443, 3306, 6379</b></code>.
- Once entered, it will continue like below:

```
Checking Port 80 (HTTP)
Port 80 is open internally (listening).

Checking Port 6379 (Redis)
Port 6379 is open internally (listening).

Checking Port 443 (HTTPS)
Port 443 is open internally (listening).

Checking Port 3306 (MySQL)
Port 3306 is open internally (listening).
--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

- This script's output will be logged to <code><b>faveo-check.log</b></code> inside the same directory where the script is present.

 - To fix this issue, try opening the port in the firewall if any is enabled. If the issue persists, please reach (**support@faveohelpdesk.com***)

---

#### Firewall Check

- This is used to check the firewall status from basic firewalls to the CSF firewall inside the server.3

- Enter <code><b>12</b></code> to check Firewall

Example Output:
```
root@Faveo:/home/faveo/script# ./basic-troubleshoot.sh
                                        _______ _______ _     _ _______ _______
                                       (_______|_______|_)   (_|_______|_______)
                                        _____   _______ _     _ _____   _     _
                                       |  ___) |  ___  | |   | |  ___) | |   | |
                                       | |     | |   | |\ \ / /| |_____| |___| |
                                       |_|     |_|   |_| \___/ |_______)\_____/

                              _     _ _______ _       ______ ______  _______  ______ _     _
                             (_)   (_|_______|_)     (_____ (______)(_______)/ _____|_)   | |
                              _______ _____   _       _____) )     _ _____  ( (____  _____| |
                             |  ___  |  ___) | |     |  ____/ |   | |  ___)  \____ \|  _   _)
                             | |   | | |_____| |_____| |    | |__/ /| |_____ _____) ) |  \ \
                             |_|   |_|_______)_______)_|    |_____/ |_______|______/|_|   \_)
```
```
Enter Faveo root directory path (e.g., /var/www/faveo) /var/www/faveo is the default press enter to use the default value: <<< enter if root directory is different from default>>>

Select an option to run:
1) Run all checks
2) SSL Check
3) System Info
4) Service Status
5) Faveo Info
6) Cron Jobs
7) Supervisor Jobs
8) Logged-in Users
9) Billing Connection
10) Root-Owned Files in Faveo Directory
11) Check if Required Ports are Open
12) Firewall check
0) Exit
Enter your choice [0-12]: 12
Welcome to Faveo
Date: Thursday 19 June 2025 02:36:24 PM IST
--------------------------------------------------
Firewall Check:
UFW is installed.
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 6568/tcp                   ALLOW IN    Anywhere
[ 2] 7070/udp                   ALLOW IN    Anywhere
[ 3] 102.106.35.21 1194/tcp     ALLOW OUT   Anywhere                   (out)
[ 4] 8080/tcp                   ALLOW IN    Anywhere
[ 5] 443                        ALLOW IN    102.106.35.21
[ 6] 443                        ALLOW IN    Anywhere
[ 7] 22/tcp                     ALLOW IN    Anywhere
[ 8] 32156/tcp                  ALLOW IN    Anywhere
[ 9] 6568/tcp (v6)              ALLOW IN    Anywhere (v6)
[10] 7070/udp (v6)              ALLOW IN    Anywhere (v6)
[11] 8080/tcp (v6)              ALLOW IN    Anywhere (v6)
[12] 443 (v6)                   ALLOW IN    Anywhere (v6)
[13] 22/tcp (v6)                ALLOW IN    Anywhere (v6)
[14] 32156/tcp (v6)             ALLOW IN    Anywhere (v6)

--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

- This script's output will be logged to <code><b>faveo-check.log</b></code> inside the same directory where the script is present.

 - To fix any issue, please reach (**support@faveohelpdesk.com***)

---

# Help
- If any queries or help with the script please reach **support@faveohelpdesk.com**


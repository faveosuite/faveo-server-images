---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/basic-troubleshooting-script/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-02-02
last_modified_by: Mohammad Asif
toc: true
title: Faveo Basic Troubleshooting via Scripts
---

<img alt="Troubleshoot" src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ2rxwH6YebmlMEZtIJSwDUehm2GRIMcwJalQ&s" width="200"  />


#### Troubleshooting Faveo Helpdesk via Bash Script for:
- Debian-based servers
- RHEL-based servers

## Introduction
The script is designed to ensure that all essential services and configurations on the Faveo-installed server are functioning correctly. It helps validate system components, identify configuration or connectivity issues, and maintain a stable and healthy Faveo Helpdesk environment and it will log the output to a file named <code><b>faveo-check.log</b></code> in the same directory where the script is present. This file will be rotated every time the script is executed.

This script includes the following diagnostic checks:

| Check | What this does |
|------|---------------|
| SSL Check | Verifies SSL certificate validity for the domain. |
| System Info | Displays OS, uptime, memory usage, CPU, and disk statistics. |
| Service Version and Status | Shows version and status of services like Apache, Nginx, MySQL, PHP, PHP-FPM, Redis, etc. |
| Faveo Info | Displays Faveo `APP_URL`, plan, and version. |
| Cron Jobs | Lists all active cron jobs for `www-data` and `root` users along with the last 6 Faveo cron runs with timestamps. |
| Supervisor Jobs | Checks the status of Supervisor jobs. |
| Logged-in Users | Displays currently logged-in (SSH) system users with timestamp and IP address. |
| Billing Connection | Tests connectivity to the Faveo billing server. |
| Root-Owned Files in Faveo Directory | Lists files and folders owned by `root` inside the Faveo directory that may cause permission issues. |
| Check if Required Ports are Open | Confirms whether required ports (e.g., 80, 443, 3306, etc.) for Faveo are open and listening. |
| Firewall Check | Checks the status of the firewall (e.g., UFW) and its active rules. |
| Check Disk I/O | Checks the read and write I/O speed of the storage disk on the Faveo server. |
| Top MEM and CPU Consumptions | Lists the top 10 processes consuming the most memory and CPU. |
| Network Latency | Checks network latency and connectivity to Google and Faveo domains. |
| Check Faveo Size | Calculates the size of the Faveo root directory and the database. |
| PHP Config Values | Lists configured PHP values from `php.ini` files. |
| Check Timeout Settings | Lists timeout settings configured in the web server and PHP. |


---

## Prerequisites:

- **wget**   tool installed.
- **sudo** or **root** user privilege

## How to execute the script:

- To download the script, **[Click here](/installation-scripts/FaveoInstallationScripts/basic-troubleshoot.sh)** or run the *wget* command below.
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
- This script will work only on faveo supported OS distro's otherwise the script will automatically exit.

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]:
```

- Option **1** is to check all information at once, select option **1** to see full diagnostic output in sequence.
- If you want to run a single specific check instead of all, select the relevant option by passing option number **2 to 18** from the menu when prompted.  [Click here for more details and steps to fix issues](#single-specific-check)

---

### To Run all checks:

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 1
Welcome to Faveo
Date: Thursday 19 June 2025 11:18:54 AM IST
--------------------------------------------------
Faveo APP_URL from .env: faveo.helpdesk.com
Enter domain for SSL check (leave empty to use APP_URL):
```

- The script will automatically read the <code><b>APP_URL</b></code> from the <code><b>.env</b></code> file inside the faveo root directory, passed in the beginning of the script, you can use the <code><b>APP_URL</b></code>  by pressing <code><b>Enter</b></code> or can use a different domain without <code><b>https://</b></code>, for example <code><b>example.faveohelpdesk.com</b></code>.


- After entering, it will contiue with the script and will show information like below: 

*SSL validation, System Info, Service Status, Faveo Application Info, Cron Jobs* , *Supervisor Jobs, Logged-in Users via SSH, Billing Connection Check, Root-Owned Files/Folders inside the Faveo directory, Port Availability Check*. 

- It will prompt for additional ports if needed enter custom ports separated by comma, if not, just press *Enter*. After entering, it will display:

 *Port Availability* and *Firewall Check* *Check Disk I/O* *Top MEM and CPU Consumptions* *Network Latency* *Check Faveo Size* *PHP Config Values* *Check Timeout Settings* like below.

```
No domain entered. Using APP_URL domain: faveo.helpdesk.com
SSL Check for: faveo.helpdesk.com
SSL is Valid
Certificate Details:
Domain          : faveo.faveo.com
Subject         : CN = faveo.faveo.com
Issuer (CA)     : C = US, O = Let's Encrypt, CN = E8
Valid From      : Jan 11 02:17:11 2026 GMT
Valid Until     : Apr 11 02:17:10 2026 GMT
Certificate Status : OK (71 days)

System Info:
Distro: Ubuntu 24.04.3 LTS
Kernel: 6.8.0-87-generic
Uptime: up 5 weeks, 1 day, 3 hours, 20 minutes
Load Avg: 0.17 0.24 0.31
vCPU Cores: 16
Memory: 3.6Gi used / 15Gi, Available: 12Gi
Disk Usage (All Mounted Partitions):
Filesystem                         Size  Used Avail Use% Mounted on
tmpfs                              1.6G  1.3M  1.6G   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv  194G  173G   12G  94% /
tmpfs                              7.9G     0  7.9G   0% /dev/shm
tmpfs                              5.0M     0  5.0M   0% /run/lock
/dev/sda2                          2.0G  197M  1.6G  11% /boot
tmpfs                              1.6G   16K  1.6G   1% /run/user/1000
overlay                            194G  173G   12G  94% /var/lib/docker/overlay2/915be71b861e379bb04a7c98ac94d560d64044016c7ac7d25edfb5224f049542/merged

Service Status:
apache2: active (Since: Wed 2026-01-28 06:37:19 IST)
apache2 version: Server version: Apache/2.4.66 (Ubuntu)

mysql: active (Since: Wed 2026-01-28 06:38:42 IST)
mysql version: mysql  Ver 8.0.44-0ubuntu0.24.04.2 for Linux on x86_64 ((Ubuntu))

redis-server: active (Since: Wed 2026-01-28 06:37:47 IST)
redis-server version: Redis server v=7.0.15 sha=00000000:0 malloc=jemalloc-5.3.0 bits=64 build=62c7a5d52c72f4cd

supervisor: active (Since: Wed 2026-01-28 06:37:46 IST)
supervisor version: Not available

php8.2-fpm: active (Since: Wed 2026-01-28 06:37:20 IST)
php8.2-fpm version: PHP 8.2.30 (cli) (built: Dec 18 2025 23:37:12) (NTS)

cron: active (Since: Sat 2026-01-24 06:08:06 IST)
cron version: Not available

nginx: not installed

meilisearch: active (Since: Wed 2025-12-24 11:47:06 IST)
meilisearch version: meilisearch 1.13.3

node: installed
node version: v20.20.0

npm: installed
npm version: 10.8.2

csf: not installed

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
2026-01-29T15:06:01.256874+05:30 Faveo CRON[80731]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
2026-01-29T15:06:01.256874+05:30 Faveo CRON[81560]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
2026-01-29T15:06:01.256874+05:30 Faveo CRON[82303]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
2026-01-29T15:06:01.256874+05:30 Faveo CRON[83040]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
2026-01-29T15:06:01.256874+05:30 Faveo CRON[83801]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
2026-01-29T15:06:01.256874+05:30 Faveo CRON[84840]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)

Cron jobs for user: root
No artisan cron jobs found

Supervisor Jobs:
faveo-Horizon                    RUNNING   pid 4060, uptime 1:54:24

Logged-in Users (SSH Sessions):
User    TTY     Login Time      Idle    Session From
faveo   pts/0  2026-01-29 14:27 0      00h:39m  (10.50.2.10)
faveo   pts/1  2026-01-29 15:05 0      00h:01m  (10.55.6.80)
Total Active SSH Users: 2

Billing Connection Check:
Billing connection is working.

Root-Owned Files/Folders in Faveo Directory:
No files/folders owned by root found.
```

---

- When it comes to <code><b>Port Availability Check</b></code>, it will prompt the user for custom ports, if any. Please enter the port number separated by a comma. The default ports in the script are <code><b>80, 443, 3306, 6379, 7700, 9000, 25, 465, 587, 143, 993, 110, 995, 6001, 9235, 389, 636</b></code>.

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
etc..

Firewall Check:
UFW is installed.
Status: inactive
```
---

- When it comes to <code><b>Disk IO check</b></code> it will ask for Enter directory to test the default directory <code><b>/var/lib/mysql</b></code> used in the script is enough for this test if needed enter your preffered directory.

```
Disk IO Check (ioping):
Read latency test:
--- /var/lib/mysql (ext4 /dev/dm-0 193.8 GiB) ioping statistics ---
19 requests completed in 6.40 ms, 76 KiB read, 2.97 k iops, 11.6 MiB/s
generated 20 requests in 19.0 s, 80 KiB, 1 iops, 4.21 KiB/s
min/avg/max/mdev = 244.1 us / 336.7 us / 432.6 us / 48.6 us
Write latency test:
--- /var/lib/mysql (ext4 /dev/dm-0 193.8 GiB) ioping statistics ---
19 requests completed in 2.99 ms, 76 KiB written, 6.34 k iops, 24.8 MiB/s
generated 20 requests in 3.32 ms, 80 KiB, 6.03 k iops, 23.6 MiB/s
min/avg/max/mdev = 131.8 us / 157.6 us / 185.3 us / 13.0 us
Disk latency within SLA for production workload

Top CPU / Memory Processes (Production SLA-aware):
Top 10 processes by CPU usage:
CRITICAL | CPU: 105.0% | MEM: 0.3% | /usr/bin/php8.2 artisan attachmentSpecific:encryption
CRITICAL | CPU: 100.0% | MEM: 0.0% | ps -eo pid,%cpu,%mem,cmd --sort=-%cpu --no-headers
OK | CPU: 6.2% | MEM: 0.5% | /usr/bin/php -q /var/www/html/saifmaster/artisan schedule:run
OK | CPU: 4.0% | MEM: 6.5% | /usr/sbin/mysqld
OK | CPU: 1.2% | MEM: 0.2% | /usr/bin/python3 /usr/bin/mta-sts-daemon --config /etc/mta-sts-daemon.yml
OK | CPU: 0.7% | MEM: 0.0% | /usr/sbin/zabbix_agentd: collector [idle 1 sec]
OK | CPU: 0.7% | MEM: 0.0% | redis-server *:6379
OK | CPU: 0.5% | MEM: 0.9% | php-fpm: pool www
OK | CPU: 0.5% | MEM: 0.0% | /usr/bin/docker-proxy -proto tcp -host-ip 127.0.0.1 -host-port 6900 -container-ip 172.17.0.2 -container-port 6379 -use-listen-fd
OK | CPU: 0.4% | MEM: 3.3% | /bin/warp-svc
Top 10 processes by Memory usage:
OK | CPU: 4.0% | MEM: 6.5% | /usr/sbin/mysqld
OK | CPU: 0.4% | MEM: 3.3% | /bin/warp-svc
OK | CPU: 0.2% | MEM: 1.1% | php-fpm: pool www
OK | CPU: 0.2% | MEM: 1.1% | php-fpm: pool www
OK | CPU: 0.2% | MEM: 1.1% | php-fpm: pool www
OK | CPU: 0.2% | MEM: 1.1% | php-fpm: pool www
OK | CPU: 0.2% | MEM: 1.1% | php-fpm: pool www
OK | CPU: 0.2% | MEM: 1.1% | php-fpm: pool www
OK | CPU: 0.2% | MEM: 1.1% | php-fpm: pool www
OK | CPU: 0.1% | MEM: 1.1% | php-fpm: pool www

Network Connectivity Test:
Pinging 8.8.8.8 ... OK (avg: 6.303 ms)
Pinging google.com ... OK (avg: 6.149 ms)
Pinging billing.faveohelpdesk.com ... SLOW (avg: 156.857 ms | SLA breached)
Pinging license.faveohelpdesk.com ... SLOW (avg: 156.862 ms | SLA breached)

Faveo Storage Usage (No MySQL login required):
Faveo Directory Size: 3.0G
```

- In this stage it will ask for MySQL data directory on all statndard installation the directory will be /var/lib/mysql so you can press enter if the MySQL data directory is different please enter the directory.

```
Enter MySQL datadir (default: /var/lib/mysql): 
Faveo Database Name: saiffaveo
Database 'saiffaveo' folder size: 249M


PHP Configuration Check:
File: /etc/php/8.2/fpm/php.ini
  file_uploads = On
  allow_url_fopen = On
  short_open_tag = On
  memory_limit = 1024M
  cgi.fix_pathinfo = 0
  upload_max_filesize = 100M
  post_max_size = 100M
  max_execution_time = 360

File: /etc/php/8.2/apache2/php.ini
  file_uploads = On
  allow_url_fopen = On
  short_open_tag = On
  memory_limit = 1024M
  cgi.fix_pathinfo = 0
  upload_max_filesize = 100M
  post_max_size = 100M
  max_execution_time = 360

File: /etc/php/8.2/cli/php.ini
  file_uploads = On
  allow_url_fopen = On
  short_open_tag = On
  memory_limit = 1024M
  cgi.fix_pathinfo = 0
  upload_max_filesize = 100M
  post_max_size = 100M
  max_execution_time = 360

Request Timeout Check:
PHP-FPM:
  request_terminate_timeout = Not set
  max_execution_time = 360

Apache:
  
--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

- This script's output will be logged to <code><b>faveo-check.log</b></code> inside the same directory where the script is present.

---
<a id="single-specific-check"></a>
### Single Specific Check:


- To run a single specific check instead of all, select the relevant option number from the menu when prompted while running the script.

- You will be prompted to select one of the following, where you can select options from <code><b>2 to 18</b></code>, which will run the corresponding checks:
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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]:
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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 2

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
Certificate Details:
Domain          : faveo.helpdesk.com
Subject         : CN = faveo.helpdesk.com
Issuer (CA)     : C = US, O = Let's Encrypt, CN = E8
Valid From      : Jan 11 02:17:11 2026 GMT
Valid Until     : Apr 11 02:17:10 2026 GMT
Certificate Status : OK (71 days)

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 3
Welcome to Faveo
Date: Thursday 19 June 2025 1:00:54 PM IST
--------------------------------------------------
System Info:
Distro: Ubuntu 24.04.3 LTS
Kernel: 6.8.0-87-generic
Uptime: up 5 weeks, 1 day, 6 hours, 16 minutes
Load Avg: 0.38 0.49 0.55
vCPU Cores: 16
Memory: 3.6Gi used / 15Gi, Available: 11Gi
Disk Usage (All Mounted Partitions):
Filesystem                         Size  Used Avail Use% Mounted on
tmpfs                              1.6G  1.3M  1.6G   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv  194G  173G   12G  94% /
tmpfs                              7.9G     0  7.9G   0% /dev/shm
tmpfs                              5.0M     0  5.0M   0% /run/lock
/dev/sda2                          2.0G  197M  1.6G  11% /boot
tmpfs                              1.6G   16K  1.6G   1% /run/user/1000
overlay                            194G  173G   12G  94% /var/lib/docker/overlay2/915be71b861e379bb04a7c98ac94d560d64044016c7ac7d25edfb5224f049542/merged


--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.

```

- This script's output will be logged to <code><b>faveo-check.log</b></code> inside the same directory where the script is present.

 - If there is any issue, please reach (**support@faveohelpdesk.com***)

---

#### Service status and version check:

- Enter <code><b>4</b></code> to check Service Status and Version.

- This check will check the status and uptime of services that are necessary for faveo to work.

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 4
Welcome to Faveo
Date: Thursday 19 June 2025 1:10:54 PM IST
--------------------------------------------------
Service Status:
apache2: active (Since: Wed 2026-01-28 06:37:19 IST)
apache2 version: Server version: Apache/2.4.66 (Ubuntu)

mysql: active (Since: Wed 2026-01-28 06:38:42 IST)
mysql version: mysql  Ver 8.0.44-0ubuntu0.24.04.2 for Linux on x86_64 ((Ubuntu))

redis-server: active (Since: Wed 2026-01-28 06:37:47 IST)
redis-server version: Redis server v=7.0.15 sha=00000000:0 malloc=jemalloc-5.3.0 bits=64 build=62c7a5d52c72f4cd

supervisor: active (Since: Wed 2026-01-28 06:37:46 IST)
supervisor version: Not available

php8.2-fpm: active (Since: Wed 2026-01-28 06:37:20 IST)
php8.2-fpm version: PHP 8.2.30 (cli) (built: Dec 18 2025 23:37:12) (NTS)

cron: active (Since: Sat 2026-01-24 06:08:06 IST)
cron version: Not available

nginx: not installed

meilisearch: active (Since: Wed 2025-12-24 11:47:06 IST)
meilisearch version: meilisearch 1.13.3

node: installed
node version: v20.20.0

npm: installed
npm version: 10.8.2

csf: not installed


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

#### Faveo Info Check:

- Enter <code><b>5</b></code> to check Faveo Info

- This check is used to check Faveo product related information.

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 5
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


#### Cron Jobs Check:

- Enter <code><b>6</b></code> to check Cron Jobs with the last few run time logs (takes 5-10 sec)

- This check is used to see cron-related data for faveo-related crons.

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 6
Welcome to Faveo
Date: Thursday 19 June 2025 1:14:30 PM IST
--------------------------------------------------
Cron Jobs:
Cron jobs for user: www-data
* * * * * /usr/bin/php /var/www/faveo/artisan schedule:run 2>&1
artisan commands found:
* * * * * /usr/bin/php /var/www/faveo/artisan schedule:run 2>&1
Estimating last run time from system logs:
2026-01-29T18:04:01.450271+05:30 Faveo CRON[179717]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
2026-01-29T18:04:01.450271+05:30 Faveo CRON[180511]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
2026-01-29T18:04:01.450271+05:30 Faveo CRON[181271]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
2026-01-29T18:04:01.450271+05:30 Faveo CRON[181997]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
2026-01-29T18:04:01.450271+05:30 Faveo CRON[182718]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)
2026-01-29T18:04:01.450271+05:30 Faveo CRON[183467]: (www-data) CMD (/usr/bin/php /var/www/faveo/artisan schedule:run 2>&1)

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

#### Supervisor jobs Check:

- Enter <code><b>7</b></code> to check the Supervisor jobs running status

- This check is used to see if all supervisor jobs are configured and running as expected for faveo

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 7
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

#### Logged in Users check:

- Enter <code><b>8</b></code> to check SSH Logged-in Users

- This is used to check how many users are currently logged in to the server via SSH

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 8
Welcome to Faveo
Date: Thursday 19 June 2025 1:22:04 PM IST
--------------------------------------------------
Logged-in Users (SSH Sessions):
User    TTY     Login Time      Idle    Session From
test   pts/0  2026-01-29 14:27 0      03h:38m  (10.20.30.40)
test   pts/1  2026-01-29 18:05 0      00h:00m  (10.20.30.41)
test   pts/3  2026-01-29 16:15 0      01h:50m  (10.20.30.42)
test   pts/5  2026-01-29 16:15 0      01h:50m  (10.20.30.43)
test   pts/6  2026-01-29 16:32 0      01h:33m  (10.20.30.44)
test   pts/7  2026-01-29 16:32 0      01h:33m  (10.20.30.45)
Total Active SSH Users: 6


--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```
- This script's output will be logged to <code><b>faveo-check.log</b></code> inside the same directory where the script is present.

---

#### Billing connection:

- Enter <code><b>9</b></code> to check Faveo Billing Connection

- This check will check the curl connection between the faveo server and billing.faveohelpdesk.com, faveo needs this to validate the license and faveo updates, etc..

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 9
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

#### Root-Owned Files check:

- Enter <code><b>10</b></code> to check Root-Owned Files in Faveo Directory

- This check will check if any files are owned by root users inside the faveo root directory.

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 10
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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 10
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

 - To fix, we can try the following command. If the issue persists, please reach (**support@faveohelpdesk.com**) or run the below command.

```
chown -R www-data:www-data <<<Enter the faveo root directory here>>>
```

- This script output will be logged to <code><b>faveo-check.log</b></code> inside the same directory where the script is present.

---

#### Required Ports are Open Check:

- Enter <code><b>11</b></code> to check if Required Ports are Open for Faveo.

- This Check is to check whether the ports are open internally and the services are listening on the port.

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 11
Welcome to Siva-LWS
Date: Thursday 19 June 2025 02:07:19 PM IST
--------------------------------------------------
Port Availability Check:
Enter any additional ports to check (comma-separated, or press Enter to skip):
```

- When it comes to <code><b>Port Availability Check</b></code>, it will prompt the user for custom ports, if any. Please enter the port number separated by a comma. The default ports in the script are <code><b>80, 443, 3306, 6379</b></code>.

> <code><b>Note:</b></code> Not all the ports are required for faveo, in this check it will print all the ports that are available for faveo to use like EMAIL releated ports etc.. check for the ports that releate to the issue.

- Once entered, it will continue like below:

```
Checking Port 80 (HTTP)
Port 80 is open internally (listening).

Checking Port 110 (POP-Plain/STARTTLS)
Port 110 is NOT open internally.

Checking Port 6379 (Redis)
Port 6379 is open internally (listening).

Checking Port 6001 (Websocket Proxy)
Port 6001 is NOT open internally.

Checking Port 143 (IMAP-Plain/STARTTLS)
Port 143 is NOT open internally.

Checking Port 7700 (Meilisearch)
Port 7700 is open internally (listening).

Checking Port 9235 (Nats)
Port 9235 is NOT open internally.

Checking Port 25 (SMTP-NONE)
Port 25 is open internally (listening).

Checking Port 9000 (PHP-FPM)
Port 9000 is NOT open internally.

Checking Port 636 (LDAPS)
Port 636 is NOT open internally.

Checking Port 465 (SMTP-SSL)
Port 465 is NOT open internally.

Checking Port 587 (SMTP-STARTTLS)
Port 587 is NOT open internally.

Checking Port 389 (LDAP)
Port 389 is NOT open internally.

Checking Port 443 (HTTPS)
Port 443 is open internally (listening).

Checking Port 993 (IMAP-SSL)
Port 993 is NOT open internally.

Checking Port 995 (POP-SSL)
Port 995 is NOT open internally.

Checking Port 3306 (MySQL)
Port 3306 is open internally (listening).


--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

- This script's output will be logged to <code><b>faveo-check.log</b></code> inside the same directory where the script is present.

 - To fix this issue, try opening the port in the firewall if any is enabled. If the issue persists, please reach (**support@faveohelpdesk.com***)

---

#### Firewall Check:

- Enter <code><b>12</b></code> to check Firewall

- This is used to check the firewall status from basic firewalls to the CSF firewall inside the server.3

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 12
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

#### Check Disk I/O:

- Enter <code><b>13</b></code> to check the disk I/O speed.

- This is used to find whether the stoage disk in the server is production compatible with the I/O check.

- In this check we use /var/lib/mysql this is the database data directory, you can enter the direcorty that you want to check or if it is diferent.

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 13
Welcome to Faveo
Date: Thursday 19 June 2025 02:36:24 PM IST
--------------------------------------------------

Disk IO Check (ioping):
Enter directory to test [default: /var/lib/mysql]: 
Read latency test:
--- /var/lib/mysql (ext4 /dev/dm-0 193.8 GiB) ioping statistics ---
19 requests completed in 5.27 ms, 76 KiB read, 3.61 k iops, 14.1 MiB/s
generated 20 requests in 19.0 s, 80 KiB, 1 iops, 4.21 KiB/s
min/avg/max/mdev = 98.9 us / 277.2 us / 379.1 us / 70.5 us
Write latency test:
--- /var/lib/mysql (ext4 /dev/dm-0 193.8 GiB) ioping statistics ---
19 requests completed in 3.18 ms, 76 KiB written, 5.97 k iops, 23.3 MiB/s
generated 20 requests in 3.58 ms, 80 KiB, 5.58 k iops, 21.8 MiB/s
min/avg/max/mdev = 126.4 us / 167.4 us / 256.7 us / 27.2 us
Disk latency within SLA for production workload


--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

---

#### Top MEM and CPU Consumptions:

- Enter <code><b>14</b></code> to check the top 10 memory and cpu consuming processes.

- This option will share the TOP 10 Memory and CPU consuming process running in the server.

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 14
Welcome to Faveo
Date: Thursday 19 June 2025 02:36:24 PM IST
--------------------------------------------------

Top CPU / Memory Processes (Production SLA-aware):
Top 10 processes by CPU usage:
OK | CPU: 57.7% | MEM: 5.8% | /usr/bin/php8.2 artisan ldap:sync
OK | CPU: 50.0% | MEM: 0.0% | ps -eo pid,%cpu,%mem,cmd --sort=-%cpu --no-headers
OK | CPU: 4.6% | MEM: 5.6% | /usr/sbin/mysqld
OK | CPU: 1.2% | MEM: 0.1% | /usr/bin/python3 /usr/bin/mta-sts-daemon --config /etc/mta-sts-daemon.yml
OK | CPU: 0.7% | MEM: 0.0% | /usr/sbin/zabbix_agentd: collector [idle 1 sec]
OK | CPU: 0.6% | MEM: 0.0% | redis-server *:6379
OK | CPU: 0.5% | MEM: 0.5% | /usr/bin/php -q /var/www/html/manikz/artisan schedule:run
OK | CPU: 0.4% | MEM: 3.1% | /bin/warp-svc
OK | CPU: 0.4% | MEM: 0.0% | /usr/bin/docker-proxy -proto tcp -host-ip 127.0.0.1 -host-port 6900 -container-ip 172.17.0.2 -container-port 6379 -use-listen-fd
OK | CPU: 0.3% | MEM: 0.0% | /usr/lib/systemd/systemd --system --deserialize=88
Top 10 processes by Memory usage:
OK | CPU: 57.6% | MEM: 5.8% | /usr/bin/php8.2 artisan ldap:sync
OK | CPU: 4.6% | MEM: 5.6% | /usr/sbin/mysqld
OK | CPU: 0.4% | MEM: 3.1% | /bin/warp-svc
OK | CPU: 0.1% | MEM: 1.1% | php-fpm: pool www
OK | CPU: 0.1% | MEM: 1.1% | php-fpm: pool www
OK | CPU: 0.1% | MEM: 1.1% | php-fpm: pool www
OK | CPU: 0.1% | MEM: 1.1% | php-fpm: pool www
OK | CPU: 0.1% | MEM: 1.1% | php-fpm: pool www
OK | CPU: 0.1% | MEM: 1.1% | php-fpm: pool www
OK | CPU: 0.1% | MEM: 1.1% | php-fpm: pool www


--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

---

#### Network Latency:

- Enter <code><b>15</b></code>  to check the network latency.

- This option will check the network latency speed in the server it will check with google.com and faveo billing and license domains.

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 15
Welcome to Faveo
Date: Thursday 19 June 2025 02:36:24 PM IST
--------------------------------------------------

Network Connectivity Test:
Pinging 8.8.8.8 ... OK (avg: 6.380 ms)
Pinging google.com ... OK (avg: 6.271 ms)
Pinging billing.faveohelpdesk.com ... SLOW (avg: 157.093 ms | SLA breached)
Pinging license.faveohelpdesk.com ... SLOW (avg: 156.836 ms | SLA breached)


--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

---

#### Check Faveo Size:

- Enter <code><b>16</b></code> to check the faveo size.

- This check is used to check the faveo size, It will check both faveo filesystem size and database size in the server.

- Also for this check you should have entered the faveo root directory path correctly in the begining of the script.

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 16
Date: Thursday 19 June 2025 02:36:24 PM IST
--------------------------------------------------
Faveo Storage Usage:
Faveo Directory Size: 3.0G
Enter MySQL datadir (default: /var/lib/mysql): 
Faveo Database Name: faveo
Database 'faveo' folder size: 249M


--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

---

#### PHP Config Values:

- Enter <code><b>17</b></code> for PHP Config Values check.

- This check will show the configured php values that are required for faveo inside the server.

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 17
Date: Thursday 19 June 2025 02:36:24 PM IST
--------------------------------------------------
PHP Configuration Check:
File: /etc/php/8.2/fpm/php.ini
  file_uploads = On
  allow_url_fopen = On
  short_open_tag = On
  memory_limit = 1024M
  cgi.fix_pathinfo = 0
  upload_max_filesize = 100M
  post_max_size = 100M
  max_execution_time = 360

File: /etc/php/8.2/apache2/php.ini
  file_uploads = On
  allow_url_fopen = On
  short_open_tag = On
  memory_limit = 1024M
  cgi.fix_pathinfo = 0
  upload_max_filesize = 100M
  post_max_size = 100M
  max_execution_time = 360

File: /etc/php/8.2/cli/php.ini
  file_uploads = On
  allow_url_fopen = On
  short_open_tag = On
  memory_limit = 1024M
  cgi.fix_pathinfo = 0
  upload_max_filesize = 100M
  post_max_size = 100M
  max_execution_time = 360


--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

---

#### Check Timeout Settings

- Enter <code><b>18</b></code> for timeout settings check.

- This check will show the timeout settings configured in the webserver level inside the server.

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
13) Check Disk I/O
14) Top MEM and CPU Consumptions
15) Network Latency
16) Check Faveo Size
17) PHP Config Values
18) Check Timeout Settings
0) Exit
Enter your choice [0-18]: 18
Date: Thursday 19 June 2025 02:36:24 PM IST
--------------------------------------------------
Request Timeout Check:
PHP-FPM:
  request_terminate_timeout = Not set
  max_execution_time = 360

Apache:


--------------------------------------------------
Script by Faveo Helpdesk | support@faveohelpdesk.com
Execution complete.
```

---

# Help
- If any queries or help with the script please reach **support@faveohelpdesk.com**


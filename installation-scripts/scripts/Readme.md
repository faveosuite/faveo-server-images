# Faveo Helpdesk Health and Status Check

Instructions on how to download and execute faveo-health.sh script to check the Health and status of the Faveo Hosted Linux server.
<b>Note:</b> This script will work on all major Linux Distros recommended by Faveo.

Prerequisites:
* sudo or root privilege
* wget insatlled on the server

Download the faveo-health.sh script using wget
```sh
wget https://github.com/ladybirdweb/faveo-server-images/raw/master/installation-scripts/FaveoInstallationScripts/faveo-health.sh
```
Once downloaded, navigate to the folder where the script has been downloaded and execute the below command to provide executable permission to the faveo-health.sh script
```sh
sudo chmod +x faveo-health.sh
```
Execute the script as root user or with sudo privilege.
```sh
sudo bash faveo-script.sh
```
This script is tested on all major Linux distros recommended by Faveo.

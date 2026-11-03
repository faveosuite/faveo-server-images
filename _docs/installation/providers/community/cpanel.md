---
layout: single
type: docs
permalink: /docs/installation/providers/community/cpanel/
redirect_from:
  - /theme-setup/
last_modified_at: 2020-06-09
toc: true
title: "Installing Faveo Helpdesk on cPanel"
---

<img alt="cPanel" src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/CPanel_logo.svg/1280px-CPanel_logo.svg.png" width="120"  />

Faveo is a self-hosted software where you can install the software by yourself on your own servers. While the installer provides step by step guide during the installation, it's important and helpful to have general knowledge about Web servers, PHP and MySQL.

Before getting started make sure your server meets following minimum requirement required to install and use Faveo as listed [here](/docs/system-requirement/requirement)

Faveo can run on [cPanel](https://cpanel.net/).

-   [Installation steps](#installation-steps)
    -   [1. Upload Faveo](#1-upload-faveo)
    -   [2. Setup the database](#2-setup-the-database)
    -   [3. Install Faveo](#3-gui-faveo-installer)
    -   [4. Configure cron job](#4-configure-cron-job)
    -   [5. Final step](#final-step)


<a id="installation-steps" name="installation-steps"></a>
## Installation steps

<a id="1-upload-faveo" name="1-upload-faveo"></a>
### 1. Upload Faveo
Please download Faveo Helpdesk from [https://store.faveohelpdesk.com](https://store.faveohelpdesk.com) and upload the .zip files in the folder of your choice on your server.


<img alt="" src="https://lh6.googleusercontent.com/QvogNHnM9veEU-FO2RBah-5BlD0bqhL3Tp_2Td2R2aunRBxwEbbKfCkmbb9DhW9TT9IwkFh8RdDScutANFZ01rHFrx8O5V_EU71NSbDgTjsrGLulJcv5b74Tc_FeoYHlD1TwVbMu"  />

<img alt="" src="https://lh6.googleusercontent.com/Tix0BlPoyjxHnYHEnNnen6bYjA1MByWDrLa_wvDZn3Kvgy2O564JzXwoNLZG9ZbOazgCSspzx61OwchYdyVBWl1GIE_tPohKfeSWnB4ZIMbbRkAe-QUawpBdmSYFCRryag0-ZZ1C"  />

Open cPanel File Manager and navigate to public_html directory/folder, You can directly upload Faveo files here or create a sub directory to host Faveo
 
<img alt="" src="https://lh4.googleusercontent.com/K6s9RwFFuKwf_xJxh27op-I8yZVauLZckirVkeP0UBFbVpz9qIVUO6WM3x5OBKjePGDWo0LZERLK4xDKE5nMu6iccF92c_mmBEk7gDv14-MkM4aiO_Z0JPJCtmLtgpGzsrgtOPai"  />

unzip and exctract the content of .zip file

<img alt="" src="https://lh3.googleusercontent.com/-G70yy2sOPWNWW8e9mVqA1vSs0xRIrxr9AeWipZtoMtig9403C_JiJNChrfUiTjCRdDf1cTLnVLSYphV5d4HvSDBYMaYI3jkmfgtf0JkuGgdlw3PaaOWTjXGG2YKmQU-NLJkYuis"  />

Once the file is extracted within the folder delete the .zip file.


<a id="2-setup-the-database" name="2-setup-the-database"></a>
### 2. Setup the database

Navigate to CPanel > MySQL and Database and click on it.

<img alt="" src="https://lh4.googleusercontent.com/aLfs9EGYVnk3m2iPALGwmK_bOqns5mJSD2AQE-LOQDLioZWCBzx_dDsWWE2cuqjfLIspPj52U6QHHJ31AMfS_vkCIkjufhjEb_4LMN1vBYXUR1EJ4BXhyv5hhHsHOOVzEGXN9Lc-"  />

Create a New Database on this page

<img alt="" src="https://lh5.googleusercontent.com/Wi-ZYJObYIE0LnjSx-tzu113Ze-J6raxZCNLPgK2Kbh5hrkMNjaLb9nhUSzS61ldK697OeBudr_ZcYKYMwIRjRzDgXHhlCqzMrS-OqqoyF5EWHz7uyHSU-W_9XzUjsd65SDlpFmI"  />

Create a new user for the database by registering the user name.

<img alt="" src="https://lh6.googleusercontent.com/ZAAs160phqKUZReeOoUKoHgoArdebNwxMait4rAn5eFEXn1AsyOU29w2l8igfBHBTcLAjQS7hHCVIbPb6KjQP2dSb7VgCe5Z6HG9PXFyMFTz-6rhjR3EZF6s6XsM7Yu2oGZa8QMg"  />

Now link the newly created user with the Database you have created, under Add New User to Database. Select the Database name from the list for which the user needs to be added and select the user name to add with the DB.

In Manage User Privileges, you can give access privileges (Choose All Privileges checkbox) ) to the newly created user and click on the Make Changes button save the details. Click on “Go back” to get the database page.


<img alt="" src="https://lh5.googleusercontent.com/IZIPudyrGRC92QQXVAQiIpTozEuJeseyj9r4q-23AvDu_etpKkp3tVzFgatr1D7NPqmVW_q1tPo9Hw_oh4d6lpJo9KhOp60Ba-nH-198LyIKEUxskkl1FjeajVS90vUS9HqUCg6x"  />

<img alt="" src="https://lh6.googleusercontent.com/HFGhvCd3mWw8LlKhi2R8bQik4ZhL9K6Ui_8-FIxEd5sdDSlUiH3zhiwR_pp7kOBpjAEE4W9phbFu6DzV3B4JfQP3DvWvZsW5lFyRq1rKlM0cAbpLuazcwN7x8cqtoRZjscdXrM6M"  />


<a id="3-gui-faveo-installer" name="3-gui-faveo-installer"></a>
### 3. Install Faveo

Now you can install Faveo via [GUI](/docs/installation/installer/gui) Wizard or [CLI](/docs/installation/installer/cli)

<a id="4-configure-cron-job" name="4-configure-cron-job"></a>
### 4. Configure cron job

Faveo requires some background processes to continuously run. 
Basically those crons are needed to receive emails

Go to CPanel > Crons Jobs > Add New Cron Job to set the cron URL

<img alt="" src="https://lh6.googleusercontent.com/SDTOXrj74XAcbuRVAFGhCwqXJ_y7WRG7GzRqy3x7FGMmpzmszahkM7udnnERWLkuCugdqwrNe5UXDWqk443GhIlM9VEV2yhhxk-N-ntJmgpmqIWAp3l1AK13Xpsth3hP1wxr-W8E"  />


<a id="final-step" name="final-step"></a>
### 5. Final step

The final step is to have fun with your newly created instance, which should be up and running to `http://localhost` or the domain you have configured Faveo with.
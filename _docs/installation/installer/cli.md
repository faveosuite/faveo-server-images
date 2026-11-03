---
layout: single
type: docs
permalink: /docs/installation/installer/cli/
redirect_from:
  - /theme-setup/
last_modified_at: 2020-06-09
toc: true
title: "Faveo CLI Installer"
---

Faveo comes with a CLI installer to help and guide you through the installation process. While the installer provides step by step guide during the installation, it's important and helpful to have general knowledge about Web servers, PHP and MySQL.

Before getting started make sure your server meets following [minimum requirement](/docs/system-requirement/requirement/) required to install and use Faveo

<a id="getting-started" name="getting-started"></a>
## Getting Started

Download the latest version of Faveo from [https://store.faveohelpdesk.com](https://store.faveohelpdesk.com) and upload the .zip files in the folder/directory on your server.

Faveo Community version can also be downloaded directly from [Github](https://github.com/ladybirdweb/faveo-helpdesk)

Basic knowledge of using FTP is an added advantage at this stage. If you don't know how to use FTP, we would recommend you read the documentation supplied with your FTP client and learn the basics of uploading and setting permissions on files. 

Type the command below to start the Faveo CLI installer

```sh
php artisan install:faveo
```

<img src="https://lh5.googleusercontent.com/Pmf71TrKPH-cHr2fBOUyJxusRodK0V56EAcGRh51z_7KXJkwdQfpbgK-EC72XlGVnpLW98Mx7FWN2bOc0WA0Zex-LxKFnWGLZxQXJRIpckE05ZFJshKtOvCDS3ksVUJsgcoJbBdL" alt="" />

<a id="step1" name="step1"></a>
### Step 1: Server Requirements

The installer will perform the system requirement test and if it spots any errors it will report. When all your server checklists are configured correctly it displays as “Loading”. You can Continue to next installation step once all the server requirment are meet.

<img src="https://lh5.googleusercontent.com/Pmf71TrKPH-cHr2fBOUyJxusRodK0V56EAcGRh51z_7KXJkwdQfpbgK-EC72XlGVnpLW98Mx7FWN2bOc0WA0Zex-LxKFnWGLZxQXJRIpckE05ZFJshKtOvCDS3ksVUJsgcoJbBdL" alt="" />
    
<a id="step2" name="step2"></a>
### Step 2: License Key

Enter the license key received for the purchased product. Refer the link [How to get the product license key?](/docs/helpers/license-key)

<img src="https://lh3.googleusercontent.com/hvtKHjaJN_ZHGiblc2Wzm0oQz-TnchDeNHZPQ8WA6YNd8s6Ub8queeUieYZqQbBV-wb9p8BQDjf-rS7xYuLCUsTdbl_iFnbb8w4fBKZfGOWztomUzOmrfLqLPpvy03tzGy0-ruby" alt="" />

<a id="step3" name="step3"></a>    
### Step 3: Database Setup

Establish the database connection by providing the database details.

Fill the Database Name, Database username, and password. The installer will create .env file and save these details in that file

<img src="https://lh4.googleusercontent.com/wsH3nAq8FBYpaFkDxY4T0T92msQVmzR_NSRYJj3Q88HLGFJzwDbc7GyHtHlYdItfFb-zgtBk2DQGrJZ0QW6mlP4cg42yzpjbypy37Z6QqqQCco6B5VqRfH_i6Sm0GtOW8X2ZnXXy" alt="" />


<a id="step4" name="step4"></a>
### Step 4: Install Database

Once installer has created .env file, you can run command for migrating and seeding database. 

```sh
php artisan install:db
```

<img src="https://lh3.googleusercontent.com/JO1GVEcDfOsObyw-AZDh24AYvXZ4LwJ7h-LKe0MtmBogRhMcBrZFh49-g_3fJ5Zcba_lRXPCGIkRfS_uWCLFTa-CIdd9XpThaNsHkpR8LGxc7YOkFt5HpFddXcHLmt5KulQdXzCS" alt="" />

<img src="https://lh6.googleusercontent.com/-Gh5codKaHw00G2a3IHezQaGl0r8KrvHpxl8hnAlbe5zn24P1ow3AQ89Q3AYCdtZmP74EUfi3LPFcAgZ3I6VnxV5KTYbwyYO1S0nrfblnl9z9xDhTLVrMiCgkLkvE-izwh2R-ppP" alt="" />
    
On completion user_name, email and password are displayed on the screen. You can use this to login to Faveo
    
Congratulations! Faveo is installed and operational!

<a id="step6" name="step6"></a>
### Step 5: Start using Faveo

Go to the browser and hit the Faveo URL to login and start using faveo
<img src="https://lh3.googleusercontent.com/4OXyz8qOcKKrxCOz7vEhnmQz7udSeJMlXNfwnVZ12zdlYKPHr_oozdhn6AGtwazdcmqfx-BdxE6Jj4ZHS3iLY4XtRmbH7RxjdB8l2vJZ4uWaIRwIdQNZILD2TcIzkn5hUzp6J7F2" alt="" />

**Note:** Installer performs basic configuration, required to get Faveo up and running. Further configuration is required post-install, to make the system fully functional like
- Email configuration
- Setting Cron Job URL

Faveo can be also installed via a [GUI](/docs/installation/installer/gui) installer. 

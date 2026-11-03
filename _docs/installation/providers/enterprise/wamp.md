---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/wamp/
redirect_from:
  - /theme-setup/
last_modified_at: 2020-06-09
toc: true
title: "Faveo Helpdesk Installation on Wamp Server with Apache on PHP 7.3"
---

Faveo can run on [WamServer](https://www.wampserver.com/).

-   [Installation steps](#installation-steps)
    -   [1. Install WAMP](#step1)
    -   [2. Upload Faveo](#step2)
    -   [3. Setup the database](#step3)
    -   [4. Enable Cacert.pem](#step4)
    -   [5. Install Faveo](#step5)
    -   [6. Configure cron job](#step6)
    -   [7. Final step](#step7)
    
 <a id="step1" name="step1"></a>   
## <strong>1: Install WAMP</strong>
Download and install latest version of WAMP server on your Windows dekstop/server

<a id="step2" name="step2"></a>
## <strong>2: Download Faveo Helpdesk Software</strong>

Please download Faveo Helpdesk from [https://store.faveohelpdesk.com](https://store.faveohelpdesk.com) and upload it to below directory

Upload the .zip file (c:\\Wamp 64\www\Faveo) to the required location and unzip the file.

<img alt="" src="https://lh3.googleusercontent.com/Yff673nIV2-eTUdpElGwQVz-BJi9iHIP-RFkts00v-CQwme5pEpmnlpN9Nqy_5NDT7qIr1OFdfSPCXYSIvcE7t5Pe4Bbcs1tldEvHIEzAJvYuEhBzW2xG0OKBk_ix6iua6JjPI9U"  />

<a id="step3" name="step3"></a>
## <strong> 3: Enable Cacert.pem file in php.ini file</strong>

<a id="3a" name="3a"></a>
<b>3(a): Download and extract the pem file save it inside your php directory</b>

Example: (C:\Program Files\iis express\PHP\v7.2 or 7.3)

Alternative Link For Downloading pem file

<a id="3b" name="3b"></a>
<b>3(b): Uncomment the below line and add the directory of the file in your php.ini and phpforApache.ini file</b>

Repalce the curl.cainfo  path in the specified .ini.file = "C:\wamp64\bin\php v7.2/v7.3\php.ini and phpforApache.ini"


<a id="step4" name="step4"></a>
## <strong> 4: Setup the database</strong>

Login to your PHP My admin

<img alt="" src="https://lh4.googleusercontent.com/K6MiXBGrfpyEETjgBaFnR3U-RiAhLTc4CcjRRPcbw_Ja9cTXYHCEPZ-I4Wj3BRCYHcDB7qXYfa4WiDode6VoQLWanD5YofZ82PJAjc5OyE_ZPOFdrJD5NbhT5mbxVqxZEL1Mly54"  />
    
Create a new Database and User. Provide all access permission/privileges to the user. Link the user with the Database.

<a id="step5" name="step5"></a>
## <strong> 5: Install Faveo</strong>

Now you can install Faveo via [GUI](/docs/installation/installer/gui) Wizard or [CLI](/docs/installation/installer/cli)

<img alt="" src="https://lh3.googleusercontent.com/yHw8zPGTJLU_O55r62SRo5zLI5G8KL6tbyVna1QnAtYWxJJXgTlU_vhTHddZiUXlHcigNRMfz-Q4fCuEhmb376lsBBqwahqCPT5gXyHJdU626iAAqSRqzau5Yn0d0eligNX14rlW"  />

<a id="step6" name="step6"></a>
## <strong> 6: Configure cron job</strong>

The cron job is used to perform background tasks such as sending emails and Recurring tickets, etc... 

In Windows, there is a task scheduler (Administrative Tools > Schedule Tasks). You open it by pressing Windows button + R and Type "taskschd.msc".

- To Setup a Schedule task for Faveo. Open Task scheduler and follow these steps
- Right-click on the Task scheduler and select “create basic task” and enter a name and click on the Next button.

<img alt="" src="https://lh5.googleusercontent.com/85Bx-59FUo7qnFcXIKCPGbHUbX8k2tDq3ph3hYr7KaCjkQM30TryEe6Dcmyy6-ioAtYFPOMWqHTe2OxteNrpLUBWwkAZUICIRb_F9jhT4X-pXolOl1eBzeqiCKnbH3f0PdUlB7wq"  />

Select the Task Running Triggered options Daily and click on the Next button.
     
<img alt="" src="https://lh3.googleusercontent.com/ULA5l6JU22FV1kl5oustcGXtQOE4PosVpWYk9-hzOncDmj8gtlsIL-1es_Sr2f1XJfcrdEj0bqdIA1-ZqVU1j1pH5pR5vpi3x7FkGZZ1X7qk2nHvP5rjy0ko6fIofs6j1kLk1K-f"  />

You can specify the necessary details and click Next.

<img alt="" src="https://lh6.googleusercontent.com/LypgYNqzx8ThkvuKZLrCyOF2U-_8XCF_hjGuOlSIDsYFdyLgoEQkBvwFCG6o0mM6pPGvrnpAG6zYl08FIbVET7hgAP8fbrK1sQHBto-fp5BkEyVwBCbAsql9LgItW1fHrv8Xc1hc"  />
     
**In program/script field enter the following value:**

```
C:\Windows\System32\cmd.exe 
```

**Add the following value in Argument:**

```
/c php "c:\inetpub\wwwroot\faveo\artisan" schedule:run
```

<img alt="" src="https://lh3.googleusercontent.com/936E97noHmbaP3hbXWj460h-d9-6QAZ0MqFNpoAwTnKh1gKKaBqSsFyWeCDQ9FxfWSbSMwAgXcy3NljUptity3w7IHbXAfz5OFEGpAixLbcZ5gvrLKcN5yV_lqeg5MOrK0eMPLh8"  />

After that, the scheduled task would appear on the list. Right-click the task and go to Properties -> Triggers.

Select the schedule and click Edit and set the cron to run every 10 minutes. You can change according to your needs.

<img alt="" src="https://lh3.googleusercontent.com/lGingy0sd6r0yXp5lLmGT0-y4sjBB64Z2_Us__ikuG1RU3kz8v4qfGT4ULtn3Sng7ZAbUKFBf5uvgZ1-YXDi3BLR8I0YE2kEsTyDw7rY8Mt651J7_6VPymhBLvKFJ_h7XcAhziza"  />

<a id="step7" name="step7"></a>
## <strong> 7: Final step</strong>

The final step is to have fun with your newly created instance, which should be up and running to `http://localhost` or the domain you have configured Faveo with.
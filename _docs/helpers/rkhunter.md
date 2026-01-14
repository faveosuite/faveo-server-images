---
layout: single
type: docs
permalink: /docs/helpers/rkhunter/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-01-14
last_modified_by: Mohammad_Asif
toc: true
title: rkhunter Installation, Configuration & Alerting
---

<img src="https://www.rkhunter.dev/icons/rkhunter-main-col.png?resize=1024%2C341&ssl=1">

## Purpose

This document explains how rkhunter (`Rootkit Hunter`) is installed, configured, updated, and monitored on Linux servers using Google Chat alerts instead of email. The guide is written for both new engineers and experienced administrators, and is aligned with SOC 2 security monitoring expectations.

### What is rkhunter?

rkhunter is a host-based security tool that scans systems for:
- Known rootkits
- Backdoors
- Suspicious binaries
- Unsafe permissions
- Signs of local compromise

It performs read-only checks and does not modify system files, making it safe for production servers.

### Environment Assumptions

- OS: Ubuntu / Debian (steps are similar for RHEL-based systems)
- Root or sudo access
- Internet access for signature updates
- Google Chat Webhook URL available

## Step 1: Installation
```
apt update
apt install -y rkhunter curl jq
```

- `curl` is required to fetch signature updates
- `jq` is required to safely format JSON payloads for Google Chat

## Step 2: Fix Update Errors (Important)

### Problem Observed
During update, the following error occurred:
```
Invalid WEB_CMD configuration option: Relative pathname: "/bin/false"
```

And updates failed:
- programs_bad.dat
- backdoorports.dat
- suspscan.dat

### Root Cause

By default, some distributions set:
```
WEB_CMD=/bin/false
```
This disables all external downloads, which prevents rkhunter from updating its signatures.

## Step 3: Correct Configuration

Edit the configuration file:
```
nano /etc/rkhunter.conf
```
Ensure the following values are set:
```
WEB_CMD=/usr/bin/curl
UPDATE_MIRRORS=0
MIRRORS_MODE=0
```

### Explanation

| Option                  | Meaning                                                             |
| ----------------------- | ------------------------------------------------------------------- |
| `WEB_CMD=/usr/bin/curl` | Allows rkhunter to securely download signature and data updates     |
| `UPDATE_MIRRORS=0`      | Prevents automatic modification of mirror lists (ensures stability) |
| `MIRRORS_MODE=0`        | Uses static mirror configuration (audit-friendly & predictable)     |


These settings are recommended for controlled enterprise environments.

## Step 4: Update rkhunter Signatures

```
rkhunter --update
```

Expected output:
- Signature files updated successfully
- No update failures

Logs:
```
/var/log/rkhunter.log
```

## Step 5: Initialize Baseline (Property Database)

```
rkhunter --propupd
```

### Why this is required

This command records:
- File hashes
- Permissions
- Ownership

These values are used as a trusted baseline for future scans.

> ⚠️ Run this only on a clean, trusted system.

## Step 6: Manual Scan Test
```
rkhunter --check
```
or (non-interactive):

```
rkhunter --check --sk
```

Warnings (if any) will be logged but not emailed.

## Step 6: Manual Scan Test
rkhunter --check

or (non-interactive):

rkhunter --check --sk

Warnings (if any) will be logged but not emailed.

## Step 7: Google Chat Alerting (Instead of Email)
Create the alert script:
```
nano /usr/local/bin/rkhunter-check.sh
```
Alerting Script

```
#!/bin/bash

HOSTNAME=$(hostname)
DATE=$(date)
LOGFILE="/var/log/rkhunter.log"
WEBHOOK_URL="YOUR_GOOGLE_CHAT_WEBHOOK_URL"

# Run scan quietly
/usr/bin/rkhunter --check --cronjob --report-warnings-only

# Check if warnings exist
grep -q "Warning:" "$LOGFILE" || exit 0

SUMMARY=$(grep "Warning:" "$LOGFILE" | head -n 20)

MESSAGE=$(cat <<EOF
🚨 *rkhunter Security Alert*

*Host:* $HOSTNAME
*Date:* $DATE

*Warnings Detected:*
\`\`\`
$SUMMARY
\`\`\`

📄 Full log:
$LOGFILE
EOF
)

curl -s -X POST \
  -H 'Content-Type: application/json' \
  -d "$(jq -nc --arg text "$MESSAGE" '{text: $text}')" \
  "$WEBHOOK_URL"
```

Make it executable:
```
chmod +x /usr/local/bin/rkhunter-check.sh
```

## Step 8: Test Alerting
```
/usr/local/bin/rkhunter-check.sh
```
Expected Behavior
- If no warnings → no alert sent
- If warnings exist → Google Chat message is delivered

## Step 9: Schedule via Cron
```
crontab -e
```
Example (daily scan at 03:30 AM):
```
30 3 * * * /usr/local/bin/rkhunter-check.sh
```

### Logs & Monitoring

| File / Component        | Purpose                                       |
| ----------------------- | --------------------------------------------- |
| `/var/log/rkhunter.log` | Stores scan results, warnings, and audit logs |
| Cron Job                | Executes automated daily rkhunter scans       |
| Google Chat             | Sends real-time security alerts to SOC team   |


### SOC 2 Alignment

| Control | Coverage                                    |
| ------- | ------------------------------------------- |
| CC7.1   | Continuous host security monitoring         |
| CC7.2   | Detection of unauthorized changes & malware |
| CC7.3   | Centralized alerting and incident response  |

---


<div style="display: flex; align-items: center;">
    <a href="https://1.gravatar.com/avatar/c0d70118d1dcf472a3b428453e49e1723127a1d83d8aeb4fb9d7b53a15860d13?size=512">
        <img src="https://1.gravatar.com/avatar/c0d70118d1dcf472a3b428453e49e1723127a1d83d8aeb4fb9d7b53a15860d13?size=128" alt="Author Image" style="border-radius: 50%; width: 50px; height: 50px; margin-right: 10px;">
    </a>
    <div style="text-align: left;">
        <div style="line-height: 1;">Authored by:</div>
      <div style="line-height: 1;"> <b>Mohammad Asif</b> </div>
			<div style="line-height: 1;">Associate DevOps Engineer</div>
    </div>
</div
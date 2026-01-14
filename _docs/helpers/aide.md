---
layout: single
type: docs
permalink: /docs/helpers/aide/
redirect_from:
  - /theme-setup/
last_modified_at: 2025-01-14
last_modified_by: Mohammad_Asif
toc: true
title: AIDE – File Integrity Monitoring (SOC 2 Compliant
---

<img src="https://linuxaarif.wordpress.com/wp-content/uploads/2013/04/aide_logo.gif?w=200">

## 1. Purpose
This document explains how AIDE is configured, monitored, and alerted across all Linux servers.

The goal is to:
- Detect unauthorized file changes
- Identify possible system compromise
- Provide tamper detection evidence
- Meet SOC 2 file integrity and monitoring controls

## 2. What is AIDE?
AIDE (Advanced Intrusion Detection Environment) is a file integrity monitoring (FIM) tool.

It works in two phases:

**1.Baseline Creation**
A snapshot of important system files is taken and stored securely.

**2. Integrity Checks**
Future scans compare current files against the baseline.

If any file is:
- Modified
- Deleted
- Added
- Permission-changed

AIDE raises an alert.

> ⚠️ AIDE does not prevent attacks. It detects and reports them.
{.is-info}

## 3. SOC 2 Control Mapping

| SOC 2 Control | Coverage                            |
| ------------- | ----------------------------------- |
| CC6.1         | Detect unauthorized changes         |
| CC6.6         | Protect system configurations       |
| CC7.2         | Detect and alert on security events |


## 4. Architecture Overview

```
[AIDE Scan]
     |
     v
[Local Log File]
     |
     v
[Google Chat Alert (Summary)]
     |
     v
[Engineer Reviews Full Log]
```

Key Design Decisions

- No email alerting (avoids spam & mail misconfig)
- Google Chat used for real-time visibility
- Full logs stored locally for forensic analysis

## 5. Installation
**Ubuntu / Debian**
```
apt update
apt install aide -y
```

**RHEL / AlmaLinux / Rocky Linux**
```
dnf install aide -y
```

## 6. Initial AIDE Setup

### 6.1 Create Secure Database Directory
```
mkdir -p /var/lib/aide
chmod 700 /var/lib/aide
```

### 6.2 Configure AIDE
Edit configuration file:
```
nano /etc/aide/aide.conf
```
Ensure database paths exist:
```
database_in=file:/var/lib/aide/aide.db
database_out=file:/var/lib/aide/aide.db.new
database_new=file:/var/lib/aide/aide.db.new
```

### 6.3 Laravel-Specific Exclusions
Laravel applications generate frequent file changes.

Add exclusions for each Laravel project:
```
!/var/www/html/*/storage
!/var/www/html/*/bootstrap/cache
!/var/www/html/*/storage/logs
!/var/www/html/*/storage/framework
```
```
# === AIDE internal ===
/var/lib/aide Full
/var/log/aide Full

# === CORE SYSTEM PROTECTION ===
/etc        Full
/bin        Full
/sbin       Full
/usr/bin    Full
/usr/sbin   Full
/lib        Full
/lib64      Full
/boot       Full
/var/lib/dpkg Full
```
> This prevents false alerts and unnecessary noise. Your Document root may be different, set it accordingly.


## 7. Baseline Database Creation (One-Time)

Run only after server is fully configured and trusted
```
aide --config /etc/aide/aide.conf --init
```

After completion:
```
mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
chmod 600 /var/lib/aide/aide.db
```

This establishes the trusted baseline.

## 8. Manual Integrity Check
```
aide --config /etc/aide/aide.conf --check
```

Possible outcomes:

- No output → No changes
- Differences found → Review required

## 9. Google Chat Alerting
### 9.1 Why Google Chat Instead of Email?
| Reason             | Benefit                |
| ------------------ | ---------------------- |
| Large logs         | Avoid mail size limits |
| Real-time alerts   | Faster response        |
| Central visibility | Team awareness         |
| SOC 2 friendly     | Summary + evidence     |


### 9.2 Alert Script

Create Script
```
nano /usr/local/bin/aide-check.sh
```

```
#!/bin/bash

HOSTNAME=$(hostname)
DATE=$(date)
AIDE="/usr/bin/aide"
CONF="/etc/aide/aide.conf"
LOG="/var/log/aide/aide.log"
TMP="/tmp/aide-alert.txt"

WEBHOOK_URL="YOUR_GOOGLE_CHAT_WEBHOOK_URL"

mkdir -p /var/log/aide

$AIDE --config $CONF --check > "$LOG" 2>&1

# Extract real changes (Debian format)
sed -n '
/^Start timestamp/,/^End timestamp/{
/^File: /p
/added$/p
/removed$/p
/changed$/p
}' "$LOG" > "$TMP"

[ -s "$TMP" ] || exit 0

MESSAGE=$(cat <<EOF
🚨 *AIDE Integrity Alert*

*Host:* $HOSTNAME
*Date:* $DATE

*Detected Changes:*
\`\`\`
$(head -n 60 "$TMP")
\`\`\`

📄 Full report:
$LOG
EOF
)

curl -s -X POST \
  -H 'Content-Type: application/json' \
  -d "$(jq -nc --arg text "$MESSAGE" '{text:$text}')" \
  "$WEBHOOK_URL"

rm -f "$TMP"
```

Secure the script:
```
chmod 750 /usr/local/bin/aide-check.sh
chown root:root /usr/local/bin/aide-check.sh
```

## 10. Automated Daily Scan (Cron)
Edit root crontab:
```
crontab -e
```

Add:

```
0 4 * * * /usr/local/bin/aide-check.sh
```
- Runs daily at 4 AM
- Alerts only on changes
- No alert fatigue

## 11. Handling Legitimate Changes
After verified system updates:
```
aide --config /etc/aide/aide.conf --update
mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
chmod 600 /var/lib/aide/aide.db
```
Never update baseline without review.

## 12. Logs & Evidence
| Item      | Location                       |
| --------- | ------------------------------ |
| AIDE Logs | `/var/log/aide/aide.log`       |
| Database  | `/var/lib/aide/aide.db`        |
| Script    | `/usr/local/bin/aide-check.sh` |
| Alerts    | Google Chat Security Channel   |


## 13. Resource Usage

| Tool | CPU        | RAM       | Notes        |
| ---- | ---------- | --------- | ------------ |
| AIDE | Burst only | 50–150 MB | During scans |





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
</div>

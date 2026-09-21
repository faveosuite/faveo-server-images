---
layout: single
type: docs
permalink: /docs/installation/providers/enterprise/setup-self-healing/
redirect_from:
  - /theme-setup/
last_modified_at: 2026-09-21
last_modified_by: Sivakumar C
toc: true
title: Self-Healing Setup Script
---

<img alt="Troubleshoot" src="self-healing-shield.svg" width="200"  />


# How to Set Up the Self-Healing Script

`Self-Healing Script` sets up a background watchdog on your server that
keeps an eye on your services (nginx, MySQL/MariaDB, Redis, PHP-FPM,
Supervisor jobs, and more). If one crashes or stops responding, it
automatically restarts it - retrying a few times before giving up - and
notifies you on Slack, Google Chat, and/or email if it can't recover on its
own. It also keeps a rotated log of everything it does, warns you before a
disk fills up, and shows a health summary banner every time you log in.

Below are step-by-step instructions to get it running on your server.

---

## Table of Contents

- [Step 1: Make sure you're on a supported OS](#step-1-make-sure-youre-on-a-supported-os)
- [Step 2: Get the script onto your server](#step-2-get-the-script-onto-your-server)
- [Step 3: Make it executable](#step-3-make-it-executable)
- [Step 4: Run it as root](#step-4-run-it-as-root)
- [Step 5: Confirm it installed correctly](#step-5-confirm-it-installed-correctly)
- [Step 6: Watch it work (optional)](#step-6-watch-it-work-optional)
- [Step 7: Log out and back in](#step-7-log-out-and-back-in)
- [Alternative: Skip the questions with flags](#alternative-skip-the-questions-with-flags)
  - [Full list of options](#full-list-of-options)
- [Preview before committing (optional)](#preview-before-committing-optional)
- [Adding another app later](#adding-another-app-later)
- [Removing it](#removing-it)

---

## Step 1: Make sure you're on a supported OS

- Debian / Ubuntu, **or**
- RHEL / CentOS / Fedora / AlmaLinux / Rocky

## Step 2: Get the script onto your server

```bash
wget https://raw.githubusercontent.com/faveosuite/faveo-server-images/master/scripts/self-healing-scritps/setup-self-healing.sh
```
Make sure `setup-self-healing.sh` is on the server you want to protect, e.g.:

```bash
ls -la setup-self-healing.sh
```

## Step 3: Make it executable

```bash
chmod +x setup-self-healing.sh
```

## Step 4: Run it as root

```bash
sudo ./setup-self-healing.sh
```

Running it with **no options** starts **interactive mode** - it will ask you
questions one at a time and you just press Enter to accept the defaults
shown in brackets.

You'll be asked, in order:

1. **Extra services to monitor** - anything not auto-detected (press Enter
   to skip).
2. **Slack webhook URL** - for alerts (press Enter to skip).
3. **Google Chat webhook URL** - for alerts (press Enter to skip).
4. **Email address** - for alerts (press Enter to skip).
   - If you skip all three, it will ask you to confirm you really want no
     alerts at all.
5. **From address** for email alerts (only if you gave an email).
6. **Restart attempts before giving up** - default `3`.
7. **Delay between restart attempts** - default `30` seconds.
8. **Poll interval when healthy** - default `30` seconds.
9. **Cooldown between repeat "still down" alerts** - default `1800`
   seconds (30 min).
10. **Enable disk space monitoring?** - default Yes.
    - If yes: which folders to watch, and the warning/critical/emergency
      usage percentages.
11. Finally, it lists every **currently running service** it detected
    (nginx, MySQL, Redis, PHP-FPM, etc.) and asks **Yes/No for each one**
    whether to enable self-healing on it.

At the end it shows a summary before making any changes.

## Step 5: Confirm it installed correctly

```bash
systemctl status self-healing-watchdog.service
```

You should see it listed as `active (running)`.

## Step 6: Watch it work (optional)

```bash
tail -f /var/log/self-healing/events.log
```

This shows live health checks, restarts, and recoveries as they happen.

## Step 7: Log out and back in

You'll now see a server health banner automatically every time you log in,
showing service status, CPU, memory, disk usage, and watchdog heartbeat.

---

## Alternative: Skip the questions with flags

If you already know what you want, run it with options instead and it
won't ask anything:

```bash
sudo ./setup-self-healing.sh \
  --services "myapp" \
  --slack-webhook "https://hooks.slack.com/services/..." \
  --email-to "you@example.com"
```

### Full list of options

| Option | What it does |
|---|---|
| `--services "svc1,svc2"` | Also monitor these services even if not auto-detected |
| `--slack-webhook URL` | Send alerts to a Slack channel |
| `--googlechat-webhook URL` | Send alerts to a Google Chat space |
| `--email-to ADDR` | Send alerts to an email address |
| `--email-from ADDR` | "From" address for email alerts |
| `--http-check "svc=URL"` | Health-check a service by hitting a URL instead of the default check |
| `--tcp-check "svc=PORT"` | Health-check a service by testing a port instead of the default check |
| `--max-attempts N` | How many restarts to try before giving up (default: 3) |
| `--retry-delay SECONDS` | Wait time between restart attempts (default: 30) |
| `--check-interval SECONDS` | How often to check services when healthy (default: 30) |
| `--cooldown SECONDS` | Minimum time between repeat "still down" alerts (default: 1800 = 30 min) |
| `--no-disk-check` | Turn off disk space monitoring entirely |
| `--disk-mounts "/,/data"` | Which folders to watch for disk space (default: `/`) |
| `--disk-warn PCT` | Warning threshold, % used (default: 80) |
| `--disk-critical PCT` | Critical threshold, % used (default: 90) |
| `--disk-emergency PCT` | Emergency threshold, % used (default: 95) |
| `--disk-cooldown SECONDS` | How often to repeat an unresolved disk alert (default: 1800) |
| `--dry-run` | Show what it *would* do, without changing anything |
| `--uninstall` | Remove everything the script installed |
| `-h`, `--help` | Show built-in help text |

## Preview before committing (optional)

To see exactly what the script *would* do without changing anything:

```bash
sudo ./setup-self-healing.sh --dry-run
```

---

## Adding another app later

Run the script again - it merges changes instead of overwriting:

```bash
sudo ./setup-self-healing.sh --services "myapp"
```

Or edit `/etc/self-healing/services.conf` directly, then:

```bash
sudo systemctl restart self-healing-watchdog.service
```

## Removing it

```bash
sudo ./setup-self-healing.sh --uninstall
```
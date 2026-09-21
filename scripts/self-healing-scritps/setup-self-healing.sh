#!/usr/bin/env bash
#
# setup-self-healing.sh
#
# Self-healing, monitoring, and alerting for Linux services + Supervisor jobs.
# Works on Debian/Ubuntu and RHEL/CentOS/Fedora/AlmaLinux/Rocky.
#
# WHAT THIS INSTALLS
#   1. A persistent watchdog daemon (systemd service, Restart=always) that
#      polls every service (and every Supervisor job) on a fixed interval.
#   2. A scripted recovery routine: on detecting a stopped/crashed/unhealthy
#      service it restarts it, waits, and health-checks - up to 3 attempts,
#      30 seconds apart (configurable). After each attempt it logs the
#      outcome. If all attempts fail, it stops retrying and sends a
#      notification (Slack, Google Chat, and/or Email) with service name,
#      server name, attempts made, status, and error detail.
#   3. Automatic recovery detection: once a previously-failing service is
#      seen healthy again, its restart counter and give-up state reset, so
#      the next failure gets a fresh 3 attempts.
#   4. Supervisor integration: every job known to `supervisorctl status` is
#      monitored and healed the same way (supervisorctl restart, not
#      systemctl).
#   5. A full event log (checks, restart attempts, recoveries, failures).
#   6. logrotate config so the event log doesn't grow unbounded.
#   7. A login MOTD banner showing service + resource health.
#   8. Disk space monitoring (`df -h`) on configured mountpoints: WARNING at
#      80% used, CRITICAL at 90%, EMERGENCY at 95% (all thresholds are
#      configurable). Alerts repeat every 30 minutes (configurable) as long
#      as usage stays at/above a threshold, and a RESOLVED notice is sent
#      once usage drops back below the warning threshold. This check is
#      read-only monitoring only - the script never deletes files, logs, or
#      anything else to free up space.
#   9. --uninstall to cleanly remove everything.
#
# USAGE
#   sudo ./setup-self-healing.sh [options]
#
# OPTIONS
#   --services "svc1,svc2"        Extra services to manage (comma separated,
#                                  systemd unit name without .service), even
#                                  if currently inactive.
#   --http-check "svc=URL"        Health check a service over HTTP instead of
#                                  the default (repeatable).
#   --tcp-check "svc=PORT"        Health check a service over TCP instead of
#                                  the default (repeatable).
#   --slack-webhook URL           Slack incoming webhook URL for alerts.
#   --googlechat-webhook URL      Google Chat incoming webhook URL for alerts.
#   --email-to ADDR               Email address to notify (requires a mail
#                                  transport; script attempts to install one).
#   --email-from ADDR             From address for email alerts (optional).
#   --max-attempts N               Restart attempts before giving up (default 3)
#   --retry-delay SECONDS         Delay between restart attempts, and before
#                                  the post-restart health check (default 30)
#   --check-interval SECONDS      How often the daemon polls each service
#                                  when everything is healthy (default 30)
#   --cooldown SECONDS            Minimum seconds between repeat "still down"
#                                  notifications for the same service once
#                                  retries are exhausted (default 1800)
#   --no-disk-check                Disable disk space monitoring entirely.
#   --disk-mounts "/,/data"        Mountpoints to watch with `df -h` (default "/")
#   --disk-warn PCT                Warning threshold, percent used (default 80)
#   --disk-critical PCT            Critical threshold, percent used (default 90)
#   --disk-emergency PCT           Emergency threshold, percent used (default 95)
#   --disk-cooldown SECONDS        Repeat interval for an unresolved disk alert
#                                  at the same severity (default 1800 = 30 min)
#   --dry-run                     Show what would be done, change nothing.
#   --uninstall                   Remove all self-healing configuration.
#   -h, --help                    Show this help.
#
# You can re-run this script safely to add services or change notification
# settings; existing config is merged, not clobbered.
#
# FILES
#   /etc/self-healing/config.conf     - notification + tuning settings
#   /etc/self-healing/services.conf   - name:checktype:target per service
#   /var/lib/self-healing/            - per-service attempt/give-up state
#   /var/log/self-healing/events.log  - event log (rotated)
#
# CHECK STATUS
#   systemctl status self-healing-watchdog.service

# Color variables (ANSI codes with escaped octal for portability)
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
blue='\033[1;34m'
cyan='\033[1;36m'
reset='\033[0m'
bold='\033[1m'


# Get terminal width directly from the shell.
# COLUMNS is preferred when available; otherwise use tput.
if [[ -n "${COLUMNS:-}" && "$COLUMNS" =~ ^[0-9]+$ ]]; then
    TERM_WIDTH=$COLUMNS
else
    TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
fi

# Minimum sane terminal width
(( TERM_WIDTH > 0 )) || TERM_WIDTH=80

# Banner
BANNER=$(cat <<'EOF'
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
EOF
)

# Find the widest line using Bash only.
BANNER_WIDTH=0

while IFS= read -r LINE; do
    LINE_WIDTH=${#LINE}

    if (( LINE_WIDTH > BANNER_WIDTH )); then
        BANNER_WIDTH=$LINE_WIDTH
    fi
done <<< "$BANNER"

# Calculate ONE padding value for the entire banner.
if (( TERM_WIDTH > BANNER_WIDTH )); then
    PADDING=$(( (TERM_WIDTH - BANNER_WIDTH) / 2 ))
else
    PADDING=0
fi

# Create indentation using Bash printf.
INDENT=$(printf '%*s' "$PADDING" '')

# Print banner.
printf '%b\n' "${cyan}${bold}"

while IFS= read -r LINE; do
    printf '%s%s\n' "$INDENT" "$LINE"
done <<< "$BANNER"

printf '%b\n' "${reset}"

set -Eeuo pipefail

SCRIPT_VERSION="1.0.0"

CONF_DIR="/etc/self-healing"
CONFIG_FILE="${CONF_DIR}/config.conf"
SERVICES_FILE="${CONF_DIR}/services.conf"

BASE_DIR="/var/lib/self-healing"
STATE_DIR="${BASE_DIR}/state"
HEARTBEAT_FILE="${BASE_DIR}/heartbeat"
LOCK_DIR="${BASE_DIR}/locks"

LOG_DIR="/var/log/self-healing"
LOG_FILE="${LOG_DIR}/events.log"

NOTIFIER_SCRIPT="/usr/local/bin/self-healing-notify.sh"
WATCHDOG_SCRIPT="/usr/local/bin/self-healing-watchdog.sh"
WATCHDOG_SERVICE="/etc/systemd/system/self-healing-watchdog.service"
LOGROTATE_FILE="/etc/logrotate.d/self-healing"
MOTD_PATH="/etc/profile.d/99-server-health.sh"

BACKUP_DIR="${BASE_DIR}/backup/$(date +%Y%m%d-%H%M%S)"

DEFAULT_SERVICES=(
    nginx apache2 httpd mariadb mysqld mysql redis-server redis
    supervisor
    php-fpm php7.4-fpm php8.0-fpm php8.1-fpm php8.2-fpm php8.3-fpm php8.4-fpm php8.5-fpm
    meilisearch cron crond
)

# Sensible default TCP health-check ports, applied only when the user has
# not supplied --tcp-check/--http-check and there is no prior override.
declare -A DEFAULT_TCP_PORT=(
    [apache2]=80 [httpd]=80 [nginx]=80
    [mysql]=3306 [mysqld]=3306 [mariadb]=3306
    [redis-server]=6379 [redis]=6379
    [meilisearch]=7700
)

# ---------------------------------------------------------------------------
# CLI defaults / arg parsing
# ---------------------------------------------------------------------------

EXTRA_SERVICES=""
declare -A HTTP_OVERRIDES=()
declare -A TCP_OVERRIDES=()
SLACK_WEBHOOK=""
GOOGLECHAT_WEBHOOK=""
EMAIL_TO=""
EMAIL_FROM=""
MAX_ATTEMPTS="3"
RETRY_DELAY="30"
CHECK_INTERVAL="30"
COOLDOWN_SECONDS="1800"
DISK_CHECK_ENABLED="1"
DISK_MOUNTPOINTS="/"
DISK_WARN_PCT="80"
DISK_CRITICAL_PCT="90"
DISK_EMERGENCY_PCT="95"
DISK_COOLDOWN_SECONDS="1800"
DRY_RUN="0"
UNINSTALL="0"

ARGS_PROVIDED=$#

usage() {
    sed -n '2,/^set -Eeuo/p' "$0" | sed '$d' | sed 's/^#//; s/^ //'
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --services) EXTRA_SERVICES="$2"; shift 2 ;;
        --http-check)
            key="${2%%=*}"; val="${2#*=}"
            HTTP_OVERRIDES["${key}"]="${val}"
            shift 2 ;;
        --tcp-check)
            key="${2%%=*}"; val="${2#*=}"
            TCP_OVERRIDES["${key}"]="${val}"
            shift 2 ;;
        --slack-webhook) SLACK_WEBHOOK="$2"; shift 2 ;;
        --googlechat-webhook) GOOGLECHAT_WEBHOOK="$2"; shift 2 ;;
        --email-to) EMAIL_TO="$2"; shift 2 ;;
        --email-from) EMAIL_FROM="$2"; shift 2 ;;
        --max-attempts) MAX_ATTEMPTS="$2"; shift 2 ;;
        --retry-delay) RETRY_DELAY="$2"; shift 2 ;;
        --check-interval) CHECK_INTERVAL="$2"; shift 2 ;;
        --cooldown) COOLDOWN_SECONDS="$2"; shift 2 ;;
        --no-disk-check) DISK_CHECK_ENABLED="0"; shift ;;
        --disk-mounts) DISK_MOUNTPOINTS="$2"; shift 2 ;;
        --disk-warn) DISK_WARN_PCT="$2"; shift 2 ;;
        --disk-critical) DISK_CRITICAL_PCT="$2"; shift 2 ;;
        --disk-emergency) DISK_EMERGENCY_PCT="$2"; shift 2 ;;
        --disk-cooldown) DISK_COOLDOWN_SECONDS="$2"; shift 2 ;;
        --dry-run) DRY_RUN="1"; shift ;;
        --uninstall) UNINSTALL="1"; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

log()   { echo "[INFO]  $1"; }
warn()  { echo "[WARN]  $1" >&2; }
error() { echo "[ERROR] $1" >&2; }
die()   { error "$1"; exit 1; }

# ---------------------------------------------------------------------------
# Interactive mode - if invoked with no CLI options at all and connected to
# a terminal, ask for the settings instead of silently applying defaults.
# Non-interactive invocations (cron, CI, piped input) skip this and just
# use the defaults, so automation never hangs waiting on stdin.
# ---------------------------------------------------------------------------

prompt_for_config() {
    echo "No options supplied - interactive setup (press Enter to accept the default shown)."
    echo

    read -rp "Extra services to monitor, comma separated [none]: " reply
    EXTRA_SERVICES="${reply:-${EXTRA_SERVICES}}"

    # Ask for all three notification channels; if all three are left blank,
    # confirm explicitly rather than silently installing with no alerting.
    while true; do
        read -rp "Slack webhook URL for alerts [none, press Enter to skip]: " reply
        SLACK_WEBHOOK="${reply:-${SLACK_WEBHOOK}}"

        read -rp "Google Chat webhook URL for alerts [none, press Enter to skip]: " reply
        GOOGLECHAT_WEBHOOK="${reply:-${GOOGLECHAT_WEBHOOK}}"

        read -rp "Email address for alerts [none, press Enter to skip]: " reply
        EMAIL_TO="${reply:-${EMAIL_TO}}"

        if [[ -z "${SLACK_WEBHOOK}" && -z "${GOOGLECHAT_WEBHOOK}" && -z "${EMAIL_TO}" ]]; then
            read -rp "No notification channel entered - alerts will not be sent anywhere. Continue without alerts? [y/N]: " reply
            case "${reply,,}" in
                y|yes) break ;;
                *) echo "Okay, let's set at least one channel (or confirm 'y' to skip)."; echo ;;
            esac
        else
            break
        fi
    done

    if [[ -n "${EMAIL_TO}" ]]; then
        read -rp "From address for email alerts [self-healing@<hostname>]: " reply
        EMAIL_FROM="${reply:-${EMAIL_FROM}}"
    fi

    read -rp "Restart attempts before giving up [${MAX_ATTEMPTS}]: " reply
    MAX_ATTEMPTS="${reply:-${MAX_ATTEMPTS}}"

    read -rp "Delay between restart attempts, seconds [${RETRY_DELAY}]: " reply
    RETRY_DELAY="${reply:-${RETRY_DELAY}}"

    read -rp "Poll interval when healthy, seconds [${CHECK_INTERVAL}]: " reply
    CHECK_INTERVAL="${reply:-${CHECK_INTERVAL}}"

    read -rp "Cooldown between repeat 'still down' alerts, seconds [${COOLDOWN_SECONDS}]: " reply
    COOLDOWN_SECONDS="${reply:-${COOLDOWN_SECONDS}}"

    echo
    read -rp "Enable disk space monitoring (df -h, alerts only - nothing is ever deleted)? [Y/n]: " reply
    case "${reply,,}" in
        n|no) DISK_CHECK_ENABLED="0" ;;
        *) DISK_CHECK_ENABLED="1" ;;
    esac

    if [[ "${DISK_CHECK_ENABLED}" == "1" ]]; then
        read -rp "Mountpoints to watch, comma separated [${DISK_MOUNTPOINTS}]: " reply
        DISK_MOUNTPOINTS="${reply:-${DISK_MOUNTPOINTS}}"

        read -rp "Warning threshold, percent used [${DISK_WARN_PCT}]: " reply
        DISK_WARN_PCT="${reply:-${DISK_WARN_PCT}}"

        read -rp "Critical threshold, percent used [${DISK_CRITICAL_PCT}]: " reply
        DISK_CRITICAL_PCT="${reply:-${DISK_CRITICAL_PCT}}"

        read -rp "Emergency threshold, percent used [${DISK_EMERGENCY_PCT}]: " reply
        DISK_EMERGENCY_PCT="${reply:-${DISK_EMERGENCY_PCT}}"

        read -rp "Repeat interval for an unresolved disk alert, seconds [${DISK_COOLDOWN_SECONDS}]: " reply
        DISK_COOLDOWN_SECONDS="${reply:-${DISK_COOLDOWN_SECONDS}}"
    fi

    echo
    log "Using: services=[${EXTRA_SERVICES:-none}] slack=[${SLACK_WEBHOOK:+set}] googlechat=[${GOOGLECHAT_WEBHOOK:+set}] email=[${EMAIL_TO:-none}] max-attempts=${MAX_ATTEMPTS} retry-delay=${RETRY_DELAY}s check-interval=${CHECK_INTERVAL}s cooldown=${COOLDOWN_SECONDS}s"
    if [[ "${DISK_CHECK_ENABLED}" == "1" ]]; then
        log "Disk monitoring: mounts=[${DISK_MOUNTPOINTS}] warn=${DISK_WARN_PCT}% critical=${DISK_CRITICAL_PCT}% emergency=${DISK_EMERGENCY_PCT}% repeat=${DISK_COOLDOWN_SECONDS}s"
    else
        log "Disk monitoring: disabled"
    fi
    echo
}

INTERACTIVE="0"
if [[ "${ARGS_PROVIDED}" -eq 0 && -t 0 ]]; then
    INTERACTIVE="1"
    prompt_for_config
fi

run() {
    # Executes a command unless --dry-run, in which case it is only printed.
    if [[ "${DRY_RUN}" == "1" ]]; then
        echo "  [dry-run] $*"
    else
        "$@"
    fi
}

trap 'error "Failed at line $LINENO (exit $?). Check ${LOG_FILE} if it exists."' ERR

# ---------------------------------------------------------------------------
# Root check
# ---------------------------------------------------------------------------

[[ "${EUID}" -eq 0 ]] || die "This script must be run as root."

echo
echo "============================================================"
echo " Self-Healing Installer v${SCRIPT_VERSION}"
echo "============================================================"
echo

# ---------------------------------------------------------------------------
# OS / package manager detection
# ---------------------------------------------------------------------------

detect_os() {
    [[ -f /etc/os-release ]] || die "/etc/os-release not found."
    # shellcheck disable=SC1091
    source /etc/os-release
    local os_id="${ID:-}" os_like="${ID_LIKE:-}"

    if [[ "${os_id}" =~ ^(debian|ubuntu)$ || "${os_like}" =~ debian ]]; then
        OS_FAMILY="debian"
        PKG_INSTALL=(apt-get install -y)
        PKG_UPDATE=(apt-get update -y)
        MAIL_PKG="mailutils"
    elif [[ "${os_id}" =~ ^(rhel|centos|fedora|almalinux|rocky|ol)$ || "${os_like}" =~ (rhel|fedora) ]]; then
        OS_FAMILY="rhel"
        if command -v dnf >/dev/null 2>&1; then
            PKG_INSTALL=(dnf install -y)
            PKG_UPDATE=(dnf makecache)
        else
            PKG_INSTALL=(yum install -y)
            PKG_UPDATE=(yum makecache)
        fi
        MAIL_PKG="mailx"
    else
        die "Unsupported OS. Supported: Debian/Ubuntu and RHEL-based families."
    fi

    OS_NAME="${PRETTY_NAME:-${os_id}}"
    log "Operating system: ${OS_NAME} (family: ${OS_FAMILY})"
}

detect_os

command -v systemctl >/dev/null 2>&1 || die "systemctl is required."
command -v flock >/dev/null 2>&1 || die "flock is required (util-linux)."

ensure_pkg() {
    local bin="$1" pkg="$2"
    command -v "${bin}" >/dev/null 2>&1 && return 0
    log "Installing missing dependency: ${pkg}"
    if [[ "${DRY_RUN}" == "1" ]]; then
        echo "  [dry-run] ${PKG_INSTALL[*]} ${pkg}"
        return 0
    fi
    "${PKG_UPDATE[@]}" >/dev/null 2>&1 || true
    "${PKG_INSTALL[@]}" "${pkg}" || warn "Could not install ${pkg}; related features may not work."
}

ensure_pkg curl curl

# ---------------------------------------------------------------------------
# Uninstall path
# ---------------------------------------------------------------------------

if [[ "${UNINSTALL}" == "1" ]]; then
    log "Uninstalling self-healing configuration..."

    run systemctl disable --now self-healing-watchdog.service 2>/dev/null || true
    run rm -f "${WATCHDOG_SERVICE}"
    run rm -f "${NOTIFIER_SCRIPT}" "${WATCHDOG_SCRIPT}"
    run rm -f "${MOTD_PATH}" "${LOGROTATE_FILE}"
    run systemctl daemon-reload || true

    echo
    log "Uninstall complete. Config/state left in place for reference:"
    log "  ${CONF_DIR}"
    log "  ${BASE_DIR}"
    log "  ${LOG_DIR}"
    log "Remove those manually if you want a fully clean system."
    exit 0
fi

# ---------------------------------------------------------------------------
# Directories
# ---------------------------------------------------------------------------

log "Creating directories..."
run mkdir -p "${CONF_DIR}" "${STATE_DIR}" "${LOCK_DIR}" "${LOG_DIR}" "${BASE_DIR}/backup"
run touch "${LOG_FILE}" "${HEARTBEAT_FILE}"
run chmod 755 "${CONF_DIR}" "${BASE_DIR}" "${STATE_DIR}" "${LOCK_DIR}" "${LOG_DIR}"
run chmod 640 "${LOG_FILE}"

# ---------------------------------------------------------------------------
# Config file (merge, don't clobber, on re-run)
# ---------------------------------------------------------------------------

if [[ -f "${CONFIG_FILE}" ]]; then
    # shellcheck disable=SC1090
    source "${CONFIG_FILE}"
fi

SLACK_WEBHOOK="${SLACK_WEBHOOK:-${EXISTING_SLACK_WEBHOOK:-}}"
GOOGLECHAT_WEBHOOK="${GOOGLECHAT_WEBHOOK:-${EXISTING_GOOGLECHAT_WEBHOOK:-}}"
EMAIL_TO="${EMAIL_TO:-${EXISTING_EMAIL_TO:-}}"
EMAIL_FROM="${EMAIL_FROM:-${EXISTING_EMAIL_FROM:-self-healing@$(hostname -f 2>/dev/null || hostname)}}"

log "Writing ${CONFIG_FILE}..."
if [[ "${DRY_RUN}" != "1" ]]; then
    cat > "${CONFIG_FILE}" <<EOF
# Managed by setup-self-healing.sh - edit and re-run script, or edit directly.
EXISTING_SLACK_WEBHOOK="${SLACK_WEBHOOK}"
EXISTING_GOOGLECHAT_WEBHOOK="${GOOGLECHAT_WEBHOOK}"
EXISTING_EMAIL_TO="${EMAIL_TO}"
EXISTING_EMAIL_FROM="${EMAIL_FROM}"
MAX_ATTEMPTS="${MAX_ATTEMPTS}"
RETRY_DELAY="${RETRY_DELAY}"
CHECK_INTERVAL="${CHECK_INTERVAL}"
COOLDOWN_SECONDS="${COOLDOWN_SECONDS}"
DISK_CHECK_ENABLED="${DISK_CHECK_ENABLED}"
DISK_MOUNTPOINTS="${DISK_MOUNTPOINTS}"
DISK_WARN_PCT="${DISK_WARN_PCT}"
DISK_CRITICAL_PCT="${DISK_CRITICAL_PCT}"
DISK_EMERGENCY_PCT="${DISK_EMERGENCY_PCT}"
DISK_COOLDOWN_SECONDS="${DISK_COOLDOWN_SECONDS}"
EOF
    chmod 640 "${CONFIG_FILE}"
fi

if [[ -n "${EMAIL_TO}" ]]; then
    ensure_pkg mail "${MAIL_PKG}"
fi

# ---------------------------------------------------------------------------
# Discover services - only currently-active ones are auto-monitored;
# anything passed via --services is added regardless of current state.
# ---------------------------------------------------------------------------

service_exists() {
    systemctl list-unit-files "$1.service" >/dev/null 2>&1 || systemctl cat "$1.service" >/dev/null 2>&1
}

resolve_service() {
    service_exists "$1" || return 1
    systemctl show "$1.service" --property=Id --value 2>/dev/null
}

declare -A FOUND=()

log "Detecting installed + active services..."
for candidate in "${DEFAULT_SERVICES[@]}"; do
    service_exists "${candidate}" || continue
    resolved="$(resolve_service "${candidate}" || true)"
    [[ -z "${resolved}" ]] && continue
    resolved="${resolved%.service}"
    systemctl is-active --quiet "${resolved}.service" 2>/dev/null || continue
    FOUND["${resolved}"]=1
done

if [[ -n "${EXTRA_SERVICES}" ]]; then
    IFS=',' read -ra EXTRA_ARR <<< "${EXTRA_SERVICES}"
    for candidate in "${EXTRA_ARR[@]}"; do
        candidate="$(echo "${candidate}" | xargs)"
        [[ -z "${candidate}" ]] && continue
        service_exists "${candidate}" || { warn "Skipping --services ${candidate}: not installed."; continue; }
        resolved="$(resolve_service "${candidate}" || true)"
        [[ -z "${resolved}" ]] && continue
        FOUND["${resolved%.service}"]=1
    done
fi

# De-duplicate common aliases
[[ -n "${FOUND[mariadb]+x}" ]] && { unset 'FOUND[mysql]'; unset 'FOUND[mysqld]'; }
[[ -n "${FOUND[redis-server]+x}" ]] && unset 'FOUND[redis]'
[[ -n "${FOUND[apache2]+x}" ]] && unset 'FOUND[httpd]'
[[ -n "${FOUND[cron]+x}" ]] && unset 'FOUND[crond]'

MONITORED_SERVICES=()
while IFS= read -r svc; do
    [[ -n "${svc}" ]] && MONITORED_SERVICES+=("${svc}")
done < <(printf '%s\n' "${!FOUND[@]}" | sort)

if [[ "${#MONITORED_SERVICES[@]}" -eq 0 ]]; then
    warn "No active supported services detected. Framework will still be installed."
elif [[ "${INTERACTIVE}" == "1" ]]; then
    echo
    log "Found these active services - choose which to self-heal:"
    CONFIRMED_SERVICES=()
    for svc in "${MONITORED_SERVICES[@]}"; do
        read -rp "  ${svc} (running) - add self-healing for this service? [Y/n]: " reply
        case "${reply,,}" in
            n|no) log "    skipping ${svc}" ;;
            *) CONFIRMED_SERVICES+=("${svc}") ;;
        esac
    done
    MONITORED_SERVICES=("${CONFIRMED_SERVICES[@]}")
    echo
else
    log "Managing services:"
    for s in "${MONITORED_SERVICES[@]}"; do echo "  -> ${s}"; done
fi

# ---------------------------------------------------------------------------
# Supervisor jobs - discovered via supervisorctl, monitored the same way
# ---------------------------------------------------------------------------

SUPERVISOR_JOBS=()
if printf '%s\n' "${MONITORED_SERVICES[@]}" | grep -qx supervisor && command -v supervisorctl >/dev/null 2>&1; then
    log "Detecting Supervisor jobs..."
    while read -r line; do
        [[ -z "${line}" ]] && continue
        job="$(awk '{print $1}' <<< "${line}")"
        [[ -n "${job}" ]] && SUPERVISOR_JOBS+=("${job}")
    done < <(supervisorctl status 2>/dev/null || true)
    if [[ "${#SUPERVISOR_JOBS[@]}" -gt 0 ]]; then
        log "Found Supervisor jobs:"
        for j in "${SUPERVISOR_JOBS[@]}"; do echo "  -> ${j}"; done
    else
        warn "Supervisor is active but no jobs were returned by 'supervisorctl status'."
    fi
fi

# ---------------------------------------------------------------------------
# Build services.conf (name:checktype:target), preserving prior overrides
# format: name:checktype:target
#   checktype: none | tcp | http | supervisor
#   for checktype=supervisor, target is the supervisorctl program name
# ---------------------------------------------------------------------------

declare -A PRIOR_CHECK=()
if [[ -f "${SERVICES_FILE}" ]]; then
    while IFS=: read -r n t v; do
        [[ -z "${n}" || "${n}" == \#* ]] && continue
        PRIOR_CHECK["${n}"]="${t}:${v}"
    done < "${SERVICES_FILE}"
fi

log "Writing ${SERVICES_FILE}..."
SERVICES_TMP="$(mktemp)"
{
    echo "# Managed by setup-self-healing.sh"
    echo "# format: service_name:checktype:target   (checktype: none|tcp|http|supervisor)"
    echo "# Add lines manually for custom apps, e.g.:"
    echo "#   myapp:tcp:8080"
    echo "#   myapp:http:http://127.0.0.1:8080/health"
    for svc in "${MONITORED_SERVICES[@]}"; do
        checktype="none"; target=""
        if [[ -n "${HTTP_OVERRIDES[${svc}]+x}" ]]; then
            checktype="http"; target="${HTTP_OVERRIDES[${svc}]}"
        elif [[ -n "${TCP_OVERRIDES[${svc}]+x}" ]]; then
            checktype="tcp"; target="${TCP_OVERRIDES[${svc}]}"
        elif [[ -n "${PRIOR_CHECK[${svc}]+x}" ]]; then
            IFS=: read -r checktype target <<< "${PRIOR_CHECK[${svc}]}"
        elif [[ -n "${DEFAULT_TCP_PORT[${svc}]+x}" ]]; then
            checktype="tcp"; target="${DEFAULT_TCP_PORT[${svc}]}"
        fi
        echo "${svc}:${checktype}:${target}"
    done
    for job in "${SUPERVISOR_JOBS[@]}"; do
        echo "${job}:supervisor:${job}"
    done
} > "${SERVICES_TMP}"

if [[ "${DRY_RUN}" != "1" ]]; then
    mv "${SERVICES_TMP}" "${SERVICES_FILE}"
    chmod 644 "${SERVICES_FILE}"
else
    cat "${SERVICES_TMP}"; rm -f "${SERVICES_TMP}"
fi

# ---------------------------------------------------------------------------
# Backup prior state (informational)
# ---------------------------------------------------------------------------

run mkdir -p "${BACKUP_DIR}"
if [[ -f "${SERVICES_FILE}" ]]; then
    cp -a "${SERVICES_FILE}" "${BACKUP_DIR}/" 2>/dev/null || true
fi

# ---------------------------------------------------------------------------
# Notifier script - Slack + Google Chat + Email
# ---------------------------------------------------------------------------

log "Installing ${NOTIFIER_SCRIPT}..."
if [[ "${DRY_RUN}" != "1" ]]; then
cat > "${NOTIFIER_SCRIPT}" <<'EOF'
#!/usr/bin/env bash
# Usage: self-healing-notify.sh <service> <status> <attempts> <error-detail...>
set -Eeuo pipefail

SERVICE_NAME="${1:-unknown}"
STATUS="${2:-DOWN}"
ATTEMPTS="${3:-0}"
shift 3 || true
ERROR_DETAIL="${*:-no additional detail captured}"

CONFIG_FILE="/etc/self-healing/config.conf"
STATE_DIR="/var/lib/self-healing/state"
LOG_FILE="/var/log/self-healing/events.log"
HOSTNAME_FQDN="$(hostname -f 2>/dev/null || hostname)"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S %Z')"

[[ -f "${CONFIG_FILE}" ]] && source "${CONFIG_FILE}"
COOLDOWN_SECONDS="${COOLDOWN_SECONDS:-1800}"
DISK_COOLDOWN_SECONDS="${DISK_COOLDOWN_SECONDS:-1800}"
case "${STATUS}" in
    DISK_*) ACTIVE_COOLDOWN="${DISK_COOLDOWN_SECONDS}" ;;
    *)      ACTIVE_COOLDOWN="${COOLDOWN_SECONDS}" ;;
esac
# Keyed by status too, so a RECOVERED notification is never suppressed by
# the cooldown of the DOWN notification that preceded it (or vice versa).
NOTIFY_FLAG="${STATE_DIR}/${SERVICE_NAME}.${STATUS,,}.last_notify"
NOW="$(date +%s)"

mkdir -p "${STATE_DIR}"
touch "${LOG_FILE}"

LAST=0
[[ -f "${NOTIFY_FLAG}" ]] && LAST="$(<"${NOTIFY_FLAG}")"
[[ "${LAST}" =~ ^[0-9]+$ ]] || LAST=0

# RECOVERED/DISK_RECOVERED are one-time transitions, not repeat spam, so
# they are never cooldown-suppressed - they must always get through so
# they can clear the prior alert's cooldown below. Only repeated "still
# down"/"still over threshold" alerts get throttled (every ACTIVE_COOLDOWN
# seconds, e.g. every 30 minutes by default).
if [[ "${STATUS}" != "RECOVERED" && "${STATUS}" != "DISK_RECOVERED" ]] && (( NOW - LAST < ACTIVE_COOLDOWN )); then
    echo "[${TIMESTAMP}] Notification for ${SERVICE_NAME} (${STATUS}) suppressed (cooldown active)." >> "${LOG_FILE}"
    exit 0
fi

case "${STATUS}" in
    RECOVERED|DISK_RECOVERED)
        HEADER="RESOLVED"
        STATUS_EMOJI="✅"
        ;;
    DISK_WARNING)
        HEADER="WARNING"
        STATUS_EMOJI="⚠️"
        ;;
    DISK_CRITICAL)
        HEADER="CRITICAL"
        STATUS_EMOJI="🔴"
        ;;
    DISK_EMERGENCY)
        HEADER="EMERGENCY"
        STATUS_EMOJI="🚨"
        ;;
    *)
        HEADER="CRITICAL"
        STATUS_EMOJI="❌"
        ;;
esac

MSG="${STATUS_EMOJI} ${HEADER}: *${SERVICE_NAME}* on *${HOSTNAME_FQDN}*
Status: *${STATUS}*
Restart attempts: ${ATTEMPTS}
Time: ${TIMESTAMP}
Detail: ${ERROR_DETAIL}"

echo "[${TIMESTAMP}] NOTIFY ${SERVICE_NAME}: status=${STATUS} attempts=${ATTEMPTS}" >> "${LOG_FILE}"

SENT=0

if [[ -n "${EXISTING_SLACK_WEBHOOK:-}" ]] && command -v curl >/dev/null 2>&1; then
    PAYLOAD="$(printf '{"text":"%s"}' "${MSG//\"/\\\"}" | sed ':a;N;$!ba;s/\n/\\n/g')"
    if curl -fsS -m 5 -X POST -H 'Content-type: application/json' \
        --data "${PAYLOAD}" "${EXISTING_SLACK_WEBHOOK}" >/dev/null 2>&1; then
        SENT=1
    else
        echo "[${TIMESTAMP}] Slack notification failed for ${SERVICE_NAME}." >> "${LOG_FILE}"
    fi
fi

if [[ -n "${EXISTING_GOOGLECHAT_WEBHOOK:-}" ]] && command -v curl >/dev/null 2>&1; then
    PAYLOAD="$(printf '{"text":"%s"}' "${MSG//\"/\\\"}" | sed ':a;N;$!ba;s/\n/\\n/g')"
    if curl -fsS -m 5 -X POST -H 'Content-type: application/json; charset=UTF-8' \
        --data "${PAYLOAD}" "${EXISTING_GOOGLECHAT_WEBHOOK}" >/dev/null 2>&1; then
        SENT=1
    else
        echo "[${TIMESTAMP}] Google Chat notification failed for ${SERVICE_NAME}." >> "${LOG_FILE}"
    fi
fi

if [[ -n "${EXISTING_EMAIL_TO:-}" ]] && command -v mail >/dev/null 2>&1; then
    if echo "${MSG}" | mail -s "[self-healing] ${STATUS_EMOJI} ${SERVICE_NAME} on ${HOSTNAME_FQDN} - ${STATUS}" \
        ${EXISTING_EMAIL_FROM:+-r "${EXISTING_EMAIL_FROM}"} "${EXISTING_EMAIL_TO}" 2>/dev/null; then
        SENT=1
    else
        echo "[${TIMESTAMP}] Email notification failed for ${SERVICE_NAME}." >> "${LOG_FILE}"
    fi
fi

if [[ "${SENT}" == "1" ]]; then
    echo "${NOW}" > "${NOTIFY_FLAG}"
    # A confirmed recovery closes out the incident that the last DOWN alert
    # was about - clear its cooldown so the *next* distinct failure always
    # alerts, instead of possibly being silently swallowed by a cooldown
    # window left over from an outage that has already been resolved.
    if [[ "${STATUS}" == "RECOVERED" ]]; then
        rm -f "${STATE_DIR}/${SERVICE_NAME}.down.last_notify"
    elif [[ "${STATUS}" == "DISK_RECOVERED" ]]; then
        rm -f "${STATE_DIR}/${SERVICE_NAME}.disk_warning.last_notify" \
              "${STATE_DIR}/${SERVICE_NAME}.disk_critical.last_notify" \
              "${STATE_DIR}/${SERVICE_NAME}.disk_emergency.last_notify"
    fi
else
    echo "[${TIMESTAMP}] No notification channel configured/succeeded for ${SERVICE_NAME}." >> "${LOG_FILE}"
fi
exit 0
EOF
chmod 755 "${NOTIFIER_SCRIPT}"
fi

# ---------------------------------------------------------------------------
# Watchdog daemon - owns detection, restart retries, and recovery/give-up
# state for both systemd services and Supervisor jobs.
# ---------------------------------------------------------------------------

log "Installing ${WATCHDOG_SCRIPT}..."
if [[ "${DRY_RUN}" != "1" ]]; then
cat > "${WATCHDOG_SCRIPT}" <<'EOF'
#!/usr/bin/env bash
# Persistent self-healing watchdog daemon.
#
# Every CHECK_INTERVAL seconds, every configured service/Supervisor job is
# health-checked. On failure the watchdog itself performs up to MAX_ATTEMPTS
# restarts, RETRY_DELAY seconds apart, health-checking after each one. If
# every attempt fails it stops retrying and fires a notification; the next
# time the service is observed healthy its state resets so a future failure
# gets a fresh set of attempts.
set -Eeuo pipefail

CONFIG_FILE="/etc/self-healing/config.conf"
SERVICES_FILE="/etc/self-healing/services.conf"
STATE_DIR="/var/lib/self-healing/state"
LOCK_DIR="/var/lib/self-healing/locks"
HEARTBEAT_FILE="/var/lib/self-healing/heartbeat"
LOG_FILE="/var/log/self-healing/events.log"
NOTIFIER="/usr/local/bin/self-healing-notify.sh"
HOSTNAME_FQDN="$(hostname -f 2>/dev/null || hostname)"

[[ -f "${CONFIG_FILE}" ]] && source "${CONFIG_FILE}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"
RETRY_DELAY="${RETRY_DELAY:-30}"
CHECK_INTERVAL="${CHECK_INTERVAL:-30}"
DISK_CHECK_ENABLED="${DISK_CHECK_ENABLED:-1}"
DISK_MOUNTPOINTS="${DISK_MOUNTPOINTS:-/}"
DISK_WARN_PCT="${DISK_WARN_PCT:-80}"
DISK_CRITICAL_PCT="${DISK_CRITICAL_PCT:-90}"
DISK_EMERGENCY_PCT="${DISK_EMERGENCY_PCT:-95}"

mkdir -p "${STATE_DIR}" "${LOCK_DIR}"
touch "${LOG_FILE}"

logline() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "${LOG_FILE}"
}

# --- health / control primitives -------------------------------------------

check_tcp() {
    timeout 3 bash -c "exec 3<>/dev/tcp/127.0.0.1/$1" 2>/dev/null
}

check_http() {
    curl -fsS -o /dev/null -m 5 "$1" 2>/dev/null
}

is_healthy() {
    local name="$1" checktype="$2" target="$3"
    case "${checktype}" in
        supervisor)
            supervisorctl status "${target}" 2>/dev/null | awk '{print $2}' | grep -qx RUNNING
            ;;
        *)
            systemctl is-active --quiet "${name}.service" 2>/dev/null || return 1
            case "${checktype}" in
                tcp)  check_tcp "${target}" ;;
                http) check_http "${target}" ;;
                *) return 0 ;;
            esac
            ;;
    esac
}

restart_unit() {
    local name="$1" checktype="$2" target="$3"
    if [[ "${checktype}" == "supervisor" ]]; then
        supervisorctl restart "${target}" >/dev/null 2>&1
    else
        systemctl restart "${name}.service" >/dev/null 2>&1
    fi
}

error_detail() {
    local name="$1" checktype="$2" target="$3"
    if [[ "${checktype}" == "supervisor" ]]; then
        supervisorctl status "${target}" 2>&1 | tr '\n' ' '
    else
        local sub result
        sub="$(systemctl show "${name}.service" --property=SubState --value 2>/dev/null)"
        result="$(systemctl show "${name}.service" --property=Result --value 2>/dev/null)"
        local jlines
        jlines="$(journalctl -u "${name}.service" -n 5 --no-pager -o cat 2>/dev/null | tr '\n' ' | ')"
        echo "substate=${sub:-unknown} result=${result:-unknown} recent_log: ${jlines:-none}"
    fi
}

# --- disk space monitoring --------------------------------------------------
# Read-only: this only checks `df -h` and notifies. It never deletes files,
# rotates logs, or frees space on its own.

disk_key() {
    # Turn a mountpoint into a safe token for state filenames / notifier
    # "service name", e.g. "/" -> "disk-root", "/data" -> "disk-data".
    local mp="${1#/}"
    mp="${mp//\//-}"
    [[ -z "${mp}" ]] && mp="root"
    echo "disk-${mp}"
}

check_disk_usage() {
    local mount="$1"
    local key; key="$(disk_key "${mount}")"
    local state_file="${STATE_DIR}/${key}.state"
    local lock_file="${LOCK_DIR}/${key}.lock"

    (
        flock -x 200

        local used total pct
        read -r used total pct <<< "$(df -hP "${mount}" 2>/dev/null | awk 'NR==2{gsub("%","",$5); print $3,$2,$5}')"
        if [[ ! "${pct}" =~ ^[0-9]+$ ]]; then
            logline "DISK CHECK ${mount}: unable to read usage via df -h (bad mountpoint?)"
            return 0
        fi

        local level="OK"
        if (( pct >= DISK_EMERGENCY_PCT )); then
            level="EMERGENCY"
        elif (( pct >= DISK_CRITICAL_PCT )); then
            level="CRITICAL"
        elif (( pct >= DISK_WARN_PCT )); then
            level="WARNING"
        fi

        local prev_level="OK"
        [[ -f "${state_file}" ]] && prev_level="$(<"${state_file}")"

        logline "DISK CHECK ${mount}: ${pct}% used (${used}/${total}), level=${level}"

        if [[ "${level}" == "OK" ]]; then
            if [[ "${prev_level}" != "OK" ]]; then
                echo "OK" > "${state_file}"
                logline "DISK RECOVERED ${mount}: back to ${pct}% used, below ${DISK_WARN_PCT}% warning threshold"
                "${NOTIFIER}" "${key}" "DISK_RECOVERED" "-" \
                    "Disk usage on ${mount} (${HOSTNAME_FQDN}) is now ${pct}% used (${used}/${total}), below the ${DISK_WARN_PCT}% warning threshold" || true
            fi
            return 0
        fi

        echo "${level}" > "${state_file}"
        # Re-notify every check; the notifier's own DISK_COOLDOWN_SECONDS
        # (default 1800s/30min) throttles this to one actual alert per
        # window per severity level, same pattern as service DOWN alerts.
        "${NOTIFIER}" "${key}" "DISK_${level}" "-" \
            "Disk usage on ${mount} (${HOSTNAME_FQDN}) is ${pct}% used (${used}/${total}) - threshold ${level,,}: warn=${DISK_WARN_PCT}% critical=${DISK_CRITICAL_PCT}% emergency=${DISK_EMERGENCY_PCT}%" || true
    ) 200>"${lock_file}"
}

# --- per-service handling ---------------------------------------------------

handle_unit() {
    local name="$1" checktype="$2" target="$3"
    local state_file="${STATE_DIR}/${name}.state"
    local lock_file="${LOCK_DIR}/${name}.lock"

    (
        flock -x 200

        local attempts=0 given_up=0
        if [[ -f "${state_file}" ]]; then
            attempts="$(grep -m1 '^attempts=' "${state_file}" 2>/dev/null | cut -d= -f2)"
            given_up="$(grep -m1 '^given_up=' "${state_file}" 2>/dev/null | cut -d= -f2)"
        fi
        [[ "${attempts}" =~ ^[0-9]+$ ]] || attempts=0
        [[ "${given_up}" =~ ^[01]$ ]] || given_up=0

        if is_healthy "${name}" "${checktype}" "${target}"; then
            logline "CHECK ${name}: OK"
            if [[ "${attempts}" != "0" || "${given_up}" == "1" ]]; then
                local was_given_up="${given_up}"
                attempts=0; given_up=0
                { echo "attempts=${attempts}"; echo "given_up=${given_up}"; } > "${state_file}"
                logline "RECOVERED ${name}: healthy again, restart counter reset"
                if [[ "${was_given_up}" == "1" ]]; then
                    "${NOTIFIER}" "${name}" "RECOVERED" "0/${MAX_ATTEMPTS}" "Service is healthy again (recovered on its own or was fixed manually) after previously exhausting all restart attempts" || true
                fi
            fi
            return 0
        fi

        logline "CHECK ${name}: FAILED (${checktype}:${target})"

        if [[ "${given_up}" == "1" ]]; then
            logline "SKIP ${name}: retries already exhausted, waiting for it to recover or be fixed manually"
            # Still down - re-notify. The notifier's own cooldown (COOLDOWN_SECONDS,
            # default 1800s/30min) throttles this to one actual alert per window
            # and logs "suppressed" for the rest, so this is safe to call every cycle.
            "${NOTIFIER}" "${name}" "DOWN" "${attempts}/${MAX_ATTEMPTS}" "$(error_detail "${name}" "${checktype}" "${target}")" || true
            return 0
        fi

        local ok=0
        while (( attempts < MAX_ATTEMPTS )); do
            attempts=$((attempts + 1))
            { echo "attempts=${attempts}"; echo "given_up=0"; } > "${state_file}"
            logline "RESTART ${name}: attempt ${attempts}/${MAX_ATTEMPTS}"
            restart_unit "${name}" "${checktype}" "${target}"
            sleep "${RETRY_DELAY}"
            if is_healthy "${name}" "${checktype}" "${target}"; then
                ok=1
                logline "RECOVERED ${name}: healthy after restart attempt ${attempts}/${MAX_ATTEMPTS}"
                attempts=0; given_up=0
                { echo "attempts=${attempts}"; echo "given_up=${given_up}"; } > "${state_file}"
                break
            else
                logline "RESTART ${name}: attempt ${attempts}/${MAX_ATTEMPTS} did not bring it healthy - $(error_detail "${name}" "${checktype}" "${target}")"
            fi
        done

        if [[ "${ok}" != "1" ]]; then
            given_up=1
            { echo "attempts=${attempts}"; echo "given_up=${given_up}"; } > "${state_file}"
            local detail
            detail="$(error_detail "${name}" "${checktype}" "${target}")"
            logline "GIVEUP ${name}: exhausted ${MAX_ATTEMPTS} restart attempts, notifying"
            "${NOTIFIER}" "${name}" "DOWN" "${attempts}/${MAX_ATTEMPTS}" "${detail}" || true
        fi
    ) 200>"${lock_file}"
}

# --- main loop ---------------------------------------------------------------

[[ -f "${SERVICES_FILE}" ]] || { logline "No ${SERVICES_FILE} found, watchdog idling"; }

while true; do
    date +%s > "${HEARTBEAT_FILE}"
    if [[ -f "${SERVICES_FILE}" ]]; then
        pids=()
        while IFS=: read -r name checktype target; do
            [[ -z "${name}" || "${name}" == \#* ]] && continue
            handle_unit "${name}" "${checktype}" "${target}" &
            pids+=($!)
        done < "${SERVICES_FILE}"
        for pid in "${pids[@]:-}"; do
            [[ -n "${pid}" ]] && wait "${pid}" 2>/dev/null || true
        done
    fi

    if [[ "${DISK_CHECK_ENABLED}" == "1" ]]; then
        disk_pids=()
        IFS=',' read -ra _DISK_MOUNTS <<< "${DISK_MOUNTPOINTS}"
        for mount in "${_DISK_MOUNTS[@]}"; do
            mount="$(echo "${mount}" | xargs)"
            [[ -z "${mount}" ]] && continue
            check_disk_usage "${mount}" &
            disk_pids+=($!)
        done
        for pid in "${disk_pids[@]:-}"; do
            [[ -n "${pid}" ]] && wait "${pid}" 2>/dev/null || true
        done
    fi

    sleep "${CHECK_INTERVAL}"
done
EOF
chmod 755 "${WATCHDOG_SCRIPT}"
fi

log "Installing watchdog systemd service..."
if [[ "${DRY_RUN}" != "1" ]]; then
cat > "${WATCHDOG_SERVICE}" <<EOF
[Unit]
Description=Self-Healing Watchdog (services + Supervisor jobs)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=${WATCHDOG_SCRIPT}
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
chmod 644 "${WATCHDOG_SERVICE}"
fi

# ---------------------------------------------------------------------------
# logrotate
# ---------------------------------------------------------------------------

log "Installing logrotate config..."
if [[ "${DRY_RUN}" != "1" ]]; then
cat > "${LOGROTATE_FILE}" <<EOF
${LOG_FILE} {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 640 root root
}
EOF
chmod 644 "${LOGROTATE_FILE}"
fi

# ---------------------------------------------------------------------------
# MOTD banner
# ---------------------------------------------------------------------------

log "Installing MOTD at ${MOTD_PATH}..."
if [[ "${DRY_RUN}" != "1" ]]; then
cat > "${MOTD_PATH}" <<'EOF'
#!/usr/bin/env bash
case $- in *i*) ;; *) exit 0 ;; esac

BASE_DIR="/var/lib/self-healing"
STATE_DIR="${BASE_DIR}/state"
HEARTBEAT_FILE="${BASE_DIR}/heartbeat"
SERVICES_FILE="/etc/self-healing/services.conf"
CONFIG_FILE="/etc/self-healing/config.conf"
[[ -f "${CONFIG_FILE}" ]] && source "${CONFIG_FILE}"
DISK_CHECK_ENABLED="${DISK_CHECK_ENABLED:-1}"
DISK_MOUNTPOINTS="${DISK_MOUNTPOINTS:-/}"
DISK_WARN_PCT="${DISK_WARN_PCT:-80}"
DISK_CRITICAL_PCT="${DISK_CRITICAL_PCT:-90}"
DISK_EMERGENCY_PCT="${DISK_EMERGENCY_PCT:-95}"

echo ""
echo "==================================================================="
echo " SERVER HEALTH & SELF-HEALING"
echo "==================================================================="

LOAD="$(uptime 2>/dev/null | awk -F'load average:' '{print $2}' | xargs || true)"
MEM_INFO="$(free -m 2>/dev/null | awk '/^Mem:/{used=$3; total=$2; pct=(total>0)?used*100/total:0; printf "%d %d %d", used, total, pct}')"
read -r MEM_USED MEM_TOTAL MEM_PCT <<< "${MEM_INFO:-0 0 0}"
OS_INFO="$(awk -F= '/^PRETTY_NAME=/{gsub(/"/,"",$2);print $2;exit}' /etc/os-release 2>/dev/null)"

echo " OS: ${OS_INFO:-unknown}"
echo " CPU Load: ${LOAD:-N/A}"
echo " Memory: ${MEM_USED}MB / ${MEM_TOTAL}MB (${MEM_PCT}% used)"

if [[ "${DISK_CHECK_ENABLED}" == "1" ]]; then
    IFS=',' read -ra _MOTD_MOUNTS <<< "${DISK_MOUNTPOINTS}"
    for _mp in "${_MOTD_MOUNTS[@]}"; do
        _mp="$(echo "${_mp}" | xargs)"
        [[ -z "${_mp}" ]] && continue
        DISK_INFO="$(df -hP "${_mp}" 2>/dev/null | awk 'NR==2{gsub("%","",$5); print $3,$2,$5}')"
        read -r DISK_USED DISK_TOTAL DISK_PCT <<< "${DISK_INFO:-? ? 0}"
        if [[ "${DISK_PCT}" =~ ^[0-9]+$ ]]; then
            if (( DISK_PCT >= DISK_EMERGENCY_PCT )); then
                echo " Disk ${_mp}: ${DISK_USED} / ${DISK_TOTAL} (${DISK_PCT}% used) - [EMERGENCY]"
            elif (( DISK_PCT >= DISK_CRITICAL_PCT )); then
                echo " Disk ${_mp}: ${DISK_USED} / ${DISK_TOTAL} (${DISK_PCT}% used) - [CRITICAL]"
            elif (( DISK_PCT >= DISK_WARN_PCT )); then
                echo " Disk ${_mp}: ${DISK_USED} / ${DISK_TOTAL} (${DISK_PCT}% used) - [WARNING]"
            else
                echo " Disk ${_mp}: ${DISK_USED} / ${DISK_TOTAL} (${DISK_PCT}% used)"
            fi
        else
            echo " Disk ${_mp}: unable to read usage"
        fi
    done
else
    DISK_INFO="$(df -hP / 2>/dev/null | awk 'NR==2{printf "%s %s %s", $3,$2,$5}')"
    read -r DISK_USED DISK_TOTAL DISK_PCT <<< "${DISK_INFO:-? ? ?}"
    echo " Root Disk: ${DISK_USED} / ${DISK_TOTAL} (${DISK_PCT} used) - disk monitoring disabled"
fi

if [[ -f "${HEARTBEAT_FILE}" ]]; then
    NOW="$(date +%s)"
    LAST="$(<"${HEARTBEAT_FILE}")"
    [[ "${LAST}" =~ ^[0-9]+$ ]] || LAST=0
    AGE=$((NOW - LAST))
    if (( AGE > 300 )); then
        echo " Watchdog heartbeat: STALE (${AGE}s old) - self-healing watchdog may be down!"
    else
        echo " Watchdog heartbeat: OK (${AGE}s ago)"
    fi
else
    echo " Watchdog heartbeat: not found"
fi

echo ""
echo " --- Monitored Services / Jobs ---"
if [[ -f "${SERVICES_FILE}" ]]; then
    found=0
    while IFS=: read -r svc checktype target; do
        [[ -z "${svc}" || "${svc}" == \#* ]] && continue
        found=1
        attempts=0; given_up=0
        state_file="${STATE_DIR}/${svc}.state"
        if [[ -f "${state_file}" ]]; then
            attempts="$(grep -m1 '^attempts=' "${state_file}" 2>/dev/null | cut -d= -f2)"
            given_up="$(grep -m1 '^given_up=' "${state_file}" 2>/dev/null | cut -d= -f2)"
        fi
        [[ "${attempts}" =~ ^[0-9]+$ ]] || attempts=0
        [[ "${given_up}" =~ ^[01]$ ]] || given_up=0
        if [[ "${checktype}" == "supervisor" ]]; then
            status_line="$(supervisorctl status "${target}" 2>/dev/null | awk '{print $2}')"
            [[ "${status_line}" == "RUNNING" ]] && ok=1 || ok=0
        else
            systemctl is-active --quiet "${svc}.service" 2>/dev/null && ok=1 || ok=0
        fi
        if [[ "${given_up}" == "1" ]]; then
            echo " [FAIL] ${svc} (check: ${checktype}) - retries exhausted, awaiting manual fix"
        elif [[ "${ok}" == "1" ]]; then
            echo " [ OK ] ${svc} (check: ${checktype})"
        else
            echo " [WARN] ${svc} (check: ${checktype}) - down, attempts so far: ${attempts}"
        fi
    done < "${SERVICES_FILE}"
    [[ "${found}" -eq 0 ]] && echo " No monitored services configured."
else
    echo " No monitored services configured."
fi
echo "==================================================================="
echo ""
EOF
chmod 755 "${MOTD_PATH}"
fi

# ---------------------------------------------------------------------------
# Reload, enable, validate
# ---------------------------------------------------------------------------

if [[ "${DRY_RUN}" == "1" ]]; then
    echo
    log "Dry run complete. No changes were made."
    exit 0
fi

log "Reloading systemd..."
systemctl daemon-reload

log "Validating generated unit..."
systemd-analyze verify "${WATCHDOG_SERVICE}" || \
    warn "systemd-analyze verify reported issues above - review before relying on this in production."

log "Enabling and starting watchdog..."
systemctl enable --now self-healing-watchdog.service
systemctl restart self-healing-watchdog.service

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo
echo "============================================================"
echo " Self-Healing Installation Complete"
echo "============================================================"
echo " OS:                ${OS_NAME}"
echo " Services managed:  ${#MONITORED_SERVICES[@]}"
for s in "${MONITORED_SERVICES[@]}"; do echo "   - ${s}"; done
if [[ "${#SUPERVISOR_JOBS[@]}" -gt 0 ]]; then
    echo " Supervisor jobs managed: ${#SUPERVISOR_JOBS[@]}"
    for j in "${SUPERVISOR_JOBS[@]}"; do echo "   - ${j}"; done
fi
echo " Restart policy:    ${MAX_ATTEMPTS} attempts, ${RETRY_DELAY}s apart, then notify + stop retrying"
echo " Poll interval:     ${CHECK_INTERVAL}s"
echo " Notify cooldown:   ${COOLDOWN_SECONDS}s per service (once retries are exhausted)"
if [[ "${DISK_CHECK_ENABLED}" == "1" ]]; then
    echo " Disk monitoring:   mounts=[${DISK_MOUNTPOINTS}] warn=${DISK_WARN_PCT}% critical=${DISK_CRITICAL_PCT}% emergency=${DISK_EMERGENCY_PCT}% repeat every ${DISK_COOLDOWN_SECONDS}s (read-only, never deletes anything)"
else
    echo " Disk monitoring:   disabled"
fi
echo " Slack configured:       $([[ -n "${SLACK_WEBHOOK}" ]] && echo yes || echo no)"
echo " Google Chat configured: $([[ -n "${GOOGLECHAT_WEBHOOK}" ]] && echo yes || echo no)"
echo " Email configured:       $([[ -n "${EMAIL_TO}" ]] && echo "yes (${EMAIL_TO})" || echo no)"
echo
echo " Config:    ${CONFIG_FILE}"
echo " Services:  ${SERVICES_FILE}  (edit to add checktype/target per app)"
echo " Event log: ${LOG_FILE}"
echo " Backup:    ${BACKUP_DIR}"
echo
echo " Useful commands:"
echo "   tail -f ${LOG_FILE}"
echo "   systemctl status self-healing-watchdog.service"
echo "   cat ${SERVICES_FILE}"
echo "   sudo ./setup-self-healing.sh --uninstall"
echo
echo " Add a custom app: edit ${SERVICES_FILE} directly, e.g.:"
echo "   myapp:http:http://127.0.0.1:8080/health"
echo " then run: systemctl restart self-healing-watchdog.service"
echo "============================================================"
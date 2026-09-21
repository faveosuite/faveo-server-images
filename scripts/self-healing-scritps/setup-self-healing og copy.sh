#!/usr/bin/env bash
#
# setup-self-healing.sh
#
# Production-grade self-healing, monitoring, and alerting for Linux services.
# Works on Debian/Ubuntu and RHEL/CentOS/Fedora/AlmaLinux/Rocky.
#
# WHAT THIS INSTALLS
#   1. systemd Restart=on-failure drop-ins for detected/configured services
#      (crash -> auto-restart, handled entirely by systemd, no custom loop)
#   2. A failure logger (ExecStopPost) that counts crashes per service
#   3. A rate-limited notifier (Slack webhook, Google Chat webhook, and/or
#      email) fired by systemd's OnFailure= once a service exhausts its
#      restart budget
#   4. An ACTIVE health-check watchdog (systemd timer, default 60s) that
#      TCP/HTTP-probes services that can be "up" per systemd but hung
#      (e.g. accepting no connections) and restarts + alerts on them too
#   5. A heartbeat so you can tell if the watchdog itself has died
#      (dead-man's-switch, surfaced in the MOTD banner)
#   6. logrotate config so the event log doesn't grow unbounded
#   7. A login MOTD banner showing service + resource health
#   8. --uninstall to cleanly remove everything and restore prior config
#
# USAGE
#   sudo ./setup-self-healing.sh [options]
#
# OPTIONS
#   --services "svc1,svc2"        Extra services to manage (comma separated,
#                                  systemd unit name without .service)
#   --http-check "svc=URL"        Add/override an HTTP health check for a
#                                  service, e.g. --http-check "nginx=http://127.0.0.1/health"
#                                  (repeatable)
#   --tcp-check "svc=PORT"        Add/override a TCP health check for a
#                                  service, e.g. --tcp-check "redis-server=6379"
#                                  (repeatable)
#   --slack-webhook URL           Slack incoming webhook URL for alerts
#   --googlechat-webhook URL      Google Chat incoming webhook URL for alerts
#   --email-to ADDR               Email address to notify (requires mail
#                                  transport; script attempts to install one)
#   --email-from ADDR             From address for email alerts (optional)
#   --cooldown SECONDS            Minimum seconds between repeat alerts for
#                                  the same service (default: 1800 / 30 min)
#   --interval SECONDS            Active health-check interval (default: 60)
#   --fail-threshold N            Consecutive failed health checks before the
#                                  watchdog restarts a service (default: 2)
#   --restart-burst N             Crash-restarts allowed within the restart
#                                  window before systemd gives up and marks
#                                  the service failed (default: 3)
#   --restart-window SECONDS      Rolling window for --restart-burst; once N
#                                  crashes happen inside this window, systemd
#                                  stops restarting and fires the failure
#                                  notification (default: 600 / 10 min)
#   --dry-run                     Show what would be done, change nothing
#   --uninstall                   Remove all self-healing configuration
#   -h, --help                    Show this help
#
# You can re-run this script safely to add services or change notification
# settings; existing config is merged, not clobbered.
#
# FILES
#   /etc/self-healing/config.conf     - notification + tuning settings
#   /etc/self-healing/services.conf   - name:checktype:target per service
#   /var/lib/self-healing/            - counters, state, heartbeat
#   /var/log/self-healing/events.log  - event log (rotated)

set -Eeuo pipefail

SCRIPT_VERSION="2.0.0"

CONF_DIR="/etc/self-healing"
CONFIG_FILE="${CONF_DIR}/config.conf"
SERVICES_FILE="${CONF_DIR}/services.conf"

BASE_DIR="/var/lib/self-healing"
COUNT_DIR="${BASE_DIR}/counts"
STATE_DIR="${BASE_DIR}/state"
HEARTBEAT_FILE="${BASE_DIR}/heartbeat"
LOCK_FILE="${BASE_DIR}/self-healing.lock"

LOG_DIR="/var/log/self-healing"
LOG_FILE="${LOG_DIR}/events.log"

LOGGER_SCRIPT="/usr/local/bin/self-healing-log-failure.sh"
NOTIFIER_SCRIPT="/usr/local/bin/self-healing-notify.sh"
WATCHDOG_SCRIPT="/usr/local/bin/self-healing-watchdog.sh"
NOTIFIER_UNIT="/etc/systemd/system/service-notifier@.service"
WATCHDOG_SERVICE="/etc/systemd/system/self-healing-watchdog.service"
WATCHDOG_TIMER="/etc/systemd/system/self-healing-watchdog.timer"
LOGROTATE_FILE="/etc/logrotate.d/self-healing"
MOTD_PATH="/etc/profile.d/99-server-health.sh"

BACKUP_DIR="${BASE_DIR}/backup/$(date +%Y%m%d-%H%M%S)"

DEFAULT_SERVICES=(
    nginx apache2 httpd mariadb mysqld mysql redis-server redis
    supervisor supervisord cron crond
    php-fpm php8.0-fpm php8.1-fpm php8.2-fpm php8.3-fpm php8.4-fpm php8.5-fpm
    postgresql sshd docker containerd 
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
COOLDOWN_SECONDS="1800"
CHECK_INTERVAL="60"
FAIL_THRESHOLD="2"
RESTART_BURST="3"
RESTART_WINDOW="600"
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
        --cooldown) COOLDOWN_SECONDS="$2"; shift 2 ;;
        --interval) CHECK_INTERVAL="$2"; shift 2 ;;
        --fail-threshold) FAIL_THRESHOLD="$2"; shift 2 ;;
        --restart-burst) RESTART_BURST="$2"; shift 2 ;;
        --restart-window) RESTART_WINDOW="$2"; shift 2 ;;
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
# Interactive mode — if invoked with no CLI options at all and connected to
# a terminal, ask for the settings instead of silently applying defaults.
# Non-interactive invocations (cron, CI, piped input) skip this and just
# use the defaults, so automation never hangs waiting on stdin.
# ---------------------------------------------------------------------------

prompt_for_config() {
    echo "No options supplied — interactive setup (press Enter to accept the default shown)."
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
            read -rp "No notification channel entered — alerts will not be sent anywhere. Continue without alerts? [y/N]: " reply
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

    read -rp "Cooldown between repeat alerts, seconds [${COOLDOWN_SECONDS}]: " reply
    COOLDOWN_SECONDS="${reply:-${COOLDOWN_SECONDS}}"

    read -rp "Active health-check interval, seconds [${CHECK_INTERVAL}]: " reply
    CHECK_INTERVAL="${reply:-${CHECK_INTERVAL}}"

    read -rp "Failed health checks before restart [${FAIL_THRESHOLD}]: " reply
    FAIL_THRESHOLD="${reply:-${FAIL_THRESHOLD}}"

    read -rp "Crash-restarts allowed before giving up, i.e. restart burst [${RESTART_BURST}]: " reply
    RESTART_BURST="${reply:-${RESTART_BURST}}"

    read -rp "Restart-burst rolling window, seconds [${RESTART_WINDOW}]: " reply
    RESTART_WINDOW="${reply:-${RESTART_WINDOW}}"

    echo
    log "Using: services=[${EXTRA_SERVICES:-none}] slack=[${SLACK_WEBHOOK:+set}] googlechat=[${GOOGLECHAT_WEBHOOK:+set}] email=[${EMAIL_TO:-none}] cooldown=${COOLDOWN_SECONDS}s interval=${CHECK_INTERVAL}s fail-threshold=${FAIL_THRESHOLD} restart-burst=${RESTART_BURST}/${RESTART_WINDOW}s"
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

    if [[ -f "${SERVICES_FILE}" ]]; then
        while IFS=: read -r svc _ _; do
            [[ -z "${svc}" || "${svc}" == \#* ]] && continue
            DROP_FILE="/etc/systemd/system/${svc}.service.d/self-healing.conf"
            if [[ -f "${DROP_FILE}" ]]; then
                run rm -f "${DROP_FILE}"
                log "Removed drop-in for ${svc}"
            fi
        done < "${SERVICES_FILE}"
    fi

    run rm -f "${NOTIFIER_UNIT}" "${WATCHDOG_SERVICE}" "${WATCHDOG_TIMER}"
    run rm -f "${LOGGER_SCRIPT}" "${NOTIFIER_SCRIPT}" "${WATCHDOG_SCRIPT}"
    run rm -f "${MOTD_PATH}" "${LOGROTATE_FILE}"
    run systemctl daemon-reload || true
    run systemctl reset-failed || true

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
run mkdir -p "${CONF_DIR}" "${COUNT_DIR}" "${STATE_DIR}" "${LOG_DIR}" "${BASE_DIR}/backup"
run touch "${LOG_FILE}" "${LOCK_FILE}" "${HEARTBEAT_FILE}"
run chmod 755 "${CONF_DIR}" "${BASE_DIR}" "${COUNT_DIR}" "${STATE_DIR}" "${LOG_DIR}"
run chmod 640 "${LOG_FILE}"
run chmod 600 "${LOCK_FILE}"

# ---------------------------------------------------------------------------
# Config file (merge, don't clobber, on re-run)
# ---------------------------------------------------------------------------

if [[ -f "${CONFIG_FILE}" ]]; then
    # shellcheck disable=SC1090
    source "${CONFIG_FILE}"
fi

SLACK_WEBHOOK="${SLACK_WEBHOOK:-${EXISTING_SLACK_WEBHOOK:-}}"
[[ -n "${SLACK_WEBHOOK}" ]] || SLACK_WEBHOOK="${EXISTING_SLACK_WEBHOOK:-}"
GOOGLECHAT_WEBHOOK="${GOOGLECHAT_WEBHOOK:-${EXISTING_GOOGLECHAT_WEBHOOK:-}}"
[[ -n "${GOOGLECHAT_WEBHOOK}" ]] || GOOGLECHAT_WEBHOOK="${EXISTING_GOOGLECHAT_WEBHOOK:-}"
EMAIL_TO="${EMAIL_TO:-${EXISTING_EMAIL_TO:-}}"
EMAIL_FROM="${EMAIL_FROM:-${EXISTING_EMAIL_FROM:-self-healing@$(hostname -f 2>/dev/null || hostname)}}"

log "Writing ${CONFIG_FILE}..."
if [[ "${DRY_RUN}" != "1" ]]; then
    cat > "${CONFIG_FILE}" <<EOF
# Managed by setup-self-healing.sh — edit and re-run script, or edit directly.
EXISTING_SLACK_WEBHOOK="${SLACK_WEBHOOK}"
EXISTING_GOOGLECHAT_WEBHOOK="${GOOGLECHAT_WEBHOOK}"
EXISTING_EMAIL_TO="${EMAIL_TO}"
EXISTING_EMAIL_FROM="${EMAIL_FROM}"
COOLDOWN_SECONDS="${COOLDOWN_SECONDS}"
CHECK_INTERVAL="${CHECK_INTERVAL}"
FAIL_THRESHOLD="${FAIL_THRESHOLD}"
RESTART_BURST="${RESTART_BURST}"
RESTART_WINDOW="${RESTART_WINDOW}"
EOF
    chmod 640 "${CONFIG_FILE}"
fi

if [[ -n "${EMAIL_TO}" ]]; then
    ensure_pkg mail "${MAIL_PKG}"
fi

# ---------------------------------------------------------------------------
# Discover services
# ---------------------------------------------------------------------------

service_exists() {
    systemctl list-unit-files "$1.service" >/dev/null 2>&1 || systemctl cat "$1.service" >/dev/null 2>&1
}

resolve_service() {
    service_exists "$1" || return 1
    systemctl show "$1.service" --property=Id --value 2>/dev/null
}

declare -A FOUND=()

CANDIDATES=("${DEFAULT_SERVICES[@]}")
if [[ -n "${EXTRA_SERVICES}" ]]; then
    IFS=',' read -ra EXTRA_ARR <<< "${EXTRA_SERVICES}"
    CANDIDATES+=("${EXTRA_ARR[@]}")
fi

log "Detecting installed services..."
for candidate in "${CANDIDATES[@]}"; do
    candidate="$(echo "${candidate}" | xargs)"
    [[ -z "${candidate}" ]] && continue
    service_exists "${candidate}" || continue
    resolved="$(resolve_service "${candidate}" || true)"
    [[ -z "${resolved}" ]] && continue
    FOUND["${resolved%.service}"]=1
done

# De-duplicate common aliases
[[ -n "${FOUND[mariadb]+x}" ]] && { unset 'FOUND[mysql]'; unset 'FOUND[mysqld]'; }
[[ -n "${FOUND[redis-server]+x}" ]] && unset 'FOUND[redis]'
[[ -n "${FOUND[supervisor]+x}" ]] && unset 'FOUND[supervisord]'
[[ -n "${FOUND[apache2]+x}" ]] && unset 'FOUND[httpd]'
[[ -n "${FOUND[cron]+x}" ]] && unset 'FOUND[crond]'

MONITORED_SERVICES=()
while IFS= read -r svc; do
    [[ -n "${svc}" ]] && MONITORED_SERVICES+=("${svc}")
done < <(printf '%s\n' "${!FOUND[@]}" | sort)

if [[ "${#MONITORED_SERVICES[@]}" -eq 0 ]]; then
    warn "No supported services detected. Framework will still be installed."
elif [[ "${INTERACTIVE}" == "1" ]]; then
    echo
    log "Found these services on this system — choose which to self-heal:"
    CONFIRMED_SERVICES=()
    for svc in "${MONITORED_SERVICES[@]}"; do
        status="stopped"
        systemctl is-active --quiet "${svc}.service" 2>/dev/null && status="running"
        read -rp "  ${svc} (${status}) — add self-healing for this service? [Y/n]: " reply
        case "${reply,,}" in
            n|no) log "    skipping ${svc}" ;;
            *) CONFIRMED_SERVICES+=("${svc}") ;;
        esac
    done
    MONITORED_SERVICES=("${CONFIRMED_SERVICES[@]}")
    echo
    if [[ "${#MONITORED_SERVICES[@]}" -eq 0 ]]; then
        warn "No services selected. Framework will still be installed."
    else
        log "Managing services:"
        for s in "${MONITORED_SERVICES[@]}"; do echo "  -> ${s}"; done
    fi
else
    log "Managing services:"
    for s in "${MONITORED_SERVICES[@]}"; do echo "  -> ${s}"; done
fi

# ---------------------------------------------------------------------------
# Build services.conf (name:checktype:target), preserving prior overrides
# ---------------------------------------------------------------------------

declare -A PRIOR_CHECK=()
if [[ -f "${SERVICES_FILE}" ]]; then
    while IFS=: read -r n t v; do
        [[ -z "${n}" || "${n}" == \#* ]] && continue
        PRIOR_CHECK["${n}"]="${t}:${v}"
    done < "${SERVICES_FILE}"
fi

log "Writing ${SERVICES_FILE}..."
{
    echo "# Managed by setup-self-healing.sh"
    echo "# format: service_name:checktype:target   (checktype: none|tcp|http)"
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
        fi
        echo "${svc}:${checktype}:${target}"
    done
} > "${SERVICES_FILE}.new"

if [[ "${DRY_RUN}" != "1" ]]; then
    mv "${SERVICES_FILE}.new" "${SERVICES_FILE}"
    chmod 644 "${SERVICES_FILE}"
else
    cat "${SERVICES_FILE}.new"; rm -f "${SERVICES_FILE}.new"
fi

# ---------------------------------------------------------------------------
# Backup existing drop-ins
# ---------------------------------------------------------------------------

run mkdir -p "${BACKUP_DIR}"
for svc in "${MONITORED_SERVICES[@]}"; do
    d="/etc/systemd/system/${svc}.service.d"
    if [[ -d "${d}" ]]; then
        run mkdir -p "${BACKUP_DIR}/${svc}.service.d"
        cp -a "${d}/." "${BACKUP_DIR}/${svc}.service.d/" 2>/dev/null || true
    fi
done

# ---------------------------------------------------------------------------
# Logger script (ExecStopPost) — reads systemd env vars, not argv
# ---------------------------------------------------------------------------

log "Installing ${LOGGER_SCRIPT}..."
if [[ "${DRY_RUN}" != "1" ]]; then
cat > "${LOGGER_SCRIPT}" <<'EOF'
#!/usr/bin/env bash
# Invoked by systemd ExecStopPost=... %n
# systemd sets SERVICE_RESULT / EXIT_CODE / EXIT_STATUS as environment
# variables for ExecStopPost — read them directly, don't rely on argv
# expansion inside the unit file.
set -Eeuo pipefail

RAW_NAME="${1:-unknown}"
SERVICE_NAME="${RAW_NAME%.service}"
SERVICE_RESULT="${SERVICE_RESULT:-unknown}"
EXIT_CODE="${EXIT_CODE:-unknown}"
EXIT_STATUS="${EXIT_STATUS:-unknown}"

BASE_DIR="/var/lib/self-healing"
COUNT_DIR="${BASE_DIR}/counts"
STATE_DIR="${BASE_DIR}/state"
LOCK_FILE="${BASE_DIR}/self-healing.lock"
LOG_FILE="/var/log/self-healing/events.log"
CONFIG_FILE="/etc/self-healing/config.conf"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

[[ -f "${CONFIG_FILE}" ]] && source "${CONFIG_FILE}"
RESTART_WINDOW="${RESTART_WINDOW:-600}"

[[ "${SERVICE_NAME}" =~ ^[a-zA-Z0-9_.@-]+$ ]] || SERVICE_NAME="unknown"

# Ignore clean stops (manual `systemctl stop`, reboots, etc.)
[[ "${SERVICE_RESULT}" == "success" ]] && exit 0

mkdir -p "${COUNT_DIR}" "${STATE_DIR}"
touch "${LOG_FILE}" "${LOCK_FILE}"

COUNT_FILE="${COUNT_DIR}/${SERVICE_NAME}"
STATE_FILE="${STATE_DIR}/${SERVICE_NAME}.state"
WINDOW_FILE="${STATE_DIR}/${SERVICE_NAME}.window"

(
    flock -x 200
    CUR=0
    [[ -f "${COUNT_FILE}" ]] && CUR="$(<"${COUNT_FILE}")"
    [[ "${CUR}" =~ ^[0-9]+$ ]] || CUR=0
    NEW=$((CUR + 1))
    echo "${NEW}" > "${COUNT_FILE}"

    # Rolling crash count within RESTART_WINDOW seconds — lets the notifier
    # tell a one-off crash apart from a genuine crash-loop, since systemd's
    # OnFailure= fires on every single failed-restart cycle, not just once
    # the restart budget (StartLimitBurst) is actually exhausted.
    NOW_EPOCH="$(date +%s)"
    WIN_START="${NOW_EPOCH}"
    WIN_COUNT=1
    if [[ -f "${WINDOW_FILE}" ]]; then
        IFS=: read -r PREV_START PREV_COUNT < "${WINDOW_FILE}" || true
        [[ "${PREV_START}" =~ ^[0-9]+$ ]] || PREV_START=0
        [[ "${PREV_COUNT}" =~ ^[0-9]+$ ]] || PREV_COUNT=0
        if (( NOW_EPOCH - PREV_START <= RESTART_WINDOW )); then
            WIN_START="${PREV_START}"
            WIN_COUNT=$((PREV_COUNT + 1))
        fi
    fi
    echo "${WIN_START}:${WIN_COUNT}" > "${WINDOW_FILE}"

    cat > "${STATE_FILE}" <<STATE
service=${SERVICE_NAME}
last_failure=${TIMESTAMP}
service_result=${SERVICE_RESULT}
exit_code=${EXIT_CODE}
exit_status=${EXIT_STATUS}
failure_count=${NEW}
window_count=${WIN_COUNT}
STATE
    echo "[${TIMESTAMP}] WARNING: ${SERVICE_NAME} failed. result=${SERVICE_RESULT} exit_code=${EXIT_CODE} exit_status=${EXIT_STATUS} total_failures=${NEW} window=${WIN_COUNT}" >> "${LOG_FILE}"
) 200>"${LOCK_FILE}"
exit 0
EOF
chmod 755 "${LOGGER_SCRIPT}"
fi

# ---------------------------------------------------------------------------
# Notifier script — Slack + email, with per-service cooldown
# ---------------------------------------------------------------------------

log "Installing ${NOTIFIER_SCRIPT}..."
if [[ "${DRY_RUN}" != "1" ]]; then
cat > "${NOTIFIER_SCRIPT}" <<'EOF'
#!/usr/bin/env bash
# Usage: self-healing-notify.sh <service-or-label> <reason text> [mode]
# mode "crash" (used by OnFailure=) is gated on the rolling crash-window
# counter the logger maintains — systemd fires OnFailure= on every single
# failed-restart cycle, not just once the restart budget is exhausted, so
# without this gate every crash would page immediately instead of only
# once RESTART_BURST crashes happen within RESTART_WINDOW seconds.
# Any other mode (e.g. the active health-check watchdog) alerts unconditionally
# since that caller already does its own consecutive-failure gating.
set -Eeuo pipefail

RAW_NAME="${1:-unknown}"
SERVICE_NAME="${RAW_NAME%.service}"
REASON="${2:-Service entered a failed/unhealthy state}"
MODE="${3:-direct}"

CONFIG_FILE="/etc/self-healing/config.conf"
STATE_DIR="/var/lib/self-healing/state"
LOG_FILE="/var/log/self-healing/events.log"
HOSTNAME="$(hostname -f 2>/dev/null || hostname)"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S %Z')"

[[ -f "${CONFIG_FILE}" ]] && source "${CONFIG_FILE}"

COOLDOWN_SECONDS="${COOLDOWN_SECONDS:-1800}"
RESTART_BURST="${RESTART_BURST:-3}"
NOTIFY_FLAG="${STATE_DIR}/${SERVICE_NAME}.last_notify"
NOW="$(date +%s)"

mkdir -p "${STATE_DIR}"
touch "${LOG_FILE}"

if [[ "${MODE}" == "crash" ]]; then
    WINDOW_FILE="${STATE_DIR}/${SERVICE_NAME}.window"
    WIN_COUNT=0
    if [[ -f "${WINDOW_FILE}" ]]; then
        IFS=: read -r _ WIN_COUNT < "${WINDOW_FILE}" || true
    fi
    [[ "${WIN_COUNT}" =~ ^[0-9]+$ ]] || WIN_COUNT=0
    if (( WIN_COUNT < RESTART_BURST )); then
        echo "[${TIMESTAMP}] ${SERVICE_NAME} crashed (${WIN_COUNT}/${RESTART_BURST} within the restart window) — systemd is still auto-restarting it, no alert yet." >> "${LOG_FILE}"
        exit 0
    fi
    REASON="Crashed ${WIN_COUNT} times within the restart window — restart budget exhausted"
fi

MSG="[${HOSTNAME}] CRITICAL: ${SERVICE_NAME} — ${REASON} (${TIMESTAMP})"
echo "[${TIMESTAMP}] ${MSG}" >> "${LOG_FILE}"

LAST=0
[[ -f "${NOTIFY_FLAG}" ]] && LAST="$(<"${NOTIFY_FLAG}")"
[[ "${LAST}" =~ ^[0-9]+$ ]] || LAST=0

if (( NOW - LAST < COOLDOWN_SECONDS )); then
    echo "[${TIMESTAMP}] Notification for ${SERVICE_NAME} suppressed (cooldown active)." >> "${LOG_FILE}"
    exit 0
fi

SENT=0

if [[ -n "${EXISTING_SLACK_WEBHOOK:-}" ]] && command -v curl >/dev/null 2>&1; then
    PAYLOAD="$(printf '{"text":"%s"}' "${MSG//\"/\\\"}")"
    if curl -fsS -m 5 -X POST -H 'Content-type: application/json' \
        --data "${PAYLOAD}" "${EXISTING_SLACK_WEBHOOK}" >/dev/null 2>&1; then
        SENT=1
    else
        echo "[${TIMESTAMP}] Slack notification failed for ${SERVICE_NAME}." >> "${LOG_FILE}"
    fi
fi

if [[ -n "${EXISTING_GOOGLECHAT_WEBHOOK:-}" ]] && command -v curl >/dev/null 2>&1; then
    PAYLOAD="$(printf '{"text":"%s"}' "${MSG//\"/\\\"}")"
    if curl -fsS -m 5 -X POST -H 'Content-type: application/json; charset=UTF-8' \
        --data "${PAYLOAD}" "${EXISTING_GOOGLECHAT_WEBHOOK}" >/dev/null 2>&1; then
        SENT=1
    else
        echo "[${TIMESTAMP}] Google Chat notification failed for ${SERVICE_NAME}." >> "${LOG_FILE}"
    fi
fi

if [[ -n "${EXISTING_EMAIL_TO:-}" ]] && command -v mail >/dev/null 2>&1; then
    if echo "${MSG}" | mail -s "[self-healing] ${SERVICE_NAME} on ${HOSTNAME}" \
        ${EXISTING_EMAIL_FROM:+-r "${EXISTING_EMAIL_FROM}"} "${EXISTING_EMAIL_TO}" 2>/dev/null; then
        SENT=1
    else
        echo "[${TIMESTAMP}] Email notification failed for ${SERVICE_NAME}." >> "${LOG_FILE}"
    fi
fi

if [[ "${SENT}" == "1" ]]; then
    echo "${NOW}" > "${NOTIFY_FLAG}"
else
    echo "[${TIMESTAMP}] No notification channel configured/succeeded for ${SERVICE_NAME}." >> "${LOG_FILE}"
fi
exit 0
EOF
chmod 755 "${NOTIFIER_SCRIPT}"
fi

# ---------------------------------------------------------------------------
# systemd notifier@ template (fired by OnFailure=)
# ---------------------------------------------------------------------------

log "Installing ${NOTIFIER_UNIT}..."
if [[ "${DRY_RUN}" != "1" ]]; then
cat > "${NOTIFIER_UNIT}" <<EOF
[Unit]
Description=Self-Healing Failure Notification for %i
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=${NOTIFIER_SCRIPT} %i "Crashed and was auto-restarted by systemd" crash
EOF
chmod 644 "${NOTIFIER_UNIT}"
fi

# ---------------------------------------------------------------------------
# Apply per-service systemd drop-ins
# ---------------------------------------------------------------------------

log "Applying systemd drop-ins..."
for svc in "${MONITORED_SERVICES[@]}"; do
    DROP_DIR="/etc/systemd/system/${svc}.service.d"
    DROP_FILE="${DROP_DIR}/self-healing.conf"
    run mkdir -p "${DROP_DIR}"
    if [[ "${DRY_RUN}" != "1" ]]; then
cat > "${DROP_FILE}" <<EOF
# Managed by setup-self-healing.sh — do not hand-edit.
[Unit]
StartLimitIntervalSec=${RESTART_WINDOW}
StartLimitBurst=${RESTART_BURST}
OnFailure=service-notifier@%n.service

[Service]
Restart=on-failure
RestartSec=5s
ExecStopPost=${LOGGER_SCRIPT} %n
EOF
        chmod 644 "${DROP_FILE}"
    fi
    log "  configured: ${svc}"
done

# ---------------------------------------------------------------------------
# Active health-check watchdog (catches "up but hung" services)
# ---------------------------------------------------------------------------

log "Installing ${WATCHDOG_SCRIPT}..."
if [[ "${DRY_RUN}" != "1" ]]; then
cat > "${WATCHDOG_SCRIPT}" <<'EOF'
#!/usr/bin/env bash
# Active health-check watchdog. Restarts services that are "active" per
# systemd but not actually responding (TCP/HTTP), after N consecutive
# failed checks. Complements — does not replace — systemd's own
# Restart=on-failure, which only fires when the process itself dies.
set -Eeuo pipefail

CONFIG_FILE="/etc/self-healing/config.conf"
SERVICES_FILE="/etc/self-healing/services.conf"
STATE_DIR="/var/lib/self-healing/state"
LOCK_FILE="/var/lib/self-healing/self-healing.lock"
HEARTBEAT_FILE="/var/lib/self-healing/heartbeat"
LOG_FILE="/var/log/self-healing/events.log"
NOTIFIER="/usr/local/bin/self-healing-notify.sh"

[[ -f "${CONFIG_FILE}" ]] && source "${CONFIG_FILE}"
FAIL_THRESHOLD="${FAIL_THRESHOLD:-2}"

mkdir -p "${STATE_DIR}"
touch "${LOG_FILE}" "${LOCK_FILE}"
date +%s > "${HEARTBEAT_FILE}"

[[ -f "${SERVICES_FILE}" ]] || exit 0

check_tcp() {
    local port="$1"
    timeout 3 bash -c "exec 3<>/dev/tcp/127.0.0.1/${port}" 2>/dev/null
}

check_http() {
    local url="$1"
    curl -fsS -o /dev/null -m 5 "${url}" 2>/dev/null
}

while IFS=: read -r svc checktype target; do
    [[ -z "${svc}" || "${svc}" == \#* ]] && continue
    [[ "${checktype}" == "none" || -z "${checktype}" ]] && continue

    systemctl is-active --quiet "${svc}.service" 2>/dev/null || continue

    OK=1
    case "${checktype}" in
        tcp)  check_tcp "${target}"  || OK=0 ;;
        http) check_http "${target}" || OK=0 ;;
        *) continue ;;
    esac

    FAIL_STATE_FILE="${STATE_DIR}/${svc}.healthchecks"
    (
        flock -x 200
        FAILS=0
        [[ -f "${FAIL_STATE_FILE}" ]] && FAILS="$(<"${FAIL_STATE_FILE}")"
        [[ "${FAILS}" =~ ^[0-9]+$ ]] || FAILS=0

        if [[ "${OK}" == "1" ]]; then
            [[ "${FAILS}" != "0" ]] && echo "0" > "${FAIL_STATE_FILE}"
        else
            FAILS=$((FAILS + 1))
            echo "${FAILS}" > "${FAIL_STATE_FILE}"
            TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
            echo "[${TIMESTAMP}] WATCHDOG: ${svc} failed active health check (${checktype}:${target}), consecutive=${FAILS}" >> "${LOG_FILE}"

            if (( FAILS >= FAIL_THRESHOLD )); then
                echo "[${TIMESTAMP}] WATCHDOG: restarting ${svc} after ${FAILS} consecutive failed health checks" >> "${LOG_FILE}"
                systemctl restart "${svc}.service" 2>>"${LOG_FILE}" || true
                echo "0" > "${FAIL_STATE_FILE}"
                "${NOTIFIER}" "${svc}" "Active health check (${checktype}) failed ${FAILS}x in a row; watchdog restarted it" || true
            fi
        fi
    ) 200>"${LOCK_FILE}"
done < "${SERVICES_FILE}"
EOF
chmod 755 "${WATCHDOG_SCRIPT}"
fi

log "Installing watchdog systemd service + timer (every ${CHECK_INTERVAL}s)..."
if [[ "${DRY_RUN}" != "1" ]]; then
cat > "${WATCHDOG_SERVICE}" <<EOF
[Unit]
Description=Self-Healing Active Health-Check Watchdog

[Service]
Type=oneshot
ExecStart=${WATCHDOG_SCRIPT}
EOF

cat > "${WATCHDOG_TIMER}" <<EOF
[Unit]
Description=Run Self-Healing Watchdog every ${CHECK_INTERVAL}s

[Timer]
OnBootSec=30s
OnUnitActiveSec=${CHECK_INTERVAL}s
AccuracySec=5s

[Install]
WantedBy=timers.target
EOF
chmod 644 "${WATCHDOG_SERVICE}" "${WATCHDOG_TIMER}"
fi

# ---------------------------------------------------------------------------
# logrotate
# ---------------------------------------------------------------------------

log "Installing logrotate config..."
if [[ "${DRY_RUN}" != "1" ]]; then
cat > "${LOGROTATE_FILE}" <<EOF
${LOG_FILE} {
    weekly
    rotate 8
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
COUNT_DIR="${BASE_DIR}/counts"
HEARTBEAT_FILE="${BASE_DIR}/heartbeat"
SERVICES_FILE="/etc/self-healing/services.conf"

echo ""
echo "==================================================================="
echo " SERVER HEALTH & SELF-HEALING"
echo "==================================================================="

LOAD="$(uptime 2>/dev/null | awk -F'load average:' '{print $2}' | xargs || true)"
MEM_INFO="$(free -m 2>/dev/null | awk '/^Mem:/{used=$3; total=$2; pct=(total>0)?used*100/total:0; printf "%d %d %d", used, total, pct}')"
read -r MEM_USED MEM_TOTAL MEM_PCT <<< "${MEM_INFO:-0 0 0}"
DISK_INFO="$(df -hP / 2>/dev/null | awk 'NR==2{printf "%s %s %s", $3,$2,$5}')"
read -r DISK_USED DISK_TOTAL DISK_PCT <<< "${DISK_INFO:-? ? ?}"
OS_INFO="$(awk -F= '/^PRETTY_NAME=/{gsub(/"/,"",$2);print $2;exit}' /etc/os-release 2>/dev/null)"

echo " OS: ${OS_INFO:-unknown}"
echo " CPU Load: ${LOAD:-N/A}"
echo " Memory: ${MEM_USED}MB / ${MEM_TOTAL}MB (${MEM_PCT}% used)"
echo " Root Disk: ${DISK_USED} / ${DISK_TOTAL} (${DISK_PCT} used)"

if [[ -f "${HEARTBEAT_FILE}" ]]; then
    NOW="$(date +%s)"
    LAST="$(<"${HEARTBEAT_FILE}")"
    [[ "${LAST}" =~ ^[0-9]+$ ]] || LAST=0
    AGE=$((NOW - LAST))
    if (( AGE > 300 )); then
        echo " Watchdog heartbeat: STALE (${AGE}s old) — self-healing watchdog may be down!"
    else
        echo " Watchdog heartbeat: OK (${AGE}s ago)"
    fi
else
    echo " Watchdog heartbeat: not found"
fi

echo ""
echo " --- Monitored Services ---"
if [[ -f "${SERVICES_FILE}" ]]; then
    found=0
    while IFS=: read -r svc checktype target; do
        [[ -z "${svc}" || "${svc}" == \#* ]] && continue
        found=1
        FAIL_COUNT=0
        [[ -f "${COUNT_DIR}/${svc}" ]] && FAIL_COUNT="$(<"${COUNT_DIR}/${svc}")"
        if systemctl is-active --quiet "${svc}.service" 2>/dev/null; then
            echo " [ OK ] ${svc} (failures logged: ${FAIL_COUNT}, check: ${checktype:-none})"
        else
            echo " [FAIL] ${svc} (failures logged: ${FAIL_COUNT}) - OFFLINE"
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

log "Validating generated units..."
systemd-analyze verify "${NOTIFIER_UNIT}" "${WATCHDOG_SERVICE}" "${WATCHDOG_TIMER}" || \
    warn "systemd-analyze verify reported issues above — review before relying on this in production."

for svc in "${MONITORED_SERVICES[@]}"; do
    # Verify the merged unit (base unit + our drop-in), not the drop-in
    # fragment by itself — systemd-analyze verify requires a full unit
    # file name/suffix and rejects a bare ".conf" override snippet.
    systemd-analyze verify "${svc}.service" || \
        warn "Verification issue for ${svc} — check its drop-in."
done

log "Enabling and starting watchdog timer..."
systemctl enable --now self-healing-watchdog.timer

log "Checking applied restart policies..."
for svc in "${MONITORED_SERVICES[@]}"; do
    pol="$(systemctl show "${svc}.service" --property=Restart --value)"
    echo "  ${svc}: Restart=${pol}"
    [[ "${pol}" == "on-failure" ]] || warn "${svc}: expected Restart=on-failure, got '${pol}'"
done

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
echo " Watchdog interval: ${CHECK_INTERVAL}s (systemd timer)"
echo " Restart policy:    ${RESTART_BURST} tries per ${RESTART_WINDOW}s, then notify"
echo " Notify cooldown:   ${COOLDOWN_SECONDS}s per service"
echo " Slack configured:      $([[ -n "${SLACK_WEBHOOK}" ]] && echo yes || echo no)"
echo " Google Chat configured: $([[ -n "${GOOGLECHAT_WEBHOOK}" ]] && echo yes || echo no)"
echo " Email configured:      $([[ -n "${EMAIL_TO}" ]] && echo "yes (${EMAIL_TO})" || echo no)"
echo
echo " Config:    ${CONFIG_FILE}"
echo " Services:  ${SERVICES_FILE}  (edit to add checktype/target per app)"
echo " Event log: ${LOG_FILE}"
echo " Backup:    ${BACKUP_DIR}"
echo
echo " Useful commands:"
echo "   tail -f ${LOG_FILE}"
echo "   systemctl status self-healing-watchdog.timer"
echo "   systemctl list-timers self-healing-watchdog.timer"
echo "   cat ${SERVICES_FILE}"
echo "   sudo ./setup-self-healing.sh --uninstall"
echo
echo " Add a custom app: edit ${SERVICES_FILE} directly, e.g.:"
echo "   myapp:http:http://127.0.0.1:8080/health"
echo " then run: systemctl restart self-healing-watchdog.timer"
echo "============================================================"

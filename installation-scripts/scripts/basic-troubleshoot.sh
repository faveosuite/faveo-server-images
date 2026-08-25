#!/bin/bash

##### This is a Basic troubleshooting script for Faveo helpdesk #####
##### This Script can be used in all Linux distributions ############
##### (Note: Tested with Debian and RHEL OS Distro's) ###############
##### (Usage: sudo ./basic_troubleshoot.sh) #########################
##### Created and maintained by Faveo Helpdesk ######################
##### For Any Queries reach (support.faveohelpdesk.com) #############
##### version of the script: 2.0 ####################################
##### Author: thirumoorthi.duraipandi@faveohelpdesk.com #############


# Colour Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Faveo Banner.

echo -e "$CYAN                                                                                                                         $RESET";
sleep 0.05
echo -e "$CYAN                                        _______ _______ _     _ _______ _______                                          $RESET";
sleep 0.05
echo -e "$CYAN                                       (_______|_______|_)   (_|_______|_______)                                         $RESET";
sleep 0.05
echo -e "$CYAN                                        _____   _______ _     _ _____   _     _                                          $RESET";
sleep 0.05
echo -e "$CYAN                                       |  ___) |  ___  | |   | |  ___) | |   | |                                         $RESET";
sleep 0.05
echo -e "$CYAN                                       | |     | |   | |\ \ / /| |_____| |___| |                                         $RESET";
sleep 0.05
echo -e "$CYAN                                       |_|     |_|   |_| \___/ |_______)\_____/                                          $RESET";
sleep 0.05
echo -e "$CYAN                                                                                                                         $RESET";
sleep 0.05
echo -e "$CYAN                              _     _ _______ _       ______ ______  _______  ______ _     _                            $RESET";
sleep 0.05
echo -e "$CYAN                             (_)   (_|_______|_)     (_____ (______)(_______)/ _____|_)   | |                            $RESET";
sleep 0.05
echo -e "$CYAN                              _______ _____   _       _____) )     _ _____  ( (____  _____| |                            $RESET";
sleep 0.05
echo -e "$CYAN                             |  ___  |  ___) | |     |  ____/ |   | |  ___)  \____ \|  _   _)                            $RESET";
sleep 0.05
echo -e "$CYAN                             | |   | | |_____| |_____| |    | |__/ /| |_____ _____) ) |  \ \                             $RESET";
sleep 0.05
echo -e "$CYAN                             |_|   |_|_______)_______)_|    |_____/ |_______|______/|_|   \_)                            $RESET";
sleep 0.05
echo -e "$CYAN                                                                                                                         $RESET";
sleep 0.05
echo -e "$CYAN                                                                                                                         $RESET";

if readlink /proc/$$/exe | grep -q "dash"; then
        echo -e "${RED}This installer needs to be run with 'bash', not 'sh'.${RESET}";
        exit 1
fi

# Root check
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root${RESET}"
    exit 1
fi

# Graceful exit on Ctrl+C instead of dying mid-write
trap 'echo -e "\n${YELLOW}Interrupted by user. Exiting.${RESET}"; exit 130' INT

# Generic dependency installer: ensure_installed <binary> [debian_pkg] [rhel_pkg]
# Uses $ID from /etc/os-release (sourced below) to pick the right package manager.
ensure_installed() {
    local bin="$1" deb_pkg="${2:-$1}" rhel_pkg="${3:-$1}"
    if command -v "$bin" &>/dev/null; then
        return 0
    fi
    echo -e "${CYAN}$bin not found, attempting install...${RESET}"
    case "$ID" in
        ubuntu|debian)
            apt-get update -qq && apt-get install -y "$deb_pkg" >/dev/null 2>&1
            ;;
        rhel|centos|rocky|almalinux|fedora)
            yum install -y "$rhel_pkg" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
    command -v "$bin" &>/dev/null
}

# OS & Version check
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
else
    echo -e "${RED}Unable to detect OS${RESET}"
    exit 1
fi

SUPPORTED=true
SUGGESTION=""

case "$ID" in
    ubuntu)
        # Ubuntu LTS >= 20.04
        UB_VER=$(echo "$VERSION_ID" | cut -d. -f1)
        if (( UB_VER < 20 )); then
            SUPPORTED=false
            SUGGESTION="Use Ubuntu 20.04 LTS or newer"
        fi
        ;;
    debian)
        # Debian LTS >= 11
        DEB_VER=$(echo "$VERSION_ID" | cut -d. -f1)
        if [[ ! "$DEB_VER" =~ ^[0-9]+$ ]]; then
            SUPPORTED=false
            SUGGESTION="Could not determine Debian version (got: '$VERSION_ID'). Use Debian 11 or 12 (LTS)"
        elif (( DEB_VER < 11 )); then
            SUPPORTED=false
            SUGGESTION="Use Debian 11 or 12 (LTS)"
        fi
        ;;
    rhel)
        # RHEL LTS >= 8
        RHEL_VER=$(echo "$VERSION_ID" | cut -d. -f1)
        if (( RHEL_VER < 8 )); then
            SUPPORTED=false
            SUGGESTION="Use RHEL 8 or 9 (LTS)"
        fi
        ;;
    rocky)
        ROCKY_VER=$(echo "$VERSION_ID" | cut -d. -f1)
        if (( ROCKY_VER < 8 )); then
            SUPPORTED=false
            SUGGESTION="Use Rocky Linux 8 or 9 (LTS)"
        fi
        ;;
    almalinux)
        ALMA_VER=$(echo "$VERSION_ID" | cut -d. -f1)
        if (( ALMA_VER < 8 )); then
            SUPPORTED=false
            SUGGESTION="Use AlmaLinux 8 or 9 (LTS)"
        fi
        ;;
    *)
        SUPPORTED=false
        SUGGESTION="Supported OS: Ubuntu ≥20.04 LTS, Debian 11/12, RHEL/Rocky/Alma 8 or 9"
        ;;
esac

if [[ "$SUPPORTED" != true ]]; then
    echo -e "${RED}Unsupported OS detected:${RESET} $PRETTY_NAME"
    echo -e "${YELLOW}Recommendation:${RESET} $SUGGESTION"
    exit 1
fi

echo -e "${GREEN}OS check passed:${RESET} $PRETTY_NAME"

# Get script directory for log
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/faveo-check.log"

# Clearing the log file at the beginning
> "$LOG_FILE"

# ---------------- Table Helpers ----------------
# Every report section is rendered as a fixed-width table so the output is
# easy to scan. Colour codes are written *inside* the padded field, so the
# escape sequences never disturb the column alignment.

# tbl_cell <text> <width> [colour] -> padded (and optionally coloured) cell
tbl_cell() {
    local text="$1" width="$2" color="${3:-}"
    if (( ${#text} > width )); then
        if (( width > 3 )); then
            text="${text:0:width-3}..."
        else
            text="${text:0:width}"
        fi
    fi
    if [[ -n "$color" ]]; then
        printf '%b%-*s%b' "$color" "$width" "$text" "$RESET"
    else
        printf '%-*s' "$width" "$text"
    fi
}

# tbl_head <width:Header> [<width:Header> ...]
tbl_head() {
    local line="" sep="" spec w h
    for spec in "$@"; do
        w="${spec%%:*}"
        h="${spec#*:}"
        line+="$(printf '%-*s' "$w" "$h") | "
        sep+="$(printf '%*s' "$w" '' | tr ' ' '-')-+-"
    done
    printf '%b%s%b\n' "$CYAN" "${line% | }" "$RESET" | tee -a "$LOG_FILE"
    printf '%s\n' "${sep%-+-}" | tee -a "$LOG_FILE"
}

# tbl_row <text> <width> <colour> [<text> <width> <colour> ...]
tbl_row() {
    local line=""
    while (( $# >= 3 )); do
        line+="$(tbl_cell "$1" "$2" "$3") | "
        shift 3
    done
    printf '%s\n' "${line% | }" | tee -a "$LOG_FILE"
}

# usage_color <percentage-number> -> colour based on 75/90 thresholds
usage_color() {
    local pct="$1"
    if [[ ! "$pct" =~ ^[0-9]+$ ]]; then
        printf '%s' ""
    elif (( pct >= 90 )); then
        printf '%s' "$RED"
    elif (( pct >= 75 )); then
        printf '%s' "$YELLOW"
    else
        printf '%s' "$GREEN"
    fi
}

# Detect the installed PHP version once and derive every PHP-related
# path/service name from it so checks don't rely on a hardcoded version.
PHP_VERSION=""
PHP_FPM_SERVICE=""
PHP_INI_FILES=()
PHP_FPM_CONF_FILES=()

detect_php_version() {
    if command -v php &>/dev/null; then
        PHP_VERSION=$(php -v 2>/dev/null | head -n1 | grep -oE 'PHP [0-9]+\.[0-9]+' | awk '{print $2}')
    fi

    # Fall back to inspecting installed packages if the php CLI isn't on PATH
    if [[ -z "$PHP_VERSION" ]]; then
        case "$ID" in
            ubuntu|debian)
                for d in /etc/php/*/; do
                    v=$(basename "$d")
                    [[ "$v" =~ ^[0-9]+\.[0-9]+$ ]] || continue
                    if [[ -z "$PHP_VERSION" ]] || [[ "$(printf '%s\n%s\n' "$PHP_VERSION" "$v" | sort -V | tail -n1)" == "$v" ]]; then
                        PHP_VERSION="$v"
                    fi
                done
                ;;
            rhel|centos|rocky|almalinux|fedora)
                PHP_VERSION=$(rpm -qa 2>/dev/null | grep -oE '^php-[0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n1)
                ;;
        esac
    fi

    if [[ -z "$PHP_VERSION" ]]; then
        echo -e "${YELLOW}Could not detect an installed PHP version. PHP-specific checks will be limited.${RESET}" | tee -a "$LOG_FILE"
        return 1
    fi

    echo -e "${GREEN}Detected PHP version: $PHP_VERSION${RESET}" | tee -a "$LOG_FILE"

    case "$ID" in
        ubuntu|debian)
            PHP_FPM_SERVICE="php${PHP_VERSION}-fpm"
            PHP_INI_FILES=(
                "/etc/php/${PHP_VERSION}/fpm/php.ini"
                "/etc/php/${PHP_VERSION}/apache2/php.ini"
                "/etc/php/${PHP_VERSION}/cli/php.ini"
            )
            PHP_FPM_CONF_FILES=("/etc/php/${PHP_VERSION}/fpm/php.ini")
            if [[ -d "/etc/php/${PHP_VERSION}/fpm/pool.d" ]]; then
                PHP_FPM_CONF_FILES+=(/etc/php/${PHP_VERSION}/fpm/pool.d/*.conf)
            fi
            ;;
        rhel|centos|rocky|almalinux|fedora)
            # Stock RHEL/Rocky/Alma packages register an unversioned php-fpm.service.
            # Remi-style SCL packages use phpNN-php-fpm instead — detect which exists.
            if systemctl list-unit-files 2>/dev/null | awk '{print $1}' | grep -qx "php-fpm.service"; then
                PHP_FPM_SERVICE="php-fpm"
            else
                PHP_FPM_SERVICE="php${PHP_VERSION//./}-php-fpm"
            fi
            PHP_INI_FILES=("/etc/php.ini")
            PHP_FPM_CONF_FILES=("/etc/php.ini")
            if [[ -d /etc/php-fpm.d ]]; then
                PHP_FPM_CONF_FILES+=(/etc/php-fpm.d/*.conf)
            fi
            ;;
        *)
            PHP_FPM_SERVICE="php-fpm"
            PHP_INI_FILES=("/etc/php.ini")
            ;;
    esac

    # Only keep ini files that actually exist on disk
    local existing=()
    for f in "${PHP_INI_FILES[@]}"; do
        [[ -f "$f" ]] && existing+=("$f")
    done
    PHP_INI_FILES=("${existing[@]}")
}

detect_php_version

# Time & Date Header
print_header() {
    echo -e "${CYAN}Welcome to $(hostname)\nDate: $(date)${RESET}" | tee -a "$LOG_FILE"
    echo "--------------------------------------------------" | tee -a "$LOG_FILE"
}

# Ask for Faveo root path
read -rp "Enter Faveo root directory path (e.g., /var/www/faveo) /var/www/faveo is the default press enter to use the default value: " FAVEO_ROOT
FAVEO_ROOT=${FAVEO_ROOT:-/var/www/faveo}

# Domain Validation
validate_domain() {
    APP_URL=$(grep APP_URL "$FAVEO_ROOT/.env" 2>/dev/null | cut -d '=' -f2 | tr -d '[:space:]')
    CLEAN_DOMAIN=$(echo "$APP_URL" | sed -E 's@^https?://@@; s@/*$@@')

    echo -e "${YELLOW}Faveo APP_URL from .env: ${RESET}$CLEAN_DOMAIN" | tee -a "$LOG_FILE"

    read -rp "Enter domain for SSL check (leave empty to use APP_URL): " USER_DOMAIN

    if [[ -z "$USER_DOMAIN" ]]; then
        DOMAIN="$CLEAN_DOMAIN"
        echo -e "${GREEN}No domain entered. Using APP_URL domain: $DOMAIN${RESET}" | tee -a "$LOG_FILE"
    else
        DOMAIN="$USER_DOMAIN"
        if [[ "$DOMAIN" != "$CLEAN_DOMAIN" ]]; then
            echo -e "${YELLOW}WARNING: Entered domain ($DOMAIN) does NOT match APP_URL ($CLEAN_DOMAIN).${RESET}" | tee -a "$LOG_FILE"
            read -rp "Do you want to continue anyway? (y/n): " CHOICE
            if [[ ! "$CHOICE" =~ ^[Yy]$ ]]; then
                echo -e "${RED}Aborting. Please rerun the script and provide the correct domain.${RESET}" | tee -a "$LOG_FILE"
                exit 1
            fi
        else
            echo -e "${GREEN}Domain matches APP_URL in .env${RESET}" | tee -a "$LOG_FILE"
        fi
    fi
}

# System Info
get_system_info() {
    echo -e "${YELLOW}System Info:${RESET}" | tee -a "$LOG_FILE"

    DISTRO=$(lsb_release -ds 2>/dev/null || awk -F= '/^PRETTY_NAME/{print $2}' /etc/os-release | tr -d '"')
    MEM_INFO=$(free -h | awk '/^Mem:/ {print $3 " used / " $2 " total (available: " $7 ")"}')
    SWAP_INFO=$(free -h | awk '/^Swap:/ {print $3 " used / " $2 " total"}')
    MEM_PCT=$(free -m | awk '/^Mem:/ {printf "%d", ($3/$2)*100}')

    tbl_head "20:Parameter" "62:Value"
    tbl_row "Hostname"    20 "" "$(hostname)"                        62 ""
    tbl_row "Distro"      20 "" "$DISTRO"                            62 ""
    tbl_row "Kernel"      20 "" "$(uname -r)"                        62 ""
    tbl_row "Architecture" 20 "" "$(uname -m)"                       62 ""
    tbl_row "Uptime"      20 "" "$(uptime -p)"                       62 ""
    tbl_row "Load Avg"    20 "" "$(cut -d ' ' -f1-3 /proc/loadavg)"  62 ""
    tbl_row "vCPU Cores"  20 "" "$(nproc)"                           62 ""
    tbl_row "Memory"      20 "$(usage_color "$MEM_PCT")" "$MEM_INFO" 62 "$(usage_color "$MEM_PCT")"
    tbl_row "Swap"        20 "" "${SWAP_INFO:-Not configured}"       62 ""

    echo | tee -a "$LOG_FILE"
    echo -e "${CYAN}Disk Usage (All Mounted Partitions):${RESET}" | tee -a "$LOG_FILE"

    tbl_head "28:Filesystem" "8:Size" "8:Used" "8:Avail" "6:Use%" "24:Mounted On"
    df -h --output=source,size,used,avail,pcent,target 2>/dev/null | tail -n +2 | \
    while read -r src size used avail pcent target; do
        pct="${pcent%\%}"
        color="$(usage_color "$pct")"
        tbl_row "$src" 28 "" "$size" 8 "" "$used" 8 "" "$avail" 8 "" \
                "$pcent" 6 "$color" "$target" 24 ""
    done

    echo | tee -a "$LOG_FILE"
}

# Service Status
get_service_status() {

    # Detect OS silently
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_ID=$ID
    else
        OS_ID=$(uname -s)
    fi

    # Services per OS
    case "$OS_ID" in
        ubuntu|debian)
            SERVICES=(
                apache2 mysql redis-server supervisor php8.2-fpm
                cron nginx meilisearch node npm csf
            )
            ;;
        rhel|centos|rocky|almalinux|fedora)
            SERVICES=(
                httpd mariadb redis supervisord
                crond nginx meilisearch node npm csf
            )
            ;;
        *)
            SERVICES=()
            ;;
    esac

    # Add the dynamically detected PHP-FPM service name, if PHP was found
    [[ -n "$PHP_FPM_SERVICE" ]] && SERVICES+=("$PHP_FPM_SERVICE")

    # CLI-only tools (not systemd services)
    CLI_TOOLS=(node npm csf)

    # First pass: figure out which candidate services are actually present
    # on this host. Only those get a full status/version report below.
    INSTALLED_SERVICES=()
    MISSING_SERVICES=()

    for svc in "${SERVICES[@]}"; do
        if [[ " ${CLI_TOOLS[*]} " == *" $svc "* ]]; then
            if command -v "$svc" >/dev/null 2>&1; then
                INSTALLED_SERVICES+=("$svc")
            else
                MISSING_SERVICES+=("$svc")
            fi
        else
            if systemctl list-unit-files 2>/dev/null | awk '{print $1}' | grep -qx "${svc}.service"; then
                INSTALLED_SERVICES+=("$svc")
            else
                MISSING_SERVICES+=("$svc")
            fi
        fi
    done

    echo -e "${YELLOW}Service Status:${RESET}" | tee -a "$LOG_FILE"

    if [[ ${#INSTALLED_SERVICES[@]} -eq 0 ]]; then
        echo -e "${RED}No known Faveo-related services were detected on this system.${RESET}" | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
        return
    fi

    tbl_head "18:Service" "12:Status" "26:Active Since" "40:Version"

    for svc in "${INSTALLED_SERVICES[@]}"; do

        # Version check (only for installed services)
        ver="Not available"

        case "$svc" in
            node) ver=$(node -v 2>/dev/null) ;;
            npm) ver=$(npm -v 2>/dev/null) ;;
            csf) ver=$(csf -v 2>/dev/null | head -n1) ;;
            *php*fpm*)
                if [[ -n "$PHP_VERSION" ]] && command -v php >/dev/null 2>&1; then
                    ver="$(php -v 2>/dev/null | head -n1 | cut -d'(' -f1 | xargs) (detected: $PHP_VERSION)"
                fi
                ;;
            redis|redis-server)
                command -v redis-server >/dev/null && ver=$(redis-server --version | awk '{print $1" "$2" "$3}')
                ;;
            mysql|mariadb)
                command -v mysql >/dev/null && ver=$(mysql --version | sed 's/^mysql *//; s/, for .*//')
                ;;
            nginx)
                command -v nginx >/dev/null && ver=$(nginx -v 2>&1 | sed 's/nginx version: //')
                ;;
            apache2|httpd)
                command -v apache2 >/dev/null && ver=$(apache2 -v | awk -F': ' '/Server version/ {print $2}')
                command -v httpd >/dev/null && ver=$(httpd -v | awk -F': ' '/Server version/ {print $2}')
                ;;
            meilisearch)
                command -v meilisearch >/dev/null && ver=$(meilisearch --version)
                ;;
        esac

        # CLI tools handling
        if [[ " ${CLI_TOOLS[*]} " == *" $svc "* ]]; then
            tbl_row "$svc" 18 "" "installed" 12 "$GREEN" "-" 26 "" "${ver:-Not available}" 40 ""
        else
            # systemd services handling
            status=$(systemctl is-active "$svc" 2>/dev/null)
            since=$(systemctl show "$svc" -p ActiveEnterTimestamp --value 2>/dev/null)

            if [[ "$status" == "active" ]]; then
                color="$GREEN"
            elif [[ "$status" == "activating" || "$status" == "reloading" ]]; then
                color="$YELLOW"
            else
                color="$RED"
            fi

            tbl_row "$svc" 18 "" "${status:-unknown}" 12 "$color" "${since:--}" 26 "" "${ver:-Not available}" 40 ""
        fi
    done

    if [[ ${#MISSING_SERVICES[@]} -gt 0 ]]; then
        echo | tee -a "$LOG_FILE"
        echo -e "${CYAN}Not installed / not detected on this host:${RESET}" | tee -a "$LOG_FILE"
        tbl_head "18:Service" "12:Status"
        for svc in "${MISSING_SERVICES[@]}"; do
            tbl_row "$svc" 18 "" "not found" 12 "$YELLOW"
        done
    fi

    echo | tee -a "$LOG_FILE"
}

# Faveo Details
check_faveo_info() {
    echo -e "${YELLOW}Faveo Application Info:${RESET}" | tee -a "$LOG_FILE"

    ENV_FILE="$FAVEO_ROOT/.env"
    CONFIG_FILE="$FAVEO_ROOT/storage/faveoconfig.ini"

    APP_URL=$(grep APP_URL "$ENV_FILE" 2>/dev/null | head -n1 | cut -d '=' -f2 | tr -d '[:space:]')
    PLAN=$(grep APP_NAME "$CONFIG_FILE" 2>/dev/null | head -n1 | cut -d '=' -f2 | tr -d '[:space:]')
    VERSION=$(grep APP_VERSION "$CONFIG_FILE" 2>/dev/null | head -n1 | cut -d '=' -f2 | tr -d '[:space:]')
    DB_NAME=$(grep -E '^DB_DATABASE=' "$ENV_FILE" 2>/dev/null | head -n1 | cut -d '=' -f2- | tr -d '"' | tr -d "'")
    APP_ENV=$(grep -E '^APP_ENV=' "$ENV_FILE" 2>/dev/null | head -n1 | cut -d '=' -f2 | tr -d '[:space:]')
    APP_DEBUG=$(grep -E '^APP_DEBUG=' "$ENV_FILE" 2>/dev/null | head -n1 | cut -d '=' -f2 | tr -d '[:space:]')
    OWNER=$(stat -c "%U:%G" "$FAVEO_ROOT" 2>/dev/null)

    tbl_head "22:Parameter" "12:Status" "56:Value"

    if [[ -d "$FAVEO_ROOT" ]]; then
        tbl_row "Faveo Root" 22 "" "Found" 12 "$GREEN" "$FAVEO_ROOT" 56 ""
    else
        tbl_row "Faveo Root" 22 "" "Missing" 12 "$RED" "$FAVEO_ROOT" 56 ""
    fi

    if [[ -f "$ENV_FILE" ]]; then
        tbl_row ".env File" 22 "" "Found" 12 "$GREEN" "$ENV_FILE" 56 ""
    else
        tbl_row ".env File" 22 "" "Missing" 12 "$RED" "$ENV_FILE" 56 ""
    fi

    if [[ -f "$CONFIG_FILE" ]]; then
        tbl_row "faveoconfig.ini" 22 "" "Found" 12 "$GREEN" "$CONFIG_FILE" 56 ""
    else
        tbl_row "faveoconfig.ini" 22 "" "Missing" 12 "$RED" "$CONFIG_FILE" 56 ""
    fi

    if [[ -n "$APP_URL" ]]; then
        URL_ST="Found"; URL_C="$GREEN"
    else
        URL_ST="Not set"; URL_C="$RED"
    fi
    tbl_row "URL"     22 "" "$URL_ST" 12 "$URL_C" "${APP_URL:--}" 56 ""
    tbl_row "Plan"    22 "" "-" 12 "" "${PLAN:-Not available}"    56 ""
    tbl_row "Version" 22 "" "-" 12 "" "${VERSION:-Not available}" 56 ""
    tbl_row "Database Name" 22 "" "-" 12 "" "${DB_NAME:-Not available}" 56 ""
    tbl_row "APP_ENV" 22 "" "-" 12 "" "${APP_ENV:-Not set}" 56 ""

    if [[ "${APP_DEBUG,,}" == "true" ]]; then
        tbl_row "APP_DEBUG" 22 "" "Warning" 12 "$YELLOW" "true (should be false in production)" 56 "$YELLOW"
    else
        tbl_row "APP_DEBUG" 22 "" "OK" 12 "$GREEN" "${APP_DEBUG:-Not set}" 56 ""
    fi

    if [[ "$OWNER" == "www-data:www-data" || "$OWNER" == "apache:apache" || "$OWNER" == "nginx:nginx" ]]; then
        tbl_row "Directory Owner" 22 "" "Correct" 12 "$GREEN" "$OWNER" 56 ""
    else
        tbl_row "Directory Owner" 22 "" "Check" 12 "$RED" "${OWNER:-Unknown}" 56 ""
    fi

    echo | tee -a "$LOG_FILE"
}

# Cron Jobs
check_cron_jobs() {
    echo -e "${YELLOW}Cron Jobs:${RESET}" | tee -a "$LOG_FILE"

    tbl_head "12:User" "10:Artisan" "72:Cron Entry"

    for user in www-data root; do
        CRONS=$(crontab -u "$user" -l 2>/dev/null | grep -vE '^\s*(#|$)')

        if [[ -z "$CRONS" ]]; then
            tbl_row "$user" 12 "" "-" 10 "" "No cron jobs configured" 72 "$YELLOW"
            continue
        fi

        echo "$CRONS" | while read -r line; do
            [[ -z "$line" ]] && continue
            if echo "$line" | grep -qEi '\bartisan\b'; then
                tbl_row "$user" 12 "" "Yes" 10 "$GREEN" "$line" 72 ""
            else
                tbl_row "$user" 12 "" "No" 10 "" "$line" 72 ""
            fi
        done
    done

    echo | tee -a "$LOG_FILE"

    # Last artisan cron executions per user
    for user in www-data root; do
        ARTISAN_CRONS=$(crontab -u "$user" -l 2>/dev/null | grep -vE '^\s*(#|$)' | grep -Ei '\bartisan\b')
        [[ -z "$ARTISAN_CRONS" ]] && continue

        echo -e "${CYAN}Last 6 artisan cron executions for $user:${RESET}" | tee -a "$LOG_FILE"

        if [[ -f /var/log/syslog ]]; then
            CRON_LOG=$(grep -iE "CRON.*\($user\).*artisan" /var/log/syslog 2>/dev/null | tail -n 6)
        elif [[ -f /var/log/cron ]]; then
            CRON_LOG=$(grep -iE "CRON.*\($user\).*artisan" /var/log/cron 2>/dev/null | tail -n 6)
        else
            CRON_LOG=""
            echo "Cron log file not found. Cannot determine last run times." | tee -a "$LOG_FILE"
        fi

        if [[ -n "$CRON_LOG" ]]; then
            tbl_head "18:Timestamp" "74:Log Entry"
            echo "$CRON_LOG" | while read -r logline; do
                TS=$(echo "$logline" | awk '{print $1" "$2" "$3}')
                MSG=$(echo "$logline" | cut -d')' -f2- | xargs)
                tbl_row "$TS" 18 "" "${MSG:-$logline}" 74 ""
            done
        fi

        echo | tee -a "$LOG_FILE"
    done
}

# Supervisor Jobs
check_supervisor_jobs() {
    echo -e "${YELLOW}Supervisor Jobs:${RESET}" | tee -a "$LOG_FILE"

    if ! command -v supervisorctl &>/dev/null; then
        echo -e "${RED}Supervisor not installed on this host.${RESET}" | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
        return
    fi

    SUP_OUT=$(supervisorctl status 2>/dev/null)

    if [[ -z "$SUP_OUT" ]] || echo "$SUP_OUT" | grep -qiE '^error|refused connection|permission'; then
        echo -e "${RED}Supervisor not available or permission denied${RESET}" | tee -a "$LOG_FILE"
        [[ -n "$SUP_OUT" ]] && echo "$SUP_OUT" | head -n 2 | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
        return
    fi

    tbl_head "34:Program" "12:State" "46:Details"

    echo "$SUP_OUT" | while read -r prog state details; do
        [[ -z "$prog" ]] && continue
        case "$state" in
            RUNNING) color="$GREEN" ;;
            STARTING|BACKOFF) color="$YELLOW" ;;
            *) color="$RED" ;;
        esac
        tbl_row "$prog" 34 "" "$state" 12 "$color" "${details:--}" 46 ""
    done

    echo | tee -a "$LOG_FILE"
}

# Logged-in Users (SSH only, human users, idle & session duration)
check_logged_users() {
    echo -e "${YELLOW}Logged-in Users (SSH Sessions):${RESET}" | tee -a "$LOG_FILE"

    # Get SSH sessions only, exclude system users
    SESSIONS=$(who | grep -E '\([0-9a-fA-F:.]+\)')

    if [[ -z "$SESSIONS" ]]; then
        echo -e "${GREEN}No active SSH user sessions${RESET}" | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
        return
    fi

    tbl_head "14:User" "10:TTY" "20:Login Time" "8:Idle" "12:Session" "26:From"

    echo "$SESSIONS" | while read -r user tty date time from; do
        # Idle time (from w)
        IDLE=$(w -h 2>/dev/null | awk -v t="$tty" '$2==t {print $5}')

        # Login timestamp → epoch
        LOGIN_EPOCH=$(date -d "$date $time" +%s 2>/dev/null)
        NOW_EPOCH=$(date +%s)

        # Session duration
        if [[ -n "$LOGIN_EPOCH" ]]; then
            DURATION_SEC=$((NOW_EPOCH - LOGIN_EPOCH))
            SESSION_TIME=$(printf '%02dh:%02dm' $((DURATION_SEC/3600)) $(((DURATION_SEC%3600)/60)))
        else
            SESSION_TIME="N/A"
        fi

        tbl_row "$user" 14 "" "$tty" 10 "" "$date $time" 20 "" \
                "${IDLE:-0}" 8 "" "$SESSION_TIME" 12 "" "$(echo "$from" | tr -d '()')" 26 ""
    done

    echo | tee -a "$LOG_FILE"
    echo -e "${GREEN}Total Active SSH Users: $(echo "$SESSIONS" | wc -l)${RESET}" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
}

# SSL Check
check_ssl_validity() {
    echo -e "${YELLOW}SSL Check for: $DOMAIN${RESET}" | tee -a "$LOG_FILE"

    # Reject anything that isn't a plausible hostname before it touches
    # PHP or openssl. Also strips any accidental protocol/path/port so a
    # value like "https://example.com/foo:1234" doesn't slip through.
    SSL_HOST=$(echo "$DOMAIN" | sed -E 's@^https?://@@; s@/.*@@; s@:.*@@')
    if [[ ! "$SSL_HOST" =~ ^[A-Za-z0-9.-]+$ ]]; then
        echo -e "${RED}Invalid or empty domain for SSL check: '$DOMAIN'${RESET}" | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
        return
    fi

    # PHP SSL validity check — domain is passed as argv[1], never
    # interpolated into the PHP source, so it can't break out of the
    # string or inject code.
    RESULT=$(php -r '
    $domain = $argv[1];
    $url = "https://" . $domain . "/cron-test.php";
    $ctx = stream_context_create(["ssl" => ["capture_peer_cert" => true]]);
    $fp = @fopen($url, "rb", false, $ctx);
    if (!$fp) {
        echo "false";
    } else {
        $params = stream_context_get_params($fp);
        $cert = $params["options"]["ssl"]["peer_certificate"] ?? null;
        echo is_null($cert) ? "false" : "true";
    }' "$SSL_HOST" 2>/dev/null)

    tbl_head "22:Check" "14:Status" "56:Details"

    if [[ "$RESULT" == "true" ]]; then
        tbl_row "SSL Handshake" 22 "" "Valid" 14 "$GREEN" "https://$SSL_HOST/cron-test.php reachable over TLS" 56 ""
    else
        tbl_row "SSL Handshake" 22 "" "Not Valid" 14 "$RED" "Could not establish a verified TLS connection" 56 ""
        echo | tee -a "$LOG_FILE"
        return
    fi

    # Ensure openssl is installed
    if ! ensure_installed openssl openssl openssl; then
        tbl_row "OpenSSL Tool" 22 "" "Missing" 14 "$RED" "openssl not available and could not be installed" 56 ""
        echo | tee -a "$LOG_FILE"
        return
    fi

    # Fetch certificate
    CERT_RAW=$(echo | openssl s_client \
        -servername "$SSL_HOST" \
        -connect "$SSL_HOST:443" 2>/dev/null)

    CERT_INFO=$(echo "$CERT_RAW" | openssl x509 -noout \
        -issuer -subject -startdate -enddate 2>/dev/null)

    if [[ -z "$CERT_INFO" ]]; then
        tbl_row "Certificate Fetch" 22 "" "Failed" 14 "$RED" "Failed to retrieve certificate details" 56 ""
        echo | tee -a "$LOG_FILE"
        return
    fi

    ISSUER=$(echo "$CERT_INFO" | grep issuer= | sed 's/issuer=//')
    SUBJECT=$(echo "$CERT_INFO" | grep subject= | sed 's/subject=//')
    START_DATE=$(echo "$CERT_INFO" | grep notBefore= | cut -d= -f2)
    END_DATE=$(echo "$CERT_INFO" | grep notAfter= | cut -d= -f2)
    PROTOCOL=$(echo "$CERT_RAW" | awk -F': ' '/^ *Protocol *:/ {print $2; exit}')
    CIPHER=$(echo "$CERT_RAW" | awk -F': ' '/^ *Cipher *:/ {print $2; exit}')

    EXPIRY_TS=$(date -d "$END_DATE" +%s 2>/dev/null)
    if [[ -z "$EXPIRY_TS" ]]; then
        tbl_row "Certificate Expiry" 22 "" "Unknown" 14 "$RED" "Could not parse expiry date: '$END_DATE'" 56 ""
        echo | tee -a "$LOG_FILE"
        return
    fi
    NOW_TS=$(date +%s)
    DAYS_LEFT=$(( (EXPIRY_TS - NOW_TS) / 86400 ))

    echo | tee -a "$LOG_FILE"
    echo -e "${CYAN}Certificate Details:${RESET}" | tee -a "$LOG_FILE"

    tbl_head "22:Parameter" "72:Value"
    tbl_row "Domain"      22 "" "$SSL_HOST"                72 ""
    tbl_row "Subject"     22 "" "$SUBJECT"                 72 ""
    tbl_row "Issuer (CA)" 22 "" "$ISSUER"                  72 ""
    tbl_row "Valid From"  22 "" "$START_DATE"              72 ""
    tbl_row "Valid Until" 22 "" "$END_DATE"                72 ""
    tbl_row "TLS Protocol" 22 "" "${PROTOCOL:-Unknown}"    72 ""
    tbl_row "Cipher"      22 "" "${CIPHER:-Unknown}"       72 ""

    # ---- Production SLA for SSL expiry ----
    if (( DAYS_LEFT < 0 )); then
        tbl_row "Certificate Status" 22 "" "EXPIRED ($((DAYS_LEFT * -1)) days ago)" 72 "$RED"
    elif (( DAYS_LEFT <= 15 )); then
        tbl_row "Certificate Status" 22 "" "EXPIRING SOON ($DAYS_LEFT days left)" 72 "$RED"
    elif (( DAYS_LEFT <= 30 )); then
        tbl_row "Certificate Status" 22 "" "WARNING ($DAYS_LEFT days left)" 72 "$YELLOW"
    else
        tbl_row "Certificate Status" 22 "" "OK ($DAYS_LEFT days left)" 72 "$GREEN"
    fi

    echo | tee -a "$LOG_FILE"
}

# Billing Connection Check
check_billing_connection() {
    echo -e "${YELLOW}Billing Connection Check:${RESET}" | tee -a "$LOG_FILE"

    tbl_head "44:Endpoint" "10:HTTP" "12:Status" "20:Response Time"

    for ep in "https://billing.faveohelpdesk.com" "https://license.faveohelpdesk.com"; do
        READ_OUT=$(curl -sL -o /dev/null -w "%{http_code} %{time_total}" --max-time 15 "$ep" 2>/dev/null)
        CODE=$(echo "$READ_OUT" | awk '{print $1}')
        TIME=$(echo "$READ_OUT" | awk '{printf "%.3f", $2}')

        if [[ "$CODE" =~ ^(200|301|302)$ ]]; then
            tbl_row "$ep" 44 "" "$CODE" 10 "" "Reachable" 12 "$GREEN" "${TIME}s" 20 ""
        else
            tbl_row "$ep" 44 "" "${CODE:-000}" 10 "" "Failed" 12 "$RED" "${TIME:-0}s" 20 ""
        fi
    done

    echo | tee -a "$LOG_FILE"
}

# Root Ownership Check
check_root_ownership() {
    echo -e "${YELLOW}Root-Owned Files/Folders in Faveo Directory:${RESET}" | tee -a "$LOG_FILE"

    ROOT_OWNED_ITEMS=$(find "$FAVEO_ROOT" -user root 2>/dev/null)

    if [[ -z "$ROOT_OWNED_ITEMS" ]]; then
        tbl_head "20:Check" "12:Status" "50:Details"
        tbl_row "Root-owned items" 20 "" "Clean" 12 "$GREEN" "No files/folders owned by root found" 50 ""
        echo | tee -a "$LOG_FILE"
        return
    fi

    ROOT_COUNT=$(echo "$ROOT_OWNED_ITEMS" | wc -l)

    tbl_head "20:Check" "12:Status" "50:Details"
    tbl_row "Root-owned items" 20 "" "Found" 12 "$RED" "$ROOT_COUNT item(s) owned by root" 50 ""
    echo | tee -a "$LOG_FILE"

    tbl_head "74:Path" "12:Type" "10:Perms"
    echo "$ROOT_OWNED_ITEMS" | while read -r item; do
        [[ -z "$item" ]] && continue
        if [[ -d "$item" ]]; then TYPE="directory"; else TYPE="file"; fi
        PERMS=$(stat -c "%a" "$item" 2>/dev/null)
        tbl_row "$item" 74 "$RED" "$TYPE" 12 "" "${PERMS:--}" 10 ""
    done

    echo | tee -a "$LOG_FILE"
}

check_ports() {
    echo -e "${YELLOW}Port Availability Check:${RESET}" | tee -a "$LOG_FILE"
    echo -e "${YELLOW}Ports details releated related issues.
Example:
 • Email problems → check SMTP/IMAP/POP ports
 • Web access issues → check HTTP/HTTPS ports
 • Database connectivity issues → check MySQL ports
 • LDAP connectivity issues → check LDAP/LDAPS ports
 • Websocket proxy issues → check Websocket proxy port
 • NATS issues → check NATS port
${RESET}" | tee -a "$LOG_FILE"


    # Default ports with labels
    declare -A DEFAULT_PORTS=(
        [80]="HTTP"
        [443]="HTTPS"
        [3306]="MySQL"
        [6379]="Redis"
        [7700]="Meilisearch"
        [9000]="PHP-FPM"
        [25]="SMTP-NONE"
        [465]="SMTP-SSL"
        [587]="SMTP-STARTTLS"
        [143]="IMAP-Plain/STARTTLS"
        [993]="IMAP-SSL"
        [110]="POP-Plain/STARTTLS"
        [995]="POP-SSL"
        [6001]="Websocket Proxy"
        [9235]="Nats"
        [389]="LDAP"
        [636]="LDAPS"
    )

    # Prompt user for additional/custom ports
    read -rp "Enter any additional ports to check (comma-separated, or press Enter to skip): " CUSTOM_PORTS
    if [[ -n "$CUSTOM_PORTS" ]]; then
        IFS=',' read -ra ADDITIONAL_PORTS <<< "$CUSTOM_PORTS"
        for port in "${ADDITIONAL_PORTS[@]}"; do
            port=$(echo "$port" | xargs)
            [[ -n "$port" ]] && DEFAULT_PORTS[$port]="Custom"
        done
    fi

    tbl_head "8:Port" "24:Service" "16:Internal" "42:Listening On"

    for PORT in $(printf '%s\n' "${!DEFAULT_PORTS[@]}" | sort -n); do
        LABEL=${DEFAULT_PORTS[$PORT]}

        # Internal check using ss or netstat
        if command -v ss &>/dev/null; then
            LISTEN=$(ss -tuln 2>/dev/null | awk -v p=":$PORT$" '$5 ~ p {print $5}' | paste -sd ', ' -)
        else
            LISTEN=$(netstat -tuln 2>/dev/null | awk -v p=":$PORT$" '$4 ~ p {print $4}' | paste -sd ', ' -)
        fi

        if [[ -n "$LISTEN" ]]; then
            tbl_row "$PORT" 8 "" "$LABEL" 24 "" "OPEN" 16 "$GREEN" "$LISTEN" 42 ""
        else
            tbl_row "$PORT" 8 "" "$LABEL" 24 "" "NOT LISTENING" 16 "$RED" "-" 42 ""
        fi
    done

    echo | tee -a "$LOG_FILE"
}

# Firewall Status and Whitelist Check
firewall_check() {
    echo -e "${YELLOW}Firewall Check:${RESET}" | tee -a "$LOG_FILE"

    # Summary table of every firewall tool this host may be running
    tbl_head "16:Firewall" "16:Installed" "16:Status" "42:Notes"

    if command -v csf &>/dev/null; then
        if csf -l &>/dev/null; then
            tbl_row "CSF" 16 "" "Yes" 16 "$GREEN" "active" 16 "$GREEN" "ConfigServer Firewall in use" 42 ""
        else
            tbl_row "CSF" 16 "" "Yes" 16 "$GREEN" "not running" 16 "$RED" "csf -l returned no rules" 42 ""
        fi
    else
        tbl_row "CSF" 16 "" "No" 16 "$YELLOW" "-" 16 "" "Not installed" 42 ""
    fi

    if command -v firewall-cmd &>/dev/null; then
        if systemctl is-active firewalld &>/dev/null; then
            tbl_row "Firewalld" 16 "" "Yes" 16 "$GREEN" "active" 16 "$GREEN" "Default zone: $(firewall-cmd --get-default-zone 2>/dev/null)" 42 ""
        else
            tbl_row "Firewalld" 16 "" "Yes" 16 "$GREEN" "inactive" 16 "$RED" "Service is not running" 42 ""
        fi
    else
        tbl_row "Firewalld" 16 "" "No" 16 "$YELLOW" "-" 16 "" "Not installed" 42 ""
    fi

    if command -v ufw &>/dev/null; then
        if ufw status 2>/dev/null | grep -qi "Status: active"; then
            tbl_row "UFW" 16 "" "Yes" 16 "$GREEN" "active" 16 "$GREEN" "Uncomplicated Firewall enabled" 42 ""
        else
            tbl_row "UFW" 16 "" "Yes" 16 "$GREEN" "inactive" 16 "$YELLOW" "Installed but disabled" 42 ""
        fi
    else
        tbl_row "UFW" 16 "" "No" 16 "$YELLOW" "-" 16 "" "Not installed" 42 ""
    fi

    if command -v iptables &>/dev/null; then
        IPT_COUNT=$(iptables -S 2>/dev/null | wc -l)
        tbl_row "iptables" 16 "" "Yes" 16 "$GREEN" "$IPT_COUNT rules" 16 "" "Raw netfilter rules" 42 ""
    else
        tbl_row "iptables" 16 "" "No" 16 "$YELLOW" "-" 16 "" "Not installed" 42 ""
    fi

    if command -v nft &>/dev/null; then
        NFT_COUNT=$(nft list ruleset 2>/dev/null | wc -l)
        tbl_row "nftables" 16 "" "Yes" 16 "$GREEN" "$NFT_COUNT lines" 16 "" "Raw nftables ruleset" 42 ""
    else
        tbl_row "nftables" 16 "" "No" 16 "$YELLOW" "-" 16 "" "Not installed" 42 ""
    fi

    echo | tee -a "$LOG_FILE"

    # Detailed rules of the active firewall
    if command -v csf &>/dev/null && sudo csf -l &>/dev/null; then
        echo -e "${CYAN}CSF allow rules:${RESET}" | tee -a "$LOG_FILE"
        sudo csf -l 2>/dev/null | awk '/ALLOWIN|ALLOWOUT|ACCEPT/ && /tcp|udp/ {print}' | tee -a "$LOG_FILE"

    elif systemctl is-active firewalld &>/dev/null; then
        echo -e "${CYAN}Firewalld configuration:${RESET}" | tee -a "$LOG_FILE"
        tbl_head "20:Setting" "72:Value"
        sudo firewall-cmd --list-all 2>/dev/null | tail -n +2 | while IFS=':' read -r fkey fval; do
            fkey=$(echo "$fkey" | xargs)
            fval=$(echo "$fval" | xargs)
            [[ -z "$fkey" ]] && continue
            tbl_row "$fkey" 20 "" "${fval:--}" 72 ""
        done

    elif command -v ufw &>/dev/null && sudo ufw status 2>/dev/null | grep -qi "Status: active"; then
        echo -e "${CYAN}UFW rules:${RESET}" | tee -a "$LOG_FILE"
        tbl_head "8:Num" "30:To" "12:Action" "36:From"
        sudo ufw status numbered 2>/dev/null | grep -E '^\[' | while read -r line; do
            NUM=$(echo "$line" | sed -E 's/^\[ *([0-9]+)\].*/\1/')
            REST=$(echo "$line" | sed -E 's/^\[ *[0-9]+\] *//')
            TO=$(echo "$REST" | awk -F'  +' '{print $1}')
            ACT=$(echo "$REST" | awk -F'  +' '{print $2}')
            FROM=$(echo "$REST" | awk -F'  +' '{print $3}')
            if echo "$ACT" | grep -qi "allow"; then color="$GREEN"; else color="$RED"; fi
            tbl_row "$NUM" 8 "" "$TO" 30 "" "$ACT" 12 "$color" "$FROM" 36 ""
        done

    elif command -v iptables &>/dev/null; then
        echo -e "${CYAN}iptables rules:${RESET}" | tee -a "$LOG_FILE"
        IPTABLES_RULES=$(sudo iptables -L -n -v 2>/dev/null | grep -E "ACCEPT|DROP")
        if [[ -z "$IPTABLES_RULES" ]]; then
            echo -e "${RED}No iptables rules found.${RESET}" | tee -a "$LOG_FILE"
        else
            tbl_head "12:Target" "8:Proto" "24:Source" "24:Destination" "24:Ports/Extra"
            echo "$IPTABLES_RULES" | while read -r pkts bytes target prot opt iface_in iface_out src dst extra; do
                if [[ "$target" == "ACCEPT" ]]; then color="$GREEN"; else color="$RED"; fi
                tbl_row "$target" 12 "$color" "$prot" 8 "" "$src" 24 "" "$dst" 24 "" "${extra:--}" 24 ""
            done
        fi

    elif command -v nft &>/dev/null; then
        echo -e "${CYAN}nftables rules:${RESET}" | tee -a "$LOG_FILE"
        sudo nft list ruleset | tee -a "$LOG_FILE"

    else
        echo -e "${RED}No firewall tools found (csf, firewalld, ufw, iptables, nft).${RESET}" | tee -a "$LOG_FILE"
    fi

    echo | tee -a "$LOG_FILE"
}

# Disk I/O Read and Write check
check_disk_io() {

    DEFAULT_DIR="/var/lib/mysql"
    IO_COUNT=20
    SLA_LATENCY_MS=10

    echo -e "${YELLOW}Disk IO Check (ioping):${RESET}" | tee -a "$LOG_FILE"

    # ---- Ask user for directory ----
    read -rp "Enter directory to test [default: $DEFAULT_DIR]: " TARGET_DIR
    TARGET_DIR=${TARGET_DIR:-$DEFAULT_DIR}

    if [[ ! -d "$TARGET_DIR" ]]; then
        echo -e "${RED}Directory $TARGET_DIR does not exist${RESET}" | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
        return 1
    fi

    # Install ioping and bc if missing
    if ! ensure_installed ioping; then
        echo -e "${RED}ioping not available and could not be installed on this OS${RESET}" | tee -a "$LOG_FILE"
        return 1
    fi
    if ! ensure_installed bc; then
        echo -e "${YELLOW}bc not available; latency will be shown but the SLA pass/fail check will be skipped.${RESET}" | tee -a "$LOG_FILE"
    fi

    # READ TEST
    echo -e "${CYAN}Read latency test:${RESET}" | tee -a "$LOG_FILE"

    READ_OUT=$(ioping -c "$IO_COUNT" "$TARGET_DIR" 2>/dev/null | sed -n '/ioping statistics/,$p')
    echo "$READ_OUT" | tee -a "$LOG_FILE"

    READ_AVG=$(echo "$READ_OUT" | awk -F'[=/ ]+' '/min\/avg\/max/ {print $4}' | sed 's/ms//')

    # WRITE TEST
    echo -e "${CYAN}Write latency test:${RESET}" | tee -a "$LOG_FILE"

    WRITE_OUT=$(ioping -RW -c "$IO_COUNT" "$TARGET_DIR" 2>/dev/null | sed -n '/ioping statistics/,$p')
    echo "$WRITE_OUT" | tee -a "$LOG_FILE"

    WRITE_AVG=$(echo "$WRITE_OUT" | awk -F'[=/ ]+' '/min\/avg\/max/ {print $4}' | sed 's/ms//')

    echo | tee -a "$LOG_FILE"
    echo -e "${CYAN}Disk I/O Summary (Target: $TARGET_DIR):${RESET}" | tee -a "$LOG_FILE"

    tbl_head "18:Test" "18:Avg Latency" "16:SLA Limit" "14:Result"

    # SLA CHECK
    if [[ -z "$READ_AVG" || -z "$WRITE_AVG" ]]; then
        tbl_row "Read latency"  18 "" "${READ_AVG:-N/A}"  18 "" "${SLA_LATENCY_MS} ms" 16 "" "Not parsed" 14 "$YELLOW"
        tbl_row "Write latency" 18 "" "${WRITE_AVG:-N/A}" 18 "" "${SLA_LATENCY_MS} ms" 16 "" "Not parsed" 14 "$YELLOW"
        echo -e "${YELLOW}Could not parse ioping latency output; skipping SLA comparison.${RESET}" | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
        return
    fi

    if ! command -v bc &>/dev/null; then
        tbl_row "Read latency"  18 "" "${READ_AVG} ms"  18 "" "${SLA_LATENCY_MS} ms" 16 "" "Not checked" 14 "$YELLOW"
        tbl_row "Write latency" 18 "" "${WRITE_AVG} ms" 18 "" "${SLA_LATENCY_MS} ms" 16 "" "Not checked" 14 "$YELLOW"
        echo -e "${YELLOW}bc not available; skipping SLA comparison.${RESET}" | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
        return
    fi

    FAIL=0

    if (( $(echo "$READ_AVG > $SLA_LATENCY_MS" | bc -l) )); then
        tbl_row "Read latency" 18 "" "${READ_AVG} ms" 18 "$RED" "${SLA_LATENCY_MS} ms" 16 "" "FAILED" 14 "$RED"
        FAIL=1
    else
        tbl_row "Read latency" 18 "" "${READ_AVG} ms" 18 "$GREEN" "${SLA_LATENCY_MS} ms" 16 "" "PASSED" 14 "$GREEN"
    fi

    if (( $(echo "$WRITE_AVG > $SLA_LATENCY_MS" | bc -l) )); then
        tbl_row "Write latency" 18 "" "${WRITE_AVG} ms" 18 "$RED" "${SLA_LATENCY_MS} ms" 16 "" "FAILED" 14 "$RED"
        FAIL=1
    else
        tbl_row "Write latency" 18 "" "${WRITE_AVG} ms" 18 "$GREEN" "${SLA_LATENCY_MS} ms" 16 "" "PASSED" 14 "$GREEN"
    fi

    if [[ "$FAIL" -eq 0 ]]; then
        echo -e "${GREEN}Disk latency within SLA for production workload${RESET}" | tee -a "$LOG_FILE"
    else
        echo -e "${RED}Disk latency breached the ${SLA_LATENCY_MS} ms production SLA${RESET}" | tee -a "$LOG_FILE"
    fi

    echo | tee -a "$LOG_FILE"
}

# Top concuming processes check
check_top_processes() {
    echo -e "${YELLOW}Top CPU / Memory Processes (Production SLA-aware):${RESET}" | tee -a "$LOG_FILE"

    CPU_WARN=70
    CPU_FAIL=90
    MEM_WARN=70
    MEM_FAIL=90

    print_proc_table() {
        local sort_key="$1" warn="$2" fail="$3" metric="$4"

        tbl_head "8:PID" "8:CPU%" "8:MEM%" "10:Status" "8:User" "46:Command"

        ps -eo pid,pcpu,pmem,user,args --sort=-"$sort_key" --no-headers 2>/dev/null | head -n 10 | \
        while read -r pid cpu mem user cmd; do
            if [[ "$metric" == "cpu" ]]; then val="$cpu"; else val="$mem"; fi
            val_int=${val%%.*}
            [[ "$val_int" =~ ^[0-9]+$ ]] || val_int=0

            if (( val_int > fail )); then
                status="CRITICAL"; color="$RED"
            elif (( val_int > warn )); then
                status="WARNING"; color="$YELLOW"
            else
                status="OK"; color="$GREEN"
            fi

            tbl_row "$pid" 8 "" "$cpu" 8 "" "$mem" 8 "" "$status" 10 "$color" \
                    "$user" 8 "" "$cmd" 46 ""
        done
    }

    echo -e "${CYAN}Top 10 processes by CPU usage:${RESET}" | tee -a "$LOG_FILE"
    print_proc_table pcpu "$CPU_WARN" "$CPU_FAIL" cpu

    echo | tee -a "$LOG_FILE"
    echo -e "${CYAN}Top 10 processes by Memory usage:${RESET}" | tee -a "$LOG_FILE"
    print_proc_table pmem "$MEM_WARN" "$MEM_FAIL" mem

    echo | tee -a "$LOG_FILE"
}

# Network Latency check
check_network() {
    echo -e "${YELLOW}Network Connectivity Test:${RESET}" | tee -a "$LOG_FILE"

    # Hosts to test
    HOSTS=(
        "8.8.8.8"
        "google.com"
        "billing.faveohelpdesk.com"
        "license.faveohelpdesk.com"
    )

    SLA_OK=50      # ms
    SLA_WARN=100  # ms

    HAVE_BC=false
    if ensure_installed bc; then
        HAVE_BC=true
    else
        echo -e "${YELLOW}bc not available; latency will be shown but not classified against SLA thresholds.${RESET}" | tee -a "$LOG_FILE"
    fi

    tbl_head "34:Host" "14:Status" "16:Avg Latency" "28:SLA (OK<=50ms, Warn<=100ms)"

    for host in "${HOSTS[@]}"; do

        # Run ping
        PING_OUTPUT=$(ping -c2 -W2 "$host" 2>/dev/null)
        if [[ $? -ne 0 ]]; then
            tbl_row "$host" 34 "" "UNREACHABLE" 14 "$RED" "-" 16 "" "Failed" 28 "$RED"
            continue
        fi

        # Extract avg latency (rtt min/avg/max/mdev line)
        AVG_LATENCY=$(echo "$PING_OUTPUT" | awk -F '/' '/rtt|round-trip/ {print $5}')

        if [[ -z "$AVG_LATENCY" ]]; then
            tbl_row "$host" 34 "" "Reachable" 14 "$GREEN" "Unknown" 16 "" "Latency not parsed" 28 "$YELLOW"
            continue
        fi

        if [[ "$HAVE_BC" != true ]]; then
            tbl_row "$host" 34 "" "Reachable" 14 "$GREEN" "${AVG_LATENCY} ms" 16 "" "Not classified (no bc)" 28 "$CYAN"
            continue
        fi

        if (( $(echo "$AVG_LATENCY <= $SLA_OK" | bc -l) )); then
            tbl_row "$host" 34 "" "Reachable" 14 "$GREEN" "${AVG_LATENCY} ms" 16 "$GREEN" "OK" 28 "$GREEN"
        elif (( $(echo "$AVG_LATENCY <= $SLA_WARN" | bc -l) )); then
            tbl_row "$host" 34 "" "Reachable" 14 "$GREEN" "${AVG_LATENCY} ms" 16 "$YELLOW" "WARNING" 28 "$YELLOW"
        else
            tbl_row "$host" 34 "" "Reachable" 14 "$GREEN" "${AVG_LATENCY} ms" 16 "$RED" "SLOW - SLA breached" 28 "$RED"
        fi
    done

    echo | tee -a "$LOG_FILE"
}

# Faveo File size check
check_faveo_storage() {
    echo -e "${YELLOW}Faveo Storage Usage:${RESET}" | tee -a "$LOG_FILE"

    # Faveo root directory
    FAVEO_ROOT=${FAVEO_ROOT:-/var/www/faveo}

    # MySQL database folder size
    read -p "Enter MySQL datadir (default: /var/lib/mysql): " MYSQL_DIR
    MYSQL_DIR=${MYSQL_DIR:-/var/lib/mysql}

    # Fetch DB name
    DB_NAME=$(grep -E '^DB_DATABASE=' "$FAVEO_ROOT/.env" 2>/dev/null \
        | head -n1 \
        | cut -d '=' -f2- \
        | tr -d '"' \
        | tr -d "'")

    DB_PATH="$MYSQL_DIR/$DB_NAME"

    tbl_head "26:Item" "46:Path" "12:Size" "12:Status"

    if [[ -d "$FAVEO_ROOT" ]]; then
        DIR_SIZE=$(du -sh "$FAVEO_ROOT" 2>/dev/null | awk '{print $1}')
        tbl_row "Faveo Directory" 26 "" "$FAVEO_ROOT" 46 "" "${DIR_SIZE:-N/A}" 12 "" "Found" 12 "$GREEN"
    else
        tbl_row "Faveo Directory" 26 "" "$FAVEO_ROOT" 46 "" "-" 12 "" "Missing" 12 "$RED"
    fi

    if [[ -d "$FAVEO_ROOT/storage" ]]; then
        STORAGE_SIZE=$(du -sh "$FAVEO_ROOT/storage" 2>/dev/null | awk '{print $1}')
        tbl_row "Faveo Storage" 26 "" "$FAVEO_ROOT/storage" 46 "" "${STORAGE_SIZE:-N/A}" 12 "" "Found" 12 "$GREEN"
    else
        tbl_row "Faveo Storage" 26 "" "$FAVEO_ROOT/storage" 46 "" "-" 12 "" "Missing" 12 "$RED"
    fi

    if [[ -d "$FAVEO_ROOT/storage/logs" ]]; then
        LOG_SIZE=$(du -sh "$FAVEO_ROOT/storage/logs" 2>/dev/null | awk '{print $1}')
        tbl_row "Laravel Logs" 26 "" "$FAVEO_ROOT/storage/logs" 46 "" "${LOG_SIZE:-N/A}" 12 "" "Found" 12 "$GREEN"
    fi

    tbl_row "MySQL Data Dir" 26 "" "$MYSQL_DIR" 46 "" "$(du -sh "$MYSQL_DIR" 2>/dev/null | awk '{print $1}')" 12 "" "-" 12 ""

    if [[ -z "$DB_NAME" ]]; then
        tbl_row "Database folder" 26 "" "DB_DATABASE not found in .env" 46 "" "-" 12 "" "Unknown" 12 "$RED"
    elif [[ -d "$DB_PATH" ]]; then
        DB_SIZE=$(du -sh "$DB_PATH" 2>/dev/null | awk '{print $1}')
        tbl_row "Database ($DB_NAME)" 26 "" "$DB_PATH" 46 "" "${DB_SIZE:-N/A}" 12 "" "Found" 12 "$GREEN"
    else
        tbl_row "Database ($DB_NAME)" 26 "" "$DB_PATH" 46 "" "-" 12 "" "Not found" 12 "$RED"
    fi

    echo | tee -a "$LOG_FILE"
}

# PHP Config Check
check_php_config() {
    echo -e "${YELLOW}PHP Configuration Check:${RESET}" | tee -a "$LOG_FILE"

    if [[ ${#PHP_INI_FILES[@]} -eq 0 ]]; then
        echo -e "${RED}No PHP ini files found (PHP version could not be detected, or PHP is not installed).${RESET}" | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
        return
    fi

    PHP_FILES=()
    PHP_LABELS=()
    for php_file in "${PHP_INI_FILES[@]}"; do
        if [[ ! -f "$php_file" ]]; then
            echo -e "${RED}$php_file not found${RESET}" | tee -a "$LOG_FILE"
            continue
        fi
        PHP_FILES+=("$php_file")
        # /etc/php/8.2/fpm/php.ini -> fpm ; /etc/php.ini -> php.ini
        label=$(basename "$(dirname "$php_file")")
        [[ "$label" == "etc" ]] && label="global"
        PHP_LABELS+=("$label")
    done

    if [[ ${#PHP_FILES[@]} -eq 0 ]]; then
        echo | tee -a "$LOG_FILE"
        return
    fi

    # Legend: which SAPI maps to which ini file
    tbl_head "12:SAPI" "80:Configuration File"
    for i in "${!PHP_FILES[@]}"; do
        tbl_row "${PHP_LABELS[$i]}" 12 "" "${PHP_FILES[$i]}" 80 ""
    done
    echo | tee -a "$LOG_FILE"

    REQUIRED_KEYS=(
        file_uploads
        max_file_uploads
        allow_url_fopen
        short_open_tag
        memory_limit
        cgi.fix_pathinfo
        upload_max_filesize
        post_max_size
        max_execution_time
        max_input_vars
        max_input_time
        date.timezone
    )

    # Header: one column per detected ini file
    HEAD_SPEC=("26:Parameter")
    for label in "${PHP_LABELS[@]}"; do
        HEAD_SPEC+=("20:$label")
    done
    tbl_head "${HEAD_SPEC[@]}"

    for key in "${REQUIRED_KEYS[@]}"; do
        ROW_ARGS=("$key" 26 "")
        for php_file in "${PHP_FILES[@]}"; do
            value=$(grep -Ei "^[[:space:]]*${key}[[:space:]]*=" "$php_file" 2>/dev/null \
                    | grep -v '^;' \
                    | tail -n 1 \
                    | awk -F= '{print $2}' \
                    | xargs)

            if [[ -z "$value" ]]; then
                ROW_ARGS+=("Not set" 20 "$RED")
            else
                ROW_ARGS+=("$value" 20 "$GREEN")
            fi
        done
        tbl_row "${ROW_ARGS[@]}"
    done

    echo | tee -a "$LOG_FILE"

    # PHP-FPM pool tuning values (process manager sizing)
    if [[ ${#PHP_FPM_CONF_FILES[@]} -gt 0 ]]; then
        echo -e "${CYAN}PHP-FPM Pool Configuration:${RESET}" | tee -a "$LOG_FILE"
        tbl_head "30:Parameter" "20:Value" "42:Source File"

        for key in pm pm.max_children pm.start_servers pm.min_spare_servers pm.max_spare_servers pm.max_requests request_terminate_timeout; do
            src=$(grep -RlsE "^[[:space:]]*${key}[[:space:]]*=" "${PHP_FPM_CONF_FILES[@]}" 2>/dev/null | tail -n 1)
            val=$(grep -RhsE "^[[:space:]]*${key}[[:space:]]*=" "${PHP_FPM_CONF_FILES[@]}" 2>/dev/null \
                  | grep -v '^;' \
                  | tail -n 1 \
                  | awk -F= '{print $2}' \
                  | xargs)

            if [[ -z "$val" ]]; then
                tbl_row "$key" 30 "" "Not set" 20 "$YELLOW" "-" 42 ""
            else
                tbl_row "$key" 30 "" "$val" 20 "$GREEN" "${src:--}" 42 ""
            fi
        done

        echo | tee -a "$LOG_FILE"
    fi
}

# PHP Extensions Check
check_php_extensions() {
    echo -e "${YELLOW}PHP Extensions Check:${RESET}" | tee -a "$LOG_FILE"

    if ! command -v php &>/dev/null; then
        echo -e "${RED}PHP CLI not found; extension check cannot run.${RESET}" | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
        return
    fi

    # Modules loaded by the CLI SAPI (lower-cased for easy matching)
    PHP_MODULES=$(php -m 2>/dev/null | tr '[:upper:]' '[:lower:]')

    # Build the distro-specific package name for a given extension suffix.
    # Debian/Ubuntu -> php8.2-curl ; RHEL family -> php-curl
    ext_pkg_name() {
        local suffix="$1"
        [[ "$suffix" == "-" ]] && { echo "-"; return; }
        case "$ID" in
            ubuntu|debian)
                if [[ "$suffix" == "core" ]]; then
                    echo "php${PHP_VERSION}"
                else
                    echo "php${PHP_VERSION}-${suffix}"
                fi
                ;;
            rhel|centos|rocky|almalinux|fedora)
                if [[ "$suffix" == "core" ]]; then
                    echo "php"
                else
                    echo "php-${suffix}"
                fi
                ;;
            *)
                echo "php-${suffix}"
                ;;
        esac
    }

    ext_pkg_installed() {
        local pkg="$1"
        [[ "$pkg" == "-" ]] && return 0
        case "$ID" in
            ubuntu|debian)
                dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed"
                ;;
            rhel|centos|rocky|almalinux|fedora)
                rpm -q "$pkg" &>/dev/null
                ;;
            *)
                return 1
                ;;
        esac
    }

    ext_mod_loaded() {
        local mod="$1"
        [[ "$mod" == "-" ]] && return 0
        echo "$PHP_MODULES" | grep -qx "$mod"
    }

    # Label | package suffix | php -m module name | requirement
    EXT_LIST=(
        "PHP Core|core|core|Required"
        "CLI SAPI|cli|-|Required"
        "FPM SAPI|fpm|-|Required"
        "MySQL Driver|mysql|mysqli|Required"
        "MySQL Native Driver|-|mysqlnd|Required"
        "PDO|-|pdo|Required"
        "PDO MySQL|-|pdo_mysql|Required"
        "MBString|mbstring|mbstring|Required"
        "XML|xml|xml|Required"
        "SimpleXML|-|simplexml|Required"
        "DOM|-|dom|Required"
        "cURL|curl|curl|Required"
        "ZIP|zip|zip|Required"
        "GD|gd|gd|Required"
        "Intl|intl|intl|Required"
        "BCMath|bcmath|bcmath|Required"
        "OpenSSL|-|openssl|Required"
        "JSON|-|json|Required"
        "Tokenizer|-|tokenizer|Required"
        "Ctype|-|ctype|Required"
        "Fileinfo|-|fileinfo|Required"
        "Iconv|-|iconv|Required"
        "Session|-|session|Required"
        "Filter|-|filter|Required"
        "IMAP|imap|imap|Required"
        "LDAP|ldap|ldap|Optional"
        "SOAP|soap|soap|Optional"
        "Redis|redis|redis|Optional"
        "Memcached|memcached|memcached|Optional"
        "OPcache|opcache|zend opcache|Optional"
        "POSIX|-|posix|Optional"
        "Process Control|-|pcntl|Optional"
        "Exif|-|exif|Optional"
        "Sodium|-|sodium|Optional"
        "GMP|gmp|gmp|Optional"
    )

    MISSING_REQUIRED=()
    MISSING_OPTIONAL=()

    tbl_head "22:Component" "22:Package" "14:Pkg State" "18:Module" "12:Requirement" "10:Status"

    for entry in "${EXT_LIST[@]}"; do
        IFS='|' read -r LABEL SUFFIX MODULE REQ <<< "$entry"

        PKG=$(ext_pkg_name "$SUFFIX")

        if [[ "$PKG" == "-" ]]; then
            PKG_TXT="built-in"
            PKG_COLOR="$CYAN"
            PKG_OK=true
        elif ext_pkg_installed "$PKG"; then
            PKG_TXT="installed"
            PKG_COLOR="$GREEN"
            PKG_OK=true
        else
            PKG_TXT="missing"
            PKG_COLOR="$RED"
            PKG_OK=false
        fi

        if [[ "$MODULE" == "-" ]]; then
            MOD_TXT="n/a"
            MOD_COLOR="$CYAN"
            MOD_OK=true
        elif ext_mod_loaded "$MODULE"; then
            MOD_TXT="loaded"
            MOD_COLOR="$GREEN"
            MOD_OK=true
        else
            MOD_TXT="not loaded"
            MOD_COLOR="$RED"
            MOD_OK=false
        fi

        if [[ "$PKG_OK" == true && "$MOD_OK" == true ]]; then
            STATUS="OK"
            STATUS_COLOR="$GREEN"
        elif [[ "$REQ" == "Required" ]]; then
            STATUS="MISSING"
            STATUS_COLOR="$RED"
            MISSING_REQUIRED+=("$LABEL")
        else
            STATUS="ABSENT"
            STATUS_COLOR="$YELLOW"
            MISSING_OPTIONAL+=("$LABEL")
        fi

        REQ_COLOR=""
        [[ "$REQ" == "Optional" ]] && REQ_COLOR="$CYAN"

        tbl_row "$LABEL" 22 "" "$PKG" 22 "" "$PKG_TXT" 14 "$PKG_COLOR" \
                "$MOD_TXT" 18 "$MOD_COLOR" "$REQ" 12 "$REQ_COLOR" "$STATUS" 10 "$STATUS_COLOR"
    done

    echo | tee -a "$LOG_FILE"

    # Summary
    tbl_head "26:Summary" "12:Count" "56:Components"

    if [[ ${#MISSING_REQUIRED[@]} -eq 0 ]]; then
        tbl_row "Missing (required)" 26 "" "0" 12 "$GREEN" "None - all required extensions present" 56 "$GREEN"
    else
        tbl_row "Missing (required)" 26 "" "${#MISSING_REQUIRED[@]}" 12 "$RED" "${MISSING_REQUIRED[*]}" 56 "$RED"
    fi

    if [[ ${#MISSING_OPTIONAL[@]} -eq 0 ]]; then
        tbl_row "Missing (optional)" 26 "" "0" 12 "$GREEN" "None" 56 ""
    else
        tbl_row "Missing (optional)" 26 "" "${#MISSING_OPTIONAL[@]}" 12 "$YELLOW" "${MISSING_OPTIONAL[*]}" 56 ""
    fi

    tbl_row "Total modules loaded" 26 "" "$(php -m 2>/dev/null | grep -cvE '^\[|^$')" 12 "" "php -m (CLI SAPI)" 56 ""

    echo | tee -a "$LOG_FILE"

    # Install hint for anything required that is missing
    if [[ ${#MISSING_REQUIRED[@]} -gt 0 ]]; then
        HINT_PKGS=""
        for entry in "${EXT_LIST[@]}"; do
            IFS='|' read -r LABEL SUFFIX MODULE REQ <<< "$entry"
            [[ "$REQ" != "Required" ]] && continue
            [[ "$SUFFIX" == "-" ]] && continue
            [[ " ${MISSING_REQUIRED[*]} " == *" $LABEL "* ]] || continue
            HINT_PKGS+="$(ext_pkg_name "$SUFFIX") "
        done

        if [[ -n "$HINT_PKGS" ]]; then
            case "$ID" in
                ubuntu|debian) echo -e "${CYAN}Install hint:${RESET} apt-get install -y $HINT_PKGS" | tee -a "$LOG_FILE" ;;
                *)             echo -e "${CYAN}Install hint:${RESET} yum install -y $HINT_PKGS" | tee -a "$LOG_FILE" ;;
            esac
        fi
        echo -e "${YELLOW}Note: some required extensions are compiled in; verify with 'php -i' if a package looks missing but the module is loaded.${RESET}" | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
    fi

    # Extensions are enabled per SAPI: an extension loaded for the CLI is not
    # automatically loaded for FPM (and vice versa). Report only the mismatches.
    CLI_CONF="/etc/php/${PHP_VERSION}/cli/conf.d"
    FPM_CONF="/etc/php/${PHP_VERSION}/fpm/conf.d"

    if [[ -n "$PHP_VERSION" && -d "$CLI_CONF" && -d "$FPM_CONF" ]]; then
        echo -e "${CYAN}CLI vs FPM enabled extensions:${RESET}" | tee -a "$LOG_FILE"
        tbl_head "34:Extension" "18:CLI" "18:FPM"

        list_sapi_mods() {
            find "$1" -maxdepth 1 -name '*.ini' -printf '%f\n' 2>/dev/null \
                | sed -E 's/^[0-9]+-//; s/\.ini$//' \
                | sort -u
        }

        SAPI_DIFF=$(comm -3 <(list_sapi_mods "$CLI_CONF") <(list_sapi_mods "$FPM_CONF"))

        if [[ -z "$SAPI_DIFF" ]]; then
            tbl_row "All extensions" 34 "" "enabled" 18 "$GREEN" "enabled" 18 "$GREEN"
        else
            echo "$SAPI_DIFF" | while IFS= read -r modline; do
                [[ -z "${modline//[[:space:]]/}" ]] && continue
                if [[ "$modline" == $'\t'* ]]; then
                    tbl_row "${modline#$'\t'}" 34 "" "not enabled" 18 "$YELLOW" "enabled" 18 "$GREEN"
                else
                    tbl_row "$modline" 34 "" "enabled" 18 "$GREEN" "not enabled" 18 "$YELLOW"
                fi
            done
        fi

        echo | tee -a "$LOG_FILE"
    fi
}

# Timeout Check
check_request_timeouts() {
    echo -e "${YELLOW}Request Timeout Check:${RESET}" | tee -a "$LOG_FILE"

    tbl_head "14:Component" "34:Parameter" "24:Value" "24:Source"

    # PHP-FPM TIMEOUTS
    if [[ ${#PHP_FPM_CONF_FILES[@]} -eq 0 ]]; then
        tbl_row "PHP-FPM" 14 "" "config file" 34 "" "Not found" 24 "$RED" "-" 24 ""
    else
        for key in request_terminate_timeout max_execution_time; do
            src=$(grep -RlsEi "^[[:space:]]*${key}[[:space:]]*=" "${PHP_FPM_CONF_FILES[@]}" 2>/dev/null | tail -n 1)
            val=$(grep -RhsEi "^[[:space:]]*${key}[[:space:]]*=" "${PHP_FPM_CONF_FILES[@]}" 2>/dev/null \
                  | grep -v '^;' \
                  | tail -n 1 \
                  | awk -F= '{print $2}' \
                  | xargs)

            if [[ -z "$val" ]]; then
                tbl_row "PHP-FPM" 14 "" "$key" 34 "" "Not set" 24 "$RED" "-" 24 ""
            else
                tbl_row "PHP-FPM" 14 "" "$key" 34 "" "$val" 24 "$GREEN" "$(basename "${src:--}")" 24 ""
            fi
        done
    fi

    # NGINX TIMEOUTS
    if command -v nginx &>/dev/null; then
        for key in fastcgi_read_timeout proxy_read_timeout send_timeout client_max_body_size; do
            NGINX_VAL=$(nginx -T 2>/dev/null | grep -E "^\s*${key}\s" | awk '{print $NF}' | tr -d ';' | tail -n 1)
            if [[ -n "$NGINX_VAL" ]]; then
                tbl_row "Nginx" 14 "" "$key" 34 "" "$NGINX_VAL" 24 "$GREEN" "nginx -T" 24 ""
            else
                tbl_row "Nginx" 14 "" "$key" 34 "" "Not set (default)" 24 "$YELLOW" "nginx -T" 24 ""
            fi
        done
    fi

    # APACHE TIMEOUTS
    if command -v apache2 &>/dev/null || command -v httpd &>/dev/null; then
        APACHE_CONF=$(apachectl -t -D DUMP_INCLUDES 2>/dev/null | awk '{print $1}')

        APACHE_ROWS=$(grep -RhsEi "^(Timeout|ProxyTimeout|FcgidIOTimeout|KeepAliveTimeout)" $APACHE_CONF 2>/dev/null \
            | grep -v '^#' \
            | awk '{print $1"="$2}' \
            | sort -u)

        if [[ -z "$APACHE_ROWS" ]]; then
            tbl_row "Apache" 14 "" "Timeout directives" 34 "" "Not set (defaults)" 24 "$YELLOW" "-" 24 ""
        else
            echo "$APACHE_ROWS" | while IFS='=' read -r akey aval; do
                [[ -z "$akey" ]] && continue
                tbl_row "Apache" 14 "" "$akey" 34 "" "${aval:--}" 24 "$GREEN" "apache config" 24 ""
            done
        fi
    fi

    echo | tee -a "$LOG_FILE"
}

# Footer
print_footer() {
    echo -e "\n--------------------------------------------------" | tee -a "$LOG_FILE"
    echo -e "${CYAN}Script by Faveo Helpdesk | support@faveohelpdesk.com${RESET}" | tee -a "$LOG_FILE"
    echo -e "${GREEN}Execution complete.${RESET}" | tee -a "$LOG_FILE"
}

# Menu
print_menu() {
    echo -e "${YELLOW}Select an option to run:${RESET}"
    sleep 0.05
    echo "1) Run all checks"
    sleep 0.05
    echo "2) SSL Check"
    sleep 0.05
    echo "3) System Info"
    sleep 0.05
    echo "4) Service Status"
    sleep 0.05
    echo "5) Faveo Info"
    sleep 0.05
    echo "6) Cron Jobs"
    sleep 0.05
    echo "7) Supervisor Jobs"
    sleep 0.05
    echo "8) Logged-in Users"
    sleep 0.05
    echo "9) Billing Connection"
    sleep 0.05
    echo "10) Root-Owned Files in Faveo Directory"
    sleep 0.05
    echo "11) Check if Required Ports are Open"
    sleep 0.05
    echo "12) Firewall check"
    sleep 0.05
    echo "13) Check Disk I/O"
    sleep 0.05
    echo "14) Top MEM and CPU Consumptions"
    sleep 0.05
    echo "15) Network Latency"
    sleep 0.05
    echo "16) Check Faveo Size"
    sleep 0.05
    echo "17) PHP Config Values"
    sleep 0.05
    echo "18) Check Timeout Settings"
    sleep 0.05
    echo "19) PHP Extensions Check"
    sleep 0.05
    echo "0) Exit"
    sleep 0.05
}

# Run based on selection
while true; do
    print_menu
    read -rp "Enter your choice [0-19]: " CHOICE
    case "$CHOICE" in
        1)
            print_header
            validate_domain
            check_ssl_validity
            get_system_info
            get_service_status
            check_faveo_info
            check_cron_jobs
            check_supervisor_jobs
            check_logged_users
            check_billing_connection
            check_root_ownership
            check_ports
            firewall_check
            check_disk_io
            check_top_processes
            check_network
            check_faveo_storage
            check_php_config
            check_php_extensions
            check_request_timeouts
            print_footer
            break
            ;;
        2) print_header; validate_domain; check_ssl_validity; print_footer; break ;;
        3) print_header; get_system_info; print_footer; break ;;
        4) print_header; get_service_status; print_footer; break ;;
        5) print_header; check_faveo_info; print_footer; break ;;
        6) print_header; check_cron_jobs; print_footer; break ;;
        7) print_header; check_supervisor_jobs; print_footer; break ;;
        8) print_header; check_logged_users; print_footer; break ;;
        9) print_header; check_billing_connection; print_footer; break ;;
        10) print_header; check_root_ownership; print_footer; break ;;
        11) print_header; check_ports; print_footer; break ;;
        12) print_header; firewall_check; print_footer; break ;;
        13) print_header; check_disk_io; print_footer; break ;;
        14) print_header; check_top_processes; print_footer; break ;;
        15) print_header; check_network; print_footer; break ;;
        16) print_header; check_faveo_storage; print_footer; break ;;
        17) print_header; check_php_config; print_footer; break ;;
        18) print_header; check_request_timeouts; print_footer; break ;;
        19) print_header; check_php_extensions; print_footer; break ;;
        0) echo -e "${CYAN}Exiting...${RESET}"; exit 0 ;;
        *) echo -e "${RED}Invalid option. Please try again.${RESET}" ;;
    esac
done

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
        echo "&red This installer needs to be run with 'bash', not 'sh'. $reset";
        exit 1
fi

# Checking for the Super User.

if [[ $EUID -ne 0 ]]; then
   echo -e "$red This script must be run as root $reset";
   exit 1
fi

# Root check
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root${RESET}"
    exit 1
fi

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
        if (( VERSION_ID < 11 )); then
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

    echo "Distro: $(lsb_release -ds 2>/dev/null || awk -F= '/^PRETTY_NAME/{print $2}' /etc/os-release | tr -d '"')" | tee -a "$LOG_FILE"
    echo "Kernel: $(uname -r)" | tee -a "$LOG_FILE"
    echo "Uptime: $(uptime -p)" | tee -a "$LOG_FILE"
    echo "Load Avg: $(cut -d ' ' -f1-3 /proc/loadavg)" | tee -a "$LOG_FILE"
    echo "vCPU Cores: $(nproc)" | tee -a "$LOG_FILE"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $3 " used / " $2 ", Available: " $7}')" | tee -a "$LOG_FILE"
    echo -e "${CYAN}Disk Usage (All Mounted Partitions):${RESET}" | tee -a "$LOG_FILE"
    df -h --output=source,size,used,avail,pcent,target | tee -a "$LOG_FILE"

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
                httpd mariadb redis supervisord php-fpm
                crond nginx meilisearch node npm csf
            )
            ;;
        *)
            SERVICES=()
            ;;
    esac

    # CLI-only tools (not systemd services)
    CLI_TOOLS=(node npm csf)

    echo -e "${YELLOW}Service Status:${RESET}" | tee -a "$LOG_FILE"

    for svc in "${SERVICES[@]}"; do

        # CLI tools handling
        if [[ " ${CLI_TOOLS[*]} " =~ " $svc " ]]; then
            if command -v "$svc" >/dev/null 2>&1; then
                echo -e "$svc: ${GREEN}installed${RESET}" | tee -a "$LOG_FILE"
            else
                echo -e "$svc: ${RED}not installed${RESET}" | tee -a "$LOG_FILE"
                echo | tee -a "$LOG_FILE"
                continue
            fi
        else
            # systemd services handling
            if systemctl list-unit-files | grep -qw "$svc"; then
                status=$(systemctl is-active "$svc")
                uptime=$(systemctl show "$svc" -p ActiveEnterTimestamp --value 2>/dev/null)

                if [[ "$status" == "active" ]]; then
                    echo -e "$svc: ${GREEN}$status${RESET} (Since: $uptime)" | tee -a "$LOG_FILE"
                else
                    echo -e "$svc: ${RED}$status${RESET}" | tee -a "$LOG_FILE"
                fi
            else
                echo -e "$svc: ${RED}not installed${RESET}" | tee -a "$LOG_FILE"
                echo | tee -a "$LOG_FILE"
                continue
            fi
        fi

        # Version check (only if installed)
        ver="Not available"

        case "$svc" in
            node) ver=$(node -v 2>/dev/null) ;;
            npm) ver=$(npm -v 2>/dev/null) ;;
            csf) ver=$(csf -v 2>/dev/null | head -n1) ;;
            php-fpm|php*-fpm)
                command -v php >/dev/null && ver=$(php -v | head -n1)
                ;;
            redis|redis-server)
                command -v redis-server >/dev/null && ver=$(redis-server --version | head -n1)
                ;;
            mysql|mariadb)
                command -v mysql >/dev/null && ver=$(mysql --version)
                ;;
            nginx)
                command -v nginx >/dev/null && ver=$(nginx -v 2>&1)
                ;;
            apache2|httpd)
                command -v apache2 >/dev/null && ver=$(apache2 -v | grep "Server version")
                command -v httpd >/dev/null && ver=$(httpd -v | grep "Server version")
                ;;
            meilisearch)
                command -v meilisearch >/dev/null && ver=$(meilisearch --version)
                ;;
        esac

        echo -e "$svc version: $ver" | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
    done
}

# Faveo Details
check_faveo_info() {
    echo -e "${YELLOW}Faveo Application Info:${RESET}" | tee -a "$LOG_FILE"
    APP_URL=$(grep APP_URL "$FAVEO_ROOT/.env" 2>/dev/null | cut -d '=' -f2)
    CONFIG_FILE="$FAVEO_ROOT/storage/faveoconfig.ini"
    PLAN=$(grep APP_NAME "$CONFIG_FILE" 2>/dev/null | cut -d '=' -f2)
    VERSION=$(grep APP_VERSION "$CONFIG_FILE" 2>/dev/null | cut -d '=' -f2)
    echo "URL: $APP_URL" | tee -a "$LOG_FILE"
    echo "Plan: $PLAN" | tee -a "$LOG_FILE"
    echo "Version: $VERSION" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
}

# Cron Jobs
check_cron_jobs() {
    echo -e "${YELLOW}Cron Jobs:${RESET}" | tee -a "$LOG_FILE"

    for user in www-data root; do
        echo -e "${CYAN}Cron jobs for user: $user${RESET}" | tee -a "$LOG_FILE"

        CRONS=$(crontab -u "$user" -l 2>/dev/null | grep -vE '^\s*(#|$)')

        if [[ -z "$CRONS" ]]; then
            echo "None" | tee -a "$LOG_FILE"
            echo | tee -a "$LOG_FILE"
            continue
        fi

        echo "$CRONS" | tee -a "$LOG_FILE"

        ARTISAN_CRONS=$(echo "$CRONS" | grep -Ei '\bartisan\b')
        if [[ -z "$ARTISAN_CRONS" ]]; then
            echo -e "${GREEN}No artisan cron jobs found.${RESET}" | tee -a "$LOG_FILE"
            echo | tee -a "$LOG_FILE"
            continue
        fi

        echo -e "${GREEN}artisan commands found:${RESET}" | tee -a "$LOG_FILE"
        echo "$ARTISAN_CRONS" | tee -a "$LOG_FILE"

        echo -e "${CYAN}Last 6 artisan cron executions:${RESET}" | tee -a "$LOG_FILE"

        if [[ -f /var/log/syslog ]]; then
            grep -iE "CRON.*\($user\).*artisan" /var/log/syslog \
                | tail -n 6 \
                | tee -a "$LOG_FILE"
        elif [[ -f /var/log/cron ]]; then
            grep -iE "CRON.*\($user\).*artisan" /var/log/cron \
                | tail -n 6 \
                | tee -a "$LOG_FILE"
        else
            echo "Cron log file not found. Cannot determine last run times." | tee -a "$LOG_FILE"
        fi

        echo | tee -a "$LOG_FILE"
    done
}

# Supervisor Jobs
check_supervisor_jobs() {
    echo -e "${YELLOW}Supervisor Jobs:${RESET}" | tee -a "$LOG_FILE"
    supervisorctl status 2>/dev/null | tee -a "$LOG_FILE" || echo "Supervisor not available or permission denied" | tee -a "$LOG_FILE"
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

    echo -e "${CYAN}User\tTTY\tLogin Time\tIdle\tSession\tFrom${RESET}" | tee -a "$LOG_FILE"

    echo "$SESSIONS" | while read -r user tty date time from; do
        # Idle time (from w)
        IDLE=$(w -h | awk -v t="$tty" '$2==t {print $5}')

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

        printf "%-8s %-6s %-16s %-6s %-8s %s\n" \
            "$user" "$tty" "$date $time" "${IDLE:-0}" "$SESSION_TIME" "$from" \
            | tee -a "$LOG_FILE"
    done

    echo -e "${GREEN}Total Active SSH Users: $(echo "$SESSIONS" | wc -l)${RESET}" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
}

# SSL Check
check_ssl_validity() {
    echo -e "${YELLOW}SSL Check for: $DOMAIN${RESET}" | tee -a "$LOG_FILE"

    # PHP SSL validity check
    RESULT=$(php -r '
    $url = "https://'${DOMAIN}'/cron-test.php";
    $ctx = stream_context_create(["ssl" => ["capture_peer_cert" => true]]);
    $fp = @fopen($url, "rb", false, $ctx);
    if (!$fp) {
        echo "false";
    } else {
        $params = stream_context_get_params($fp);
        $cert = $params["options"]["ssl"]["peer_certificate"] ?? null;
        echo is_null($cert) ? "false" : "true";
    }' 2>/dev/null)

    if [[ "$RESULT" == "true" ]]; then
        echo -e "${GREEN}SSL is Valid${RESET}" | tee -a "$LOG_FILE"
    else
        echo -e "${RED}SSL is Not Valid${RESET}" | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
        return
    fi

    # Ensure openssl is installed
    if ! command -v openssl &>/dev/null; then
        echo -e "${CYAN}openssl not found, installing...${RESET}" | tee -a "$LOG_FILE"
        if [[ -f /etc/debian_version ]]; then
            apt-get update -qq && apt-get install -y openssl >/dev/null 2>&1
        elif [[ -f /etc/redhat-release ]]; then
            yum install -y openssl >/dev/null 2>&1
        else
            echo -e "${RED}Unsupported OS – cannot install openssl${RESET}" | tee -a "$LOG_FILE"
            return
        fi
    fi

    # Sanitize DOMAIN for OpenSSL
    SSL_HOST=$(echo "$DOMAIN" | sed -E 's@^https?://@@; s@/.*@@')

    # Fetch certificate
    CERT_RAW=$(echo | openssl s_client \
        -servername "$SSL_HOST" \
        -connect "$SSL_HOST:443" 2>/dev/null)

    CERT_INFO=$(echo "$CERT_RAW" | openssl x509 -noout \
        -issuer -subject -startdate -enddate 2>/dev/null)

    if [[ -z "$CERT_INFO" ]]; then
        echo -e "${RED}Failed to retrieve certificate details${RESET}" | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
        return
    fi

    ISSUER=$(echo "$CERT_INFO" | grep issuer= | sed 's/issuer=//')
    SUBJECT=$(echo "$CERT_INFO" | grep subject= | sed 's/subject=//')
    START_DATE=$(echo "$CERT_INFO" | grep notBefore= | cut -d= -f2)
    END_DATE=$(echo "$CERT_INFO" | grep notAfter= | cut -d= -f2)

    EXPIRY_TS=$(date -d "$END_DATE" +%s)
    NOW_TS=$(date +%s)
    DAYS_LEFT=$(( (EXPIRY_TS - NOW_TS) / 86400 ))

    echo -e "${CYAN}Certificate Details:${RESET}" | tee -a "$LOG_FILE"
    echo "Domain          : $SSL_HOST" | tee -a "$LOG_FILE"
    echo "Subject         : $SUBJECT" | tee -a "$LOG_FILE"
    echo "Issuer (CA)     : $ISSUER" | tee -a "$LOG_FILE"
    echo "Valid From      : $START_DATE" | tee -a "$LOG_FILE"
    echo "Valid Until     : $END_DATE" | tee -a "$LOG_FILE"

    # ---- Production SLA for SSL expiry ----
    if (( DAYS_LEFT < 0 )); then
        echo -e "${RED}Certificate Status : EXPIRED${RESET}" | tee -a "$LOG_FILE"
    elif (( DAYS_LEFT <= 15 )); then
        echo -e "${RED}Certificate Status : EXPIRING SOON ($DAYS_LEFT days)${RESET}" | tee -a "$LOG_FILE"
    elif (( DAYS_LEFT <= 30 )); then
        echo -e "${YELLOW}Certificate Status : WARNING ($DAYS_LEFT days)${RESET}" | tee -a "$LOG_FILE"
    else
        echo -e "${GREEN}Certificate Status : OK ($DAYS_LEFT days)${RESET}" | tee -a "$LOG_FILE"
    fi

    echo | tee -a "$LOG_FILE"
}

# Billing Connection Check
check_billing_connection() {
    echo -e "${YELLOW}Billing Connection Check:${RESET}" | tee -a "$LOG_FILE"
    if curl -sL -o /dev/null -w "%{http_code}" https://billing.faveohelpdesk.com | grep -qE "200|301|302"; then
        echo -e "${GREEN}Billing connection is working.${RESET}" | tee -a "$LOG_FILE"
    else
        echo -e "${RED}Billing connection is not working.${RESET}" | tee -a "$LOG_FILE"
    fi
    echo | tee -a "$LOG_FILE"
}

# Root Ownership Check
check_root_ownership() {
    echo -e "${YELLOW}Root-Owned Files/Folders in Faveo Directory:${RESET}" | tee -a "$LOG_FILE"
    ROOT_OWNED_ITEMS=$(find "$FAVEO_ROOT" -user root 2>/dev/null)
    if [[ -n "$ROOT_OWNED_ITEMS" ]]; then
        echo -e "${RED}The following items are owned by root:${RESET}" | tee -a "$LOG_FILE"
        echo "$ROOT_OWNED_ITEMS" | tee -a "$LOG_FILE"
    else
        echo -e "${GREEN}No files/folders owned by root found.${RESET}" | tee -a "$LOG_FILE"
    fi
    echo | tee -a "$LOG_FILE"
}

check_ports() {
    echo -e "${YELLOW}Port Availability Check:${RESET}" | tee -a "$LOG_FILE"

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
            DEFAULT_PORTS[$port]="Custom"
        done
    fi

    for PORT in "${!DEFAULT_PORTS[@]}"; do
        LABEL=${DEFAULT_PORTS[$PORT]}
        echo -e "\nChecking Port $PORT ($LABEL)" | tee -a "$LOG_FILE"

        # Internal check using netstat or ss
        if command -v ss &>/dev/null; then
            ss -tuln | grep ":$PORT " &>/dev/null
        else
            netstat -tuln | grep ":$PORT " &>/dev/null
        fi
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}Port $PORT is open internally (listening).${RESET}" | tee -a "$LOG_FILE"
        else
            echo -e "${RED}Port $PORT is NOT open internally.${RESET}" | tee -a "$LOG_FILE"
        fi
    done
    echo | tee -a "$LOG_FILE"
}

# Firewall Status and Whitelist Check
firewall_check() {
    echo -e "${YELLOW}Firewall Check:${RESET}" | tee -a "$LOG_FILE"

    if command -v csf &>/dev/null && sudo csf -l &>/dev/null; then
        echo -e "${GREEN}CSF is installed.${RESET}" | tee -a "$LOG_FILE"
        sudo csf -l 2>/dev/null | awk '/ALLOWIN|ALLOWOUT|ACCEPT/ && /tcp|udp/ {print}' | tee -a "$LOG_FILE"

    elif systemctl is-active firewalld &>/dev/null; then
        echo -e "${GREEN}Firewalld is active.${RESET}" | tee -a "$LOG_FILE"
        sudo firewall-cmd --list-all | tee -a "$LOG_FILE"

    elif command -v ufw &>/dev/null; then
        ufw_status=$(sudo ufw status | grep -i "Status:")

        if echo "$ufw_status" | grep -qi "active"; then
            echo -e "${GREEN}UFW is installed.${RESET}" | tee -a "$LOG_FILE"
            sudo ufw status numbered | tee -a "$LOG_FILE"
        else
            echo -e "${YELLOW}UFW is installed but inactive.${RESET}" | tee -a "$LOG_FILE"
        fi

    else
        echo -e "${YELLOW}No supported firewall detected. Falling back to iptables or nftables if available.${RESET}" | tee -a "$LOG_FILE"

        if command -v iptables &>/dev/null; then
            echo -e "${CYAN}iptables rules:${RESET}" | tee -a "$LOG_FILE"
            IPTABLES_RULES=$(sudo iptables -L -n -v | grep -E "ACCEPT|DROP")
            if [[ -z "$IPTABLES_RULES" ]]; then
                echo -e "${RED}No iptables rules found.${RESET}" | tee -a "$LOG_FILE"
            else
                echo "$IPTABLES_RULES" | tee -a "$LOG_FILE"
            fi

        elif command -v nft &>/dev/null; then
            echo -e "${CYAN}nftables rules:${RESET}" | tee -a "$LOG_FILE"
            sudo nft list ruleset | tee -a "$LOG_FILE"

        else
            echo -e "${RED}No firewall tools found (csf, firewalld, ufw, iptables, nft).${RESET}" | tee -a "$LOG_FILE"
        fi
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

    # Install ioping if missing
    if ! command -v ioping >/dev/null 2>&1; then
        echo "ioping not found, installing..." | tee -a "$LOG_FILE"

        . /etc/os-release 2>/dev/null

        if [[ "$ID" =~ (ubuntu|debian) ]]; then
            apt-get update -qq && apt-get install -y ioping >/dev/null 2>&1
        elif [[ "$ID" =~ (rhel|centos|rocky|almalinux|fedora) ]]; then
            yum install -y ioping >/dev/null 2>&1
        else
            echo -e "${RED}Unsupported OS for ioping install${RESET}" | tee -a "$LOG_FILE"
            return 1
        fi
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

    # SLA CHECK
    FAIL=0

    if (( $(echo "$READ_AVG > $SLA_LATENCY_MS" | bc -l) )); then
        echo -e "${RED}READ latency FAILED SLA (${READ_AVG} ms > ${SLA_LATENCY_MS} ms)${RESET}" | tee -a "$LOG_FILE"
        FAIL=1
    fi

    if (( $(echo "$WRITE_AVG > $SLA_LATENCY_MS" | bc -l) )); then
        echo -e "${RED}WRITE latency FAILED SLA (${WRITE_AVG} ms > ${SLA_LATENCY_MS} ms)${RESET}" | tee -a "$LOG_FILE"
        FAIL=1
    fi

    if [[ "$FAIL" -eq 0 ]]; then
        echo -e "${GREEN}Disk latency within SLA for production workload${RESET}" | tee -a "$LOG_FILE"
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

    echo -e "${CYAN}Top 10 processes by CPU usage:${RESET}" | tee -a "$LOG_FILE"

    ps -eo pid,%cpu,%mem,cmd --sort=-%cpu --no-headers | head -n 10 | \
    awk -v cw=$CPU_WARN -v cf=$CPU_FAIL '
    {
        cpu=$2; mem=$3;
        status="OK"; color="\033[0;32m";

        if (cpu > cf) { status="CRITICAL"; color="\033[0;31m" }
        else if (cpu > cw) { status="WARNING"; color="\033[0;33m" }

        printf "%s%s | CPU: %.1f%% | MEM: %.1f%% | %s\033[0m\n",
               color, status, cpu, mem, substr($0, index($0,$4))
    }' | tee -a "$LOG_FILE"

    echo -e "${CYAN}Top 10 processes by Memory usage:${RESET}" | tee -a "$LOG_FILE"

    ps -eo pid,%cpu,%mem,cmd --sort=-%mem --no-headers | head -n 10 | \
    awk -v mw=$MEM_WARN -v mf=$MEM_FAIL '
    {
        cpu=$2; mem=$3;
        status="OK"; color="\033[0;32m";

        if (mem > mf) { status="CRITICAL"; color="\033[0;31m" }
        else if (mem > mw) { status="WARNING"; color="\033[0;33m" }

        printf "%s%s | CPU: %.1f%% | MEM: %.1f%% | %s\033[0m\n",
               color, status, cpu, mem, substr($0, index($0,$4))
    }' | tee -a "$LOG_FILE"

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

    for host in "${HOSTS[@]}"; do
        echo -n "Pinging $host ... " | tee -a "$LOG_FILE"

        # Run ping
        PING_OUTPUT=$(ping -c2 -W2 "$host" 2>/dev/null)
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}UNREACHABLE${RESET}" | tee -a "$LOG_FILE"
            continue
        fi

        # Extract avg latency
        AVG_LATENCY=$(echo "$PING_OUTPUT" | awk -F '/' '/rtt/ {print $5}')

        if (( $(echo "$AVG_LATENCY <= $SLA_OK" | bc -l) )); then
            echo -e "${GREEN}OK (avg: ${AVG_LATENCY} ms)${RESET}" | tee -a "$LOG_FILE"

        elif (( $(echo "$AVG_LATENCY <= $SLA_WARN" | bc -l) )); then
            echo -e "${YELLOW}WARNING (avg: ${AVG_LATENCY} ms)${RESET}" | tee -a "$LOG_FILE"

        else
            echo -e "${RED}SLOW (avg: ${AVG_LATENCY} ms | SLA breached)${RESET}" | tee -a "$LOG_FILE"
        fi
    done

    echo | tee -a "$LOG_FILE"
}

# Faveo File size check
check_faveo_storage() {
    echo -e "${YELLOW}Faveo Storage Usage (No MySQL login required):${RESET}" | tee -a "$LOG_FILE"

    # Faveo root directory
    FAVEO_ROOT=${FAVEO_ROOT:-/var/www/faveo}

    if [[ -d "$FAVEO_ROOT" ]]; then
        DIR_SIZE=$(du -sh "$FAVEO_ROOT" 2>/dev/null | awk '{print $1}')
        echo -e "Faveo Directory Size: ${DIR_SIZE}" | tee -a "$LOG_FILE"
    else
        echo -e "${RED}Faveo directory not found at $FAVEO_ROOT${RESET}" | tee -a "$LOG_FILE"
    fi

    # MySQL database folder size
    read -p "Enter MySQL datadir (default: /var/lib/mysql): " MYSQL_DIR
    MYSQL_DIR=${MYSQL_DIR:-/var/lib/mysql}

    # Fetch DB name
    DB_NAME=$(grep -E '^DB_DATABASE=' "$FAVEO_ROOT/.env" 2>/dev/null \
        | head -n1 \
        | cut -d '=' -f2- \
        | tr -d '"' \
        | tr -d "'")
    echo -e "${YELLOW}Faveo Database Name:${RESET} $DB_NAME" | tee -a "$LOG_FILE"

    DB_PATH="$MYSQL_DIR/$DB_NAME"

    if [[ -d "$DB_PATH" ]]; then
        DB_SIZE=$(du -sh "$DB_PATH" 2>/dev/null | awk '{print $1}')
        echo -e "Database '$DB_NAME' folder size: $DB_SIZE" | tee -a "$LOG_FILE"
    else
        echo -e "${RED}Database folder '$DB_PATH' not found${RESET}" | tee -a "$LOG_FILE"
    fi

    echo | tee -a "$LOG_FILE"
}

# PHP Config Check
check_php_config() {
    echo -e "${YELLOW}PHP Configuration Check:${RESET}" | tee -a "$LOG_FILE"

    # Detect OS silently
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_ID=$ID
    else
        OS_ID=$(uname -s)
    fi

    PHP_FILES=()

    case "$OS_ID" in
        ubuntu|debian)
            PHP_FILES=(
                /etc/php/8.2/fpm/php.ini
                /etc/php/8.2/apache2/php.ini
                /etc/php/8.2/cli/php.ini
            )
            ;;
        rhel|centos|rocky|almalinux|fedora)
            PHP_FILES=(
                /etc/php.ini
            )
            ;;
        *)
            echo "Unsupported OS for PHP config check" | tee -a "$LOG_FILE"
            return
            ;;
    esac

    REQUIRED_KEYS=(
        file_uploads
        allow_url_fopen
        short_open_tag
        memory_limit
        cgi.fix_pathinfo
        upload_max_filesize
        post_max_size
        max_execution_time
    )

    for php_file in "${PHP_FILES[@]}"; do
        if [[ ! -f "$php_file" ]]; then
            echo -e "${RED}$php_file not found${RESET}" | tee -a "$LOG_FILE"
            continue
        fi

        echo -e "${CYAN}File: $php_file${RESET}" | tee -a "$LOG_FILE"

        for key in "${REQUIRED_KEYS[@]}"; do
            value=$(grep -Ei "^[[:space:]]*$key[[:space:]]*=" "$php_file" \
                    | grep -v '^;' \
                    | tail -n 1 \
                    | awk -F= '{print $2}' \
                    | xargs)

            if [[ -z "$value" ]]; then
                echo -e "  $key = ${RED}Not set${RESET}" | tee -a "$LOG_FILE"
            else
                echo -e "  $key = ${GREEN}$value${RESET}" | tee -a "$LOG_FILE"
            fi
        done

        echo | tee -a "$LOG_FILE"
    done
}

# Timeout Check
check_request_timeouts() {
    echo -e "${YELLOW}Request Timeout Check:${RESET}" | tee -a "$LOG_FILE"

    # Detect OS silently
    . /etc/os-release 2>/dev/null
    OS_ID=$ID

    # PHP-FPM TIMEOUTS
    echo -e "${CYAN}PHP-FPM:${RESET}" | tee -a "$LOG_FILE"

    PHP_FPM_CONF=()

    case "$OS_ID" in
        ubuntu|debian)
            PHP_FPM_CONF=(/etc/php/8.2/fpm/php.ini /etc/php/8.2/fpm/pool.d/*.conf)
            ;;
        rhel|centos|rocky|almalinux|fedora)
            PHP_FPM_CONF=(/etc/php.ini /etc/php-fpm.d/*.conf)
            ;;
    esac

    for key in request_terminate_timeout max_execution_time; do
        val=$(grep -RhsEi "^[[:space:]]*$key[[:space:]]*=" "${PHP_FPM_CONF[@]}" \
              | grep -v '^;' \
              | tail -n 1 \
              | awk -F= '{print $2}' \
              | xargs)

        [[ -z "$val" ]] && val="Not set"
        echo "  $key = $val" | tee -a "$LOG_FILE"
    done

    echo | tee -a "$LOG_FILE"

    # NGINX TIMEOUTS
    if command -v nginx &>/dev/null; then
        echo -e "${CYAN}Nginx:${RESET}" | tee -a "$LOG_FILE"

        nginx -T 2>/dev/null | awk '
            /fastcgi_read_timeout/ {
                print "  fastcgi_read_timeout = " $NF
            }
        ' | tail -n 1 | tee -a "$LOG_FILE"

        [[ $? -ne 0 ]] && echo "  fastcgi_read_timeout = Not set (default 60s)" | tee -a "$LOG_FILE"

        echo | tee -a "$LOG_FILE"
    fi

    # APACHE TIMEOUTS
    if command -v apache2 &>/dev/null || command -v httpd &>/dev/null; then
        echo -e "${CYAN}Apache:${RESET}" | tee -a "$LOG_FILE"

        APACHE_CONF=$(apachectl -t -D DUMP_INCLUDES 2>/dev/null | awk '{print $1}')

        grep -RhsEi "^(Timeout|ProxyTimeout|FcgidIOTimeout)" $APACHE_CONF \
            | grep -v '^#' \
            | awk '{print "  "$1" = "$2}' \
            | tee -a "$LOG_FILE"

        echo | tee -a "$LOG_FILE"
    fi
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
    echo "0) Exit"
    sleep 0.05
}

# Run based on selection
while true; do
    print_menu
    read -rp "Enter your choice [0-18]: " CHOICE
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
        0) echo -e "${CYAN}Exiting...${RESET}"; exit 0 ;;
        *) echo -e "${RED}Invalid option. Please try again.${RESET}" ;;
    esac
done


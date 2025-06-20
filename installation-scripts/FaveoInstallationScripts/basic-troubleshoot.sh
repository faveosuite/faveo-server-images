#!/bin/bash

##### This is a Basic troubleshooting script for Faveo helpdesk #####
##### This Script can be used in all Linux distributions ############
##### (Note: Tested with Debian and RHEL OS Distro's) ###############
##### (Usage: sudo ./basic_troubleshoot.sh) #########################
##### Created and maintained by Faveo Helpdesk ######################
##### For Any Queries reach (support.faveohelpdesk.com) #############
##### version of the script: 1.0 ####################################
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
    echo "Distro: $(lsb_release -ds 2>/dev/null || grep PRETTY_NAME /etc/os-release | cut -d '"' -f2)" | tee -a "$LOG_FILE"
    echo "Kernel: $(uname -r)" | tee -a "$LOG_FILE"
    echo "Uptime: $(uptime -p)" | tee -a "$LOG_FILE"
    echo "Load Avg: $(cut -d ' ' -f1-3 /proc/loadavg)" | tee -a "$LOG_FILE"
    echo "vCPU Cores: $(nproc)" | tee -a "$LOG_FILE"
    echo "Memory: $(free -htm | awk '/Total:/ {print $3" used / "$2}')" | tee -a "$LOG_FILE"
    echo "Disk: $(df -h / | awk 'NR==2{print $3" used / "$2" ("$5")"}')" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
}

# Service Status
get_service_status() {
    # OS-specific service mappings
    SERVICES=(
        apache2 httpd
        mysql mariadb
        redis redis-server
        supervisord supervisor
	php
	php8.2-fpm php-fpm
        cron crond
        meilisearch
        nginx
        node
        npm
        csf
    )

    echo -e "${YELLOW}Service Status:${RESET}" | tee -a "$LOG_FILE"
    for service_pair in "${SERVICES[@]}"; do
        for svc in $service_pair; do
            if systemctl list-units --type=service --all | grep -qw "$svc"; then
                status=$(systemctl is-active "$svc")
                uptime_info=$(systemctl show "$svc" -p ActiveEnterTimestamp 2>/dev/null | cut -d= -f2)
                if [ "$status" == "active" ]; then
                    echo -e "$svc: ${GREEN}$status${RESET} (Since: $uptime_info)" | tee -a "$LOG_FILE"
                else
                    echo -e "$svc: ${RED}$status${RESET}" | tee -a "$LOG_FILE"
                fi
                break
            fi
        done

        # Version check
        case "$svc" in
            node) ver=$(node -v 2>/dev/null);;
            npm) ver=$(npm -v 2>/dev/null);;
            csf) ver=$(csf -v 2>/dev/null | head -n1);;
            php8.2-fpm|php-fpm) ver=$(php-fpm -v 2>/dev/null | head -n1);;
            redis|redis-server) ver=$(redis-server --version 2>/dev/null | head -n1);;
            mysql|mariadb) ver=$(mysql --version 2>/dev/null);;
            nginx) ver=$(nginx -v 2>&1);;
            apache2|httpd) ver=$($svc -v 2>/dev/null | grep "Server version" || apache2 -v 2>/dev/null | grep "Server version");;
            meilisearch) ver=$(meilisearch --version 2>/dev/null);;
            *) ver="Not found or not applicable";;
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
        CRONS=$(crontab -u "$user" -l 2>/dev/null | grep -v '^#')

        if [[ -z "$CRONS" ]]; then
            echo "None" | tee -a "$LOG_FILE"
        else
            echo "$CRONS" | tee -a "$LOG_FILE"

            ARTISAN_CRONS=$(echo "$CRONS" | grep -Ei "artisan")
            if [[ -n "$ARTISAN_CRONS" ]]; then
                echo -e "${GREEN}artisan commands found:${RESET}" | tee -a "$LOG_FILE"
                echo "$ARTISAN_CRONS" | tee -a "$LOG_FILE"

                echo -e "${CYAN}Estimating last run time from system logs:${RESET}" | tee -a "$LOG_FILE"

                if command -v journalctl &>/dev/null; then
                    journalctl --no-pager | grep -iE "$user.*artisan" | tail -n 6 | tee -a "$LOG_FILE"
                elif [[ -f /var/log/syslog ]]; then
                    grep -iE "$user.*artisan" /var/log/syslog | tail -n 6 | tee -a "$LOG_FILE"
                elif [[ -f /var/log/cron ]]; then
                    grep -iE "$user.*artisan" /var/log/cron | tail -n 6 | tee -a "$LOG_FILE"
                else
                    echo "No available logs to estimate cron run times." | tee -a "$LOG_FILE"
                fi
            else
                echo -e "No artisan commands found." | tee -a "$LOG_FILE"
            fi
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

# Logged-in Users
check_logged_users() {
    echo -e "${YELLOW}Logged-in Users:${RESET}" | tee -a "$LOG_FILE"
    who | wc -l | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
}

# SSL Check
check_ssl_validity() {
    echo -e "${YELLOW}SSL Check for: $DOMAIN${RESET}" | tee -a "$LOG_FILE"
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
    echo "0) Exit"
    sleep 0.05
}

# Run based on selection
while true; do
    print_menu
    read -rp "Enter your choice [0-12]: " CHOICE
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
        0) echo -e "${CYAN}Exiting...${RESET}"; exit 0 ;;
        *) echo -e "${RED}Invalid option. Please try again.${RESET}" ;;
    esac
done

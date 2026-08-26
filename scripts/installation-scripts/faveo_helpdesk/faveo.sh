#!/bin/bash

##---------- Author : Thirumoorthi Duraipandi------------------------------------------------##
##---------- Email : thirumoorthi.duraipandi@ladybirdweb.com,thirumoorthi3706@gmail.com------##
##---------- Github page : https://github.com/ladybirdweb/faveo-server-images/---------------##
##---------- Purpose : Auto Install Faveo Helpdesk in a linux system.------------------------##
##---------- Tested on : RHEL 10/9/8, Rocky 10/9/8, Ubuntu 24/22/20 -------------------------##
##---------- Alma Linux 8/9/10, Debian 11/12/13 ---------------------------------------------##
##---------- Updated version : v2.0 (Updated on 17th AUG 2026) ------------------------------##
##-----NOTE: This script requires root privileges, otherwise one could run the script -------##
##---------- as a sudo user who got root privileges. ----------------------------------------##
##-----------USAGE: "sudo /bin/bash faveo-autoscript.sh" ------------------------------------##


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


# Detect scripts invoked through a non-Bash shell.
# IMPORTANT: do not grep the executable path for "sh" because /bin/bash
# itself contains the string "sh" and would incorrectly trigger this check.
if [[ -z "${BASH_VERSION:-}" ]]; then
    echo -e "${red}This installer needs to be run with 'bash' not 'sh', try again with bash.${reset}"
    exit 1
fi

# Checking for the Super User.
if [[ $EUID -ne 0 ]]; then
    echo -e "${red}This script must be run as root, try again with sudo or root user.${reset}"
    exit 1
fi

###################################################### End of Banner ####################################################################


######################################################## End of OS Validation ###########################################################
os_check() {
    echo -e "\n$yellow Checking OS compatibility for Faveo Helpdesk... $reset"
    sleep 0.05

    # Detect OS
    if [[ -e /etc/os-release ]]; then
        source /etc/os-release
        os_name=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
        os_version_id=$(echo "$VERSION_ID" | tr -d '"')
        Os_Version="$PRETTY_NAME"
    elif [[ -e /etc/debian_version ]]; then
        os_name="debian"
        os_version_id=$(cat /etc/debian_version | cut -d'.' -f1)
        Os_Version="Debian $(cat /etc/debian_version)"
    else
        echo -e "${red}Unsupported Linux distribution. Supported: Ubuntu 20/22/24, Debian 11/12, RHEL 8/9.${reset}"
        exit 1
    fi

    echo -e "[Detected OS] : $green $Os_Version $reset"
    sleep 0.05

    # Supported versions (Update when needed)
    declare -A supported_versions
    supported_versions=(
        [ubuntu]="22.04 24.04 26.04"
        [debian]="11 12"
        [rhel]="8 9 10"
        [rocky]="8 9 10"
        [almalinux]="8 9 10"
    )

    # Check if OS is supported
    if [[ -z "${supported_versions[$os_name]}" ]]; then
        echo -e "${red}Unsupported Linux distribution: $os_name.${reset}"
        exit 1
    fi

    # Check if OS version is supported
    supported=false
    for ver in ${supported_versions[$os_name]}; do
        if [[ "$os_version_id" == "$ver"* ]]; then
            supported=true
            break
        fi
    done

    if ! $supported; then
        echo -e "${red}This $os_name version ($Os_Version) is unsupported. Supported versions: ${supported_versions[$os_name]}.${reset}"
        exit 1
    fi

    echo -e "Faveo Helpdesk Compatibility Check: $green [OK] $reset"
    sleep 0.05

    # Call OS-specific installer scripts from the same folder
    case "$os_name" in
        ubuntu|debian)
            if [[ -f "./debian_block.sh" ]]; then
                bash ./debian_block.sh "$@"
            else
                echo -e "${red}Debian installer script not found!${reset}"
                exit 1
            fi
            ;;
        rhel|rocky|almalinux|centos)
            if [[ -f "./rhel_block.sh" ]]; then
                bash ./rhel_block.sh "$@"
            else
                echo -e "${red}RHEL installer script not found!${reset}"
                exit 1
            fi
            ;;
    esac
}

os_check "$@"

##################################################### OS CHECK ########################################################

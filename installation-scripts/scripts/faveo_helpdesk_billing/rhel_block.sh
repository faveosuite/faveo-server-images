#!/bin/bash

##---------- Author : Thirumoorthi Duraipandi------------------------------------------------##
##---------- Email : thirumoorthi.duraipandi@ladybirdweb.com,thirumoorthi3706@gmail.com------##
##---------- Github page : https://github.com/ladybirdweb/faveo-server-images/---------------##
##---------- Purpose : Auto Install Faveo Helpdesk on RHEL-family systems.-------------------##
##---------- Tested on : RHEL 8/9/10, Rocky 8/9/10, AlmaLinux 8/9/10, -----------------------##
##---------- Updated version : v2.0 (Updated on 17th Aug 2026) ------------------------------##
##-----------NOTE: This script requires root privileges, otherwise one could run the script--##
##---------- as a sudo user who got root privileges. ----------------------------------------##
##-----------USAGE: "sudo /bin/bash rhel-test.sh" -------------------------------------------##


# Color variables (ANSI codes with escaped octal for portability)

red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
blue='\033[1;34m'
cyan='\033[1;36m'
reset='\033[0m'
bold='\033[1m'


############################ RHEL BLOCK #################################

rhel_block() {

# ---------------------------------------------------------------------------
# Resolves a CLI-supplied certificate/key value that may be:
#   1) an existing file path already on this server
#   2) base64-encoded PEM content (recommended for CLI/automation use, since
#      it survives shell quoting/newlines safely - e.g. --sqlsslca "$(base64 -w0 ca.pem)")
#   3) raw PEM content passed directly as the argument (e.g. via $'...'
#      ANSI-C quoting with real newlines)
# Normalizes whichever form was given into a real file on disk, validates it
# with openssl, and echoes the final file path on success (nothing on failure).
# ---------------------------------------------------------------------------

_resolve_cert_arg() {
    local value="$1"
    local dest_file="$2"
    local kind="$3"   # cert|key

    [[ -z "$value" ]] && return 1

    _pem_ok() {
        if [[ "$kind" == "key" ]]; then
            openssl pkey -noout -in "$1" &>/dev/null
        else
            openssl x509 -noout -in "$1" &>/dev/null
        fi
    }

    # 1) Already a path to an existing, valid PEM file - use as-is.
    if [[ -f "$value" ]]; then
        _pem_ok "$value" && { echo "$value"; return 0; }
        return 1
    fi

    mkdir -p "$(dirname "$dest_file")"

    # 2) Try base64-decoded content.
    local decoded
    decoded=$(printf '%s' "$value" | base64 -d 2>/dev/null)
    if [[ -n "$decoded" ]]; then
        printf '%s\n' "$decoded" > "$dest_file"
        chmod 600 "$dest_file"
        _pem_ok "$dest_file" && { echo "$dest_file"; return 0; }
    fi

    # 3) Fall back to treating the raw value as literal PEM content.
    printf '%s\n' "$value" > "$dest_file"
    chmod 600 "$dest_file"
    _pem_ok "$dest_file" && { echo "$dest_file"; return 0; }

    rm -f "$dest_file"
    return 1
}

# ---------------------------------------------------------------------------
# CLI Argument Parser
# Supports both interactive mode (no args) and --option mode
# ---------------------------------------------------------------------------

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --domain)       DomainName="$2";                shift 2 ;;
            --email)        Email="$2";                     shift 2 ;;
            --license)      LicenseCode="$2";               shift 2 ;;
            --order)        OrderNumber="$2";               shift 2 ;;
            --sql)          Sql_option_value="$2";          shift 2 ;;
            --php)          Php_option_value="$2";          shift 2 ;;
            --webserver)    Webserver_option_value="$2";    shift 2 ;;
            --ssl)          Ssl_option_value="$2";          shift 2 ;;
            --meili)        Meili_option_value="$2";        shift 2 ;;
            --release)      ReleaseSelection="$2";          shift 2 ;;
            --nats)         Nats_option_value="$2";         shift 2 ;;
            --node)         Node_option_value="$2";         shift 2 ;;
            --certfile)     certfile="$2";                  shift 2 ;;
            --keyfile)      keyfile="$2";                   shift 2 ;;
            --cacertfile)   cacertfile="$2";                shift 2 ;;
            --sqlreser)     MySQL_LOCATION="$2";            shift 2 ;;
            --sqlhost)      MySQL_HOST="$2";                shift 2 ;;
            --sqlusername)  MySQL_USERNAME="$2";            shift 2 ;;
            --sqlpassword)  MySQL_PASSWORD="$2";            shift 2 ;;
            --sqlport)      MySQL_PORT="$2";                shift 2 ;;
            --sqlsecure)    MySQL_SEC="$2";                 shift 2 ;;
            --sqlsslcert)   MySQL_SSLCERT="$2";             shift 2 ;;
            --sqlsslkey)    MySQL_SSLKEY="$2";              shift 2 ;;
            --sqlsslca)     MySQL_SSLCA="$2";               shift 2 ;;
            --sslverify)    MySQL_SSLVERIFY="$2";           shift 2 ;;
            --faveoenv)     ENV_SETUP="$2";                 shift 2 ;;
            --help)
                echo -e "${cyan}Usage: $0 [OPTIONS]${reset}"
                echo ""
                echo -e "${yellow}If no options are supplied, the script runs interactively.${reset}"
                echo ""
                echo "Options:"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--domain"      "<domain>"           "Domain name for Faveo"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--email"       "<email>"            "Admin email address"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--license"     "<16-char-code>"     "Faveo license code"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--order"       "<8-char-code>"      "Faveo order number"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--sql"         "mysql|mariadb"      "SQL server          (default: mysql)"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--php"         "<version e.g. 8.4>" "PHP version         (default: 8.4)"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--webserver"   "apache|nginx"       "Web server"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--ssl"         "certbot|self-signed|paid-ssl" "SSL type"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--release"     "official|rc|beta"   "Release type        (default: official)"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--meili"       "yes|no"             "Meilisearch         (default: yes)"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--nats"        "yes|no"             "NATS/Network Disc.  (default: no)"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--node"        "yes|no"             "Node.js             (default: no)"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--certfile"    "<path>"             "Certificate file    (paid-ssl only)"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--keyfile"     "<path>"             "Private key file    (paid-ssl only)"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--cacertfile"  "<path>"             "CA bundle file      (paid-ssl only)"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--sqlreser"    "yes|no"             "SQL server location (default: no)"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--sqlhost"     "MySQL Host Name"    "MySQL Host Name or IP"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--sqlusername" "MySQL User Name"    "MySQL Remote Host Username"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--sqlpassword" "MySQL Password"     "MySQL Remote Host Password"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--sqlport"     "MySQL Port Number"  "MySQL Port Number"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--sqlsecure"   "yes|no"             "MySQL Secure Connection"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--sqlsslcert"  "<path>"             "MySQL SSL Certificate file"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--sqlsslkey"   "<path>"             "MySQL SSL Key file"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--sqlsslca"    "<path>"             "MySQL SSL CA file"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--sqlsslverify" "yes|no"            "MySQL SSL Verify"
                printf "  ${green}%-15s${reset} %-35s %s\n" "--faveoenv"    "production|development|testing" "Faveo environment"
                exit 0
                ;;
            *)
                echo -e "$red Unknown option: $1$reset"
                echo "Run '$0 --help' for usage."
                exit 1
                ;;
        esac
    done

    # Validate any CLI-supplied values before the install begins
    local errors=0
    local email_regex="^[A-Za-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[A-Za-z0-9!#\$%&'*+/=?^_\`{|}~-]+)*@([A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z]{2,}$"

    [[ -n "$Email"              && ! "$Email"              =~ $email_regex                ]] && { echo -e "$red --email: invalid format.$reset";                   errors=$((errors+1)); }
    [[ -n "$LicenseCode"        && ${#LicenseCode} -ne 16                                ]] && { echo -e "$red --license: must be exactly 16 characters.$reset";  errors=$((errors+1)); }
    [[ -n "$OrderNumber"        && ${#OrderNumber}  -ne 8                                ]] && { echo -e "$red --order: must be exactly 8 characters.$reset";     errors=$((errors+1)); }
    [[ -n "$Sql_option_value"   && ! "$Sql_option_value"   =~ ^(mysql|mariadb)$          ]] && { echo -e "$red --sql: must be mysql or mariadb.$reset";           errors=$((errors+1)); }
    [[ -n "$Php_option_value"   && ! "$Php_option_value"   =~ ^([8-9]|[1-9][0-9])\.[0-9]+$ ]] && { echo -e "$red --php: must be version 8.x or above.$reset";   errors=$((errors+1)); }
    [[ -n "$Webserver_option_value" && ! "$Webserver_option_value" =~ ^(apache|nginx)$  ]] && { echo -e "$red --webserver: must be apache or nginx.$reset";       errors=$((errors+1)); }
    [[ -n "$Ssl_option_value"   && ! "$Ssl_option_value"   =~ ^(certbot|self-signed|paid-ssl)$ ]] && { echo -e "$red --ssl: must be certbot, self-signed, or paid-ssl.$reset"; errors=$((errors+1)); }
    [[ -n "$ReleaseSelection"  && ! "$ReleaseSelection"   =~ ^(official|rc|beta)$              ]] && { echo -e "$red --release: must be official, rc, or beta.$reset";          errors=$((errors+1)); }
    [[ -n "$Meili_option_value" && ! "$Meili_option_value" =~ ^(yes|no)$                ]] && { echo -e "$red --meili: must be yes or no.$reset";                 errors=$((errors+1)); }
    [[ -n "$Nats_option_value"  && ! "$Nats_option_value"  =~ ^(yes|no)$                ]] && { echo -e "$red --nats: must be yes or no.$reset";                  errors=$((errors+1)); }
    [[ -n "$Node_option_value"  && ! "$Node_option_value"  =~ ^(yes|no)$                ]] && { echo -e "$red --node: must be yes or no.$reset";                  errors=$((errors+1)); }
    if [[ "$Ssl_option_value" == "paid-ssl" ]]; then
        if [[ -n "$certfile" ]]; then
            _resolved=$(_resolve_cert_arg "$certfile" "/etc/httpd/ssl/faveolocal.crt" "cert")
            [[ -n "$_resolved" ]] && certfile="$_resolved" || { echo -e "$red --certfile: not a valid path or PEM certificate (plain or base64).$reset"; errors=$((errors+1)); }
        else
            echo -e "$red --certfile: required for paid-ssl.$reset"; errors=$((errors+1))
        fi
        if [[ -n "$keyfile" ]]; then
            _resolved=$(_resolve_cert_arg "$keyfile" "/etc/httpd/ssl/private.key" "key")
            [[ -n "$_resolved" ]] && keyfile="$_resolved" || { echo -e "$red --keyfile: not a valid path or PEM private key (plain or base64).$reset"; errors=$((errors+1)); }
        else
            echo -e "$red --keyfile: required for paid-ssl.$reset"; errors=$((errors+1))
        fi
        if [[ -n "$cacertfile" ]]; then
            _resolved=$(_resolve_cert_arg "$cacertfile" "/etc/httpd/ssl/faveorootCA.crt" "cert")
            [[ -n "$_resolved" ]] && cacertfile="$_resolved" || { echo -e "$red --cacertfile: not a valid path or PEM certificate (plain or base64).$reset"; errors=$((errors+1)); }
        else
            echo -e "$red --cacertfile: required for paid-ssl.$reset"; errors=$((errors+1))
        fi
    fi
    [[ -n "$MySQL_LOCATION" && ! "$MySQL_LOCATION" =~ ^(yes|no)$ ]] && { echo -e "$red --sqlreser: must be yes or no.$reset"; errors=$((errors+1)); }
    [[ -n "$MySQL_HOST" && ! "$MySQL_HOST" =~ ^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])(\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]))*$ && ! "$MySQL_HOST" =~ ^((25[0-5]|(2[0-4]|1[0-9]|[1-9])?[0-9])\.){3}(25[0-5]|(2[0-4]|1[0-9]|[1-9])?[0-9])$ ]] && { echo -e "$red --mysql-host: must be a valid IPv4 address or domain name (e.g. 127.0.0.1 or db.example.com).$reset"; errors=$((errors+1)); }
    [[ -n "$MySQL_USERNAME" && "$MySQL_USERNAME" =~ ^-- ]] && { echo -e "$red --sqlusername: value cannot start with '--'.$reset"; errors=$((errors+1)); }
    [[ -n "$MySQL_PASSWORD" && "$MySQL_PASSWORD" =~ ^-- ]] && { echo -e "$red --sqlpassword: value cannot start with '--'.$reset"; errors=$((errors+1)); }
    [[ -n "$MySQL_PORT" && ( ! "$MySQL_PORT" =~ ^[0-9]+$ || MySQL_PORT -lt 1 || MySQL_PORT -gt 65535 ) ]] && { echo -e "$red --mysql-port: must be a valid port number (1-65535).$reset"; errors=$((errors+1)); }
    if [[ "$MySQL_SEC" == "yes" ]]; then
        if [[ -n "$MySQL_SSLCA" ]]; then
            _resolved=$(_resolve_cert_arg "$MySQL_SSLCA" "/etc/my.cnf.d/faveo-mysql-ca.pem" "cert")
            [[ -n "$_resolved" ]] && MySQL_SSLCA="$_resolved" || { echo -e "$red --sqlsslca: not a valid path or PEM certificate (plain or base64).$reset"; errors=$((errors+1)); }
        else
            echo -e "$red --sqlsslca: required for sqlsecure.$reset"; errors=$((errors+1))
        fi
        if [[ -n "$MySQL_SSLCERT" ]]; then
            _resolved=$(_resolve_cert_arg "$MySQL_SSLCERT" "/etc/my.cnf.d/faveo-mysql-cert.pem" "cert")
            [[ -n "$_resolved" ]] && MySQL_SSLCERT="$_resolved" || { echo -e "$red --sqlsslcert: not a valid path or PEM certificate (plain or base64).$reset"; errors=$((errors+1)); }
        fi
        if [[ -n "$MySQL_SSLKEY" ]]; then
            _resolved=$(_resolve_cert_arg "$MySQL_SSLKEY" "/etc/my.cnf.d/faveo-mysql-key.pem" "key")
            [[ -n "$_resolved" ]] && MySQL_SSLKEY="$_resolved" || { echo -e "$red --sqlsslkey: not a valid path or PEM private key (plain or base64).$reset"; errors=$((errors+1)); }
        fi
    fi
    [[ -n "$MySQL_SSLVERIFY" && ! "$MySQL_SSLVERIFY" =~ ^(yes|no)$ ]] && { echo -e "$red --sqlsslverify: must be yes or no.$reset"; errors=$((errors+1)); }
    [[ -n "$ENV_SETUP"       && ! "$ENV_SETUP"       =~ ^(production|development|testing)$ ]] && { echo -e "$red --faveoenv: must be production, development, or testing.$reset"; errors=$((errors+1)); }
    [[ $errors -gt 0 ]] && exit 1
}

# ---------------------------------------------------------------------------
# Determine the system user that owns the webserver / PHP-FPM process
# Apache on RHEL-family runs as 'apache', Nginx runs as 'nginx'
# ---------------------------------------------------------------------------
webuser() {
    if [[ "$Webserver_option_value" == "nginx" ]]; then
        echo "nginx"
    else
        echo "apache"
    fi
}

# ---------------------------------------------------------------------------
# mod_ssl's default /etc/httpd/conf.d/ssl.conf ships a <VirtualHost _default_:443>
# pointing at /etc/pki/tls/certs/localhost.crt + /etc/pki/tls/private/localhost.key.
# On AlmaLinux/Rocky/RHEL those files are not generated automatically, so
# `apachectl configtest` (and any httpd restart) fails with AH00526 until they
# exist. Generate a throwaway self-signed cert at those exact paths so the
# default vhost is valid - it is never actually served, since our own
# per-domain vhost (named ServerName) takes over via SNI.
# ---------------------------------------------------------------------------
ensure_default_ssl_cert() {
    if [[ ! -s /etc/pki/tls/certs/localhost.crt || ! -s /etc/pki/tls/private/localhost.key ]]; then
        mkdir -p /etc/pki/tls/certs /etc/pki/tls/private
        openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
            -keyout /etc/pki/tls/private/localhost.key \
            -out /etc/pki/tls/certs/localhost.crt \
            -subj "/CN=localhost" 2>/dev/null
        chmod 600 /etc/pki/tls/private/localhost.key
    fi
}

rollback ()
{
    local sql_option="$1"
    local php_option="$2"
    local meili_option="$3"
    local webserver="$4"
    local node_option="$5"
    local nats_option="$6"
    local ssl_option="$7"

    local WEBUSER
    WEBUSER=$(webuser)

    echo -e "$red Rolling back Faveo installation... $reset"

    # Meilisearch
    [[ "$meili_option" =~ ^(yes|y)$ ]] && {
        systemctl stop meilisearch 2>/dev/null
        systemctl disable meilisearch 2>/dev/null
        userdel -r meilisearch 2>/dev/null
        rm -f /usr/local/bin/meilisearch /etc/meilisearch.toml
        rm -f /etc/systemd/system/meilisearch.service
        rm -rf /var/lib/meilisearch
        systemctl daemon-reload 2>/dev/null
        echo -e "$red Removed Meilisearch $reset"
    }

    # NATS Server
    [[ "$nats_option" =~ ^(yes|y)$ ]] && {
        systemctl stop nats 2>/dev/null
        systemctl disable nats 2>/dev/null
        rm -f /usr/local/bin/nats-server
        rm -f /etc/systemd/system/nats.service
        if [[ -f /etc/supervisord.d/faveo-worker.ini ]]; then
            sed -i '/\[program:faveo-Nats\]/,/^$/d' /etc/supervisord.d/faveo-worker.ini 2>/dev/null
        fi
        systemctl daemon-reload 2>/dev/null
        echo -e "$red Removed NATS Server $reset"
    }

    # Node.js & Puppeteer
    [[ "$node_option" =~ ^(yes|y)$ ]] && {
        npm uninstall -g puppeteer 2>/dev/null
        dnf remove -y nodejs 2>/dev/null
        rm -f /etc/yum.repos.d/nodesource*.repo
        echo -e "$red Removed Node.js and Puppeteer $reset"
    }

    # SQL Server cleanup
    if [[ "$sql_option" =~ ^(mysql|mariadb)$ ]]; then

        service_name="mariadb"
        [[ "$sql_option" == "mysql" ]] && service_name="mysqld"

        if [[ "$Remote_Sql_option_value" != "yes" ]] && systemctl list-unit-files | grep -q "^${service_name}\.service"; then
            if systemctl is-active --quiet "$service_name"; then
                echo -e "$yellow $service_name is running. Dropping database and user... $reset"
                mysql -u root -e "DROP DATABASE IF EXISTS faveo; DROP USER IF EXISTS 'faveo'@'localhost'; FLUSH PRIVILEGES;" 2>/dev/null || true
            else
                echo -e "$yellow $service_name is not running. Skipping DB drop. $reset"
            fi
            systemctl stop "$service_name" 2>/dev/null
            systemctl disable "$service_name" 2>/dev/null
        fi

        if [[ "$Remote_Sql_option_value" != "yes" ]]; then
            if [[ "$sql_option" == "mariadb" ]]; then
                # MariaDB-* (uppercase) is MariaDB.org's own EL8/9 package;
                # mariadb-server/mariadb (lowercase) is RHEL10's native AppStream package.
                dnf remove -y MariaDB-server MariaDB-client MariaDB-backup MariaDB-common mariadb-server mariadb 2>/dev/null
                rm -f /etc/yum.repos.d/mariadb.repo
            else
                # mysql8.4-server is RHEL10's native AppStream package name.
                dnf remove -y mysql mysql-server mysql-community-server mysql8.4-server 2>/dev/null
                dnf module reset mysql -y 2>/dev/null
            fi

            rm -rf /var/lib/mysql /etc/my.cnf.d
            dnf autoremove -y 2>/dev/null
        fi

        echo -e "$red Removed $sql_option server and database $reset"
    fi

    # PHP
    [[ -n "$php_option" ]] && {
        systemctl stop php-fpm 2>/dev/null
        dnf remove -y "php-*" 2>/dev/null
        dnf module reset php -y 2>/dev/null
        dnf autoremove -y 2>/dev/null
        echo -e "$red Removed PHP $php_option packages $reset"
    }

    # Web Server
    case "$webserver" in
        apache)
            systemctl stop httpd 2>/dev/null
            systemctl disable httpd 2>/dev/null
            rm -f /etc/httpd/conf.d/faveo*.conf
            rm -rf /etc/httpd/ssl
            rm -rf "$certfile" "$keyfile" "$cacertfile"
            dnf remove -y httpd httpd-tools mod_ssl 2>/dev/null
            dnf autoremove -y 2>/dev/null
            echo -e "$red Removed Apache and vhost configs $reset"
            ;;
        nginx)
            systemctl stop nginx 2>/dev/null
            systemctl disable nginx 2>/dev/null
            rm -f /etc/nginx/conf.d/faveo*.conf
            rm -rf /etc/nginx/ssl
            rm -rf "$certfile" "$keyfile" "$cacertfile"
            dnf remove -y nginx 2>/dev/null
            dnf autoremove -y 2>/dev/null
            echo -e "$red Removed Nginx and vhost configs $reset"
            ;;
    esac

    # SSL Certificates
    case "$ssl_option" in
        certbot)
            systemctl stop certbot-renew.timer 2>/dev/null
            dnf remove -y certbot python3-certbot-apache python3-certbot-nginx 2>/dev/null
            rm -rf /etc/letsencrypt /var/lib/letsencrypt /var/log/letsencrypt
            rm -f /etc/cron.d/faveo-ssl
            echo -e "$red Removed Certbot and Let's Encrypt certificates $reset"
            ;;
        self-signed)
            rm -rf /etc/httpd/ssl /etc/nginx/ssl
            rm -f /etc/pki/ca-trust/source/anchors/faveorootCA.crt
            echo -e "$red Removed self-signed certificates $reset"
            ;;
        paid-ssl)
            rm -f /etc/pki/ca-trust/source/anchors/faveorootCA.crt
            echo -e "$red Removed paid SSL CA from trusted store $reset"
            ;;
    esac

    # Redis & Supervisor
    systemctl stop redis 2>/dev/null
    systemctl disable redis 2>/dev/null
    systemctl stop supervisord 2>/dev/null
    systemctl disable supervisord 2>/dev/null
    rm -f /etc/supervisord.d/faveo-worker.ini
    dnf remove -y redis supervisor 2>/dev/null
    dnf autoremove -y 2>/dev/null
    echo -e "$red Removed Redis and Supervisor $reset"

    # wkhtmltopdf & IonCube
    dnf remove -y wkhtmltox 2>/dev/null
    rm -rf /usr/lib64/php/modules/ioncube* "$PWD"/ioncube* "$PWD"/wkhtmltox*.rpm
    echo -e "$red Removed wkhtmltopdf and IonCube $reset"

    # Faveo cronjob
    (sudo -u "$WEBUSER" crontab -l 2>/dev/null | grep -v "/usr/bin/php /var/www/faveo/artisan schedule:run") | sudo -u "$WEBUSER" crontab -
    echo -e "$red Removed Faveo cronjob $reset"

    # Faveo files & repo files
    rm -rf /var/www/faveo /var/www/storage
    rm -f "$PWD"/*.rpm

    # epel-release/epel-next-release/remi-release are actual installed RPM
    # packages (unlike MariaDB's/Nodesource's repo files, which shell scripts
    # write directly) - rm -f'ing their .repo file alone leaves rpm thinking
    # they're still installed, so a later "dnf install .../epel-release.rpm"
    # silently no-ops and the repo never comes back. Remove the packages.
    dnf remove -y epel-release epel-next-release remi-release 2>/dev/null
    rm -f /etc/yum.repos.d/mariadb.repo \
          /etc/yum.repos.d/remi*.repo \
          /etc/yum.repos.d/epel*.repo \
          /etc/yum.repos.d/nodesource*.repo \
          /etc/cron.d/faveo-ssl
    update-ca-trust extract 2>/dev/null
    echo -e "$red Removed Faveo files and repo sources $reset"

    systemctl daemon-reload 2>/dev/null
    echo -e "$red Rollback completed. Contact Faveo Technical Support if needed. $reset"
    exit 1
}

# Prompting Final Credentials in a Color-Coded Table
credentials () {
    OUTPUT_FILE="$PWD/credentials.txt"

    # Save to file
    cat > "$OUTPUT_FILE" << EOF
Faveo Helpdesk Installation Details
-----------------------------------
URL: https://$DomainName
Email: $Email
License Code: $LicenseCode
Order Number: $OrderNumber
Release Selected: $ReleaseSelection
SQL Option: $Sql_option_value
SQL Version Installed: $SQL_Version_Installed
PHP Version: $Php_option_value
Meilisearch Option: $Meili_option_value
Web Server: $Webserver_option_value
Node Option: $Node_option_value
NATS Option: $Nats_option_value
SSL Option: $Ssl_option_value
Database Root Password: $MySQL_PASS
Database Name: faveo
Database Username: faveo
Database Password: $MySQL_PASS
Meilisearch Master Key: $Meili_PASS
Faveo Login Username: demo_admin
Faveo Login Password: demopass
Faveo Environment: $ENV_SETUP
EOF

    # Display in a table
    echo -e "${cyan}${bold}Faveo Helpdesk Installation Summary${reset}"
    echo -e "${cyan}-------------------------------------------${reset}"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "URL:" "https://$DomainName"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "Email:" "$Email"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "License Code:" "$LicenseCode"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "Order Number:" "$OrderNumber"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "Release Selected:" "$ReleaseSelection"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "SQL Option:" "$Sql_option_value"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "SQL Version Installed:" "$SQL_Version_Installed"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "PHP Version:" "$Php_option_value"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "Meilisearch Option:" "$Meili_option_value"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "Web Server:" "$Webserver_option_value"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "Node Option:" "$Node_option_value"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "NATS Option:" "$Nats_option_value"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "SSL Option:" "$Ssl_option_value"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "Database Root Password::" "$MySQL_PASS"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "Database Name:" "faveo"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "Database Username:" "faveo"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "Database Password:" "$MySQL_PASS"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "Meilisearch Master Key:" "$Meili_PASS"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "Faveo Environment:" "$ENV_SETUP"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "Faveo Login Username:" "demo_admin"
    printf "${yellow}%-25s${green}%-40s${reset}\n" "Faveo Login Password:" "demopass"
    echo -e "${cyan}-------------------------------------------${reset}"
    echo -e "${cyan}${bold}Details also saved in $OUTPUT_FILE${reset}"

    exit 0
}

# FaveoCLI Installation
faveocli() {
    local WEBUSER
    WEBUSER=$(webuser)

    echo -e "$yellow Configuring Faveo for you.. $reset"
    cd /var/www/faveo
    php artisan install:faveo --appurl=https://$DomainName --sqlengine=mysql --sqlhost=$MySQL_HOST --dbname=faveo --dbuser=faveo --dbpass=$MySQL_PASS --sqlport=$MySQL_PORT --securecon=$MySQL_SEC --sslkey=$MySQL_SSLKEY --sslcert=$MySQL_SSLCERT --sslca=$MySQL_SSLCA --sslverify=$MySQL_SSLVERIFY --migrate=1 --dummy=0 --env=$ENV_SETUP || {
        echo -e "$red Failed to Configure Faveo Login. Rolling back... $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
        return 1
    }

    chown -R "$WEBUSER":"$WEBUSER" /var/www/faveo

    # Starting supervisor
    systemctl start supervisord

    # Uncomment Faveo schedule cron
    sudo -u www-data crontab -l 2>/dev/null | \
    sed 's|^# \(\* \* \* \* \* /usr/bin/php /var/www/faveo/artisan schedule:run.*\)|\1|' | \
    sudo -u www-data crontab -


    credentials "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$MySQL_PASS" "$Meili_PASS"
}

# Redis & Cron:
redis() {
    local WEBUSER
    WEBUSER=$(webuser)

    echo -e "$yellow Installing and Configuring Redis & Supervisor... $reset"

    local os_ver_redis os_major_redis
    os_ver_redis=$(grep '^VERSION_ID=' /etc/os-release | cut -d '=' -f2 | tr -d '"')
    os_major_redis=${os_ver_redis%%.*}

    if [[ "$os_major_redis" -ge 10 ]]; then
        # RHEL10 replaced Redis with Valkey in its own AppStream, so the plain
        # "redis" package no longer resolves the same way there. Pull real
        # Redis from Remi's modular repo instead - Remi still ships its own
        # module metadata regardless of RHEL10 dropping native modularity.
        dnf install -y epel-release 2>/dev/null
        dnf install -y "https://rpms.remirepo.net/enterprise/remi-release-${os_major_redis}.rpm" 2>/dev/null
        dnf config-manager --set-enabled remi-modular 2>/dev/null
        dnf module reset redis -y 2>/dev/null
        dnf module enable -y redis:remi-8.0 || {
            echo -e "$red Failed to enable Remi's Redis module stream on EL${os_major_redis}. Rolling back... $reset"
            rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
            return 1
        }
    fi

    dnf install -y redis supervisor || {
        echo -e "$red Failed to install Redis or Supervisor. Rolling back... $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
        return 1
    }

    systemctl enable --now redis supervisord || {
        echo -e "$red Failed to enable/start services. Rolling back... $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
        return 1
    }

    chown -R "$WEBUSER":"$WEBUSER" /var/www
    if [[ "$Nats_option_value" =~ ^(y|yes)$ ]]; then
        cat <<EOF >/etc/supervisord.d/faveo-worker.ini
[program:faveo-Horizon]
process_name=%(program_name)s
command=php /var/www/faveo/artisan horizon
autostart=true
autorestart=true
user=$WEBUSER
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/horizon-worker.log

[program:faveo-websockets-subscribe]
process_name=%(program_name)s
command=php /var/www/faveo/artisan socket:serve
autostart=true
autorestart=true
user=root
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/socket-worker.log

[program:faveo-websockets-node]
process_name=%(program_name)s
command=node /var/www/faveo/resources/assets/js/socket
autostart=true
autorestart=true
user=root
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/node-server.log

[program:faveo-Nats]
process_name=%(program_name)s
command=php /var/www/faveo/artisan nats:listen
autostart=true
autorestart=true
user=$WEBUSER
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/nats-worker.log
EOF
    else
        cat <<EOF >/etc/supervisord.d/faveo-worker.ini
[program:faveo-Horizon]
process_name=%(program_name)s
command=php /var/www/faveo/artisan horizon
autostart=true
autorestart=true
user=$WEBUSER
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/horizon-worker.log

[program:faveo-websockets-subscribe]
process_name=%(program_name)s
command=php /var/www/faveo/artisan socket:serve
autostart=true
autorestart=true
user=root
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/socket-worker.log

[program:faveo-websockets-node]
process_name=%(program_name)s
command=node /var/www/faveo/resources/assets/js/socket
autostart=true
autorestart=true
user=root
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/node-server.log

EOF
    fi

    systemctl restart supervisord || {
        echo -e "$red Supervisor restart failed. Rolling back... $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
        return 1
    }
    systemctl stop supervisord

    (sudo -u "$WEBUSER" crontab -l 2>/dev/null | grep -q "artisan schedule:run") || \
        (sudo -u "$WEBUSER" crontab -l 2>/dev/null; echo "#* * * * * /usr/bin/php /var/www/faveo/artisan schedule:run 2>&1") | \
        sudo -u "$WEBUSER" crontab -
    echo -e "$green Redis & Supervisor configured. Setting up cron... $reset"
    sleep 1
    faveocli "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$MySQL_PASS" "$Meili_PASS"
}

# Meilisearch Installation:
meilisearch () {
    echo -e "$yellow Installing and Configuring Meilisearch $reset"

    curl -L https://install.meilisearch.com | sh || {
        echo -e "$red Failed to download Meilisearch. Rolling back... $reset";
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"; return 1;
    }
    chmod +x meilisearch
    mv ./meilisearch /usr/local/bin/ || {
        echo -e "$red Failed to move Meilisearch binary. Rolling back... $reset";
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"; return 1;
    }

    id -u meilisearch &>/dev/null || useradd -d /var/lib/meilisearch -b /bin/false -m -r meilisearch

    curl -fsSL https://raw.githubusercontent.com/meilisearch/meilisearch/latest/config.toml -o /etc/meilisearch.toml || {
        echo -e "$red Failed to download Meilisearch config. Rolling back... $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"; return 1
    }

    Meili_PASS=$(openssl rand -base64 24)
    sed -i 's|env =.*|env = "production"|g' /etc/meilisearch.toml
    sed -i "s|# master_key =.*|master_key = \"$Meili_PASS\"|g" /etc/meilisearch.toml
    sed -i 's|db_path =.*|db_path = "/var/lib/meilisearch/data"|g' /etc/meilisearch.toml
    sed -i 's|dump_dir = .*|dump_dir = "/var/lib/meilisearch/dumps"|g' /etc/meilisearch.toml
    sed -i 's|snapshot_dir =.*|snapshot_dir = "/var/lib/meilisearch/snapshots"|g' /etc/meilisearch.toml

    mkdir -p /var/lib/meilisearch/{data,dumps,snapshots}
    chown -R meilisearch:meilisearch /var/lib/meilisearch
    chmod 750 /var/lib/meilisearch

    cat <<'EOF' > /etc/systemd/system/meilisearch.service
[Unit]
Description=Meilisearch
After=systemd-user-sessions.service

[Service]
Type=simple
WorkingDirectory=/var/lib/meilisearch
ExecStart=/usr/local/bin/meilisearch --config-file-path /etc/meilisearch.toml
User=meilisearch
Group=meilisearch

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable meilisearch
    systemctl start meilisearch

    if [[ $? -ne 0 ]]; then
        echo -e "$red Something went wrong configuring Meilisearch. Rolling back... $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
        return 1
    fi

    systemctl restart php-fpm
    if [[ "$Webserver_option_value" == "apache" ]]; then
        systemctl restart httpd
    elif [[ "$Webserver_option_value" == "nginx" ]]; then
        systemctl restart nginx
    fi

    echo -e "$green Meilisearch is configured successfully. $reset"
    sleep 1

    redis "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$MySQL_PASS" "$Meili_PASS"
}

# Extensions: Ioncube and Wkhtmltopdf
extensions () {
    echo -e "$yellow Installing Ioncube and Wkhtmltopdf $reset"

    OS_VER=$(grep '^VERSION_ID=' /etc/os-release | cut -d '"' -f 2)
    OS_MAJOR=${OS_VER%%.*}

    # Ioncube Loader
    wget -q https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
    if [[ $? -ne 0 ]]; then
        echo -e "$red Failed to download Ioncube loaders. Rolling back... $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
        return 1
    fi

    tar -zxf ioncube_loaders_lin_x86-64.tar.gz
    php_path=$(php -r 'echo ini_get("extension_dir");')
    cp "ioncube/ioncube_loader_lin_${Php_option_value}.so" "$php_path/" || {
        echo -e "$red Failed to copy Ioncube loader. Rolling back... $reset";
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile";
        return 1;
    }
    rm -rf ioncube*

    # Remi packaging keeps a single php.ini for all SAPIs
    if [[ -f /etc/php.ini ]]; then
        sed -i "2 a zend_extension = \"$php_path/ioncube_loader_lin_${Php_option_value}.so\"" /etc/php.ini || {
            echo -e "$red Failed to update php.ini. Rolling back... $reset"
            rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
            return 1
        }
    fi

    # Wkhtmltopdf Installation
    dnf install -y xorg-x11-fonts-75dpi xorg-x11-fonts-Type1 libpng libjpeg-turbo openssl libicu libX11 libXext libXrender || {
        echo -e "$red Failed to install font/dependency packages. Rolling back... $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
        return 1
    }

    # wkhtmltopdf upstream only publishes builds for almalinux8 and almalinux9.
    # EL10 has no dedicated build; the almalinux9 RPM installs and works via compat libs.
    local wk_ver="$OS_MAJOR"
    [[ "$OS_MAJOR" -ge 10 ]] && wk_ver="9"
    local wkurl="https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox-0.12.6.1-2.almalinux${wk_ver}.x86_64.rpm"

    wget -q "$wkurl" -O wkhtmltox.rpm || { echo -e "$red Failed to download wkhtmltopdf. Rolling back... $reset"; rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"; return 1; }
    dnf install -y ./wkhtmltox.rpm || { echo -e "$red Failed to install wkhtmltopdf. Rolling back... $reset"; rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"; return 1; }
    rm -f ./wkhtmltox.rpm

    systemctl restart php-fpm || { echo -e "$red Failed to restart PHP-FPM. Rolling back... $reset"; rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"; return 1; }

    if [[ "$Webserver_option_value" == "apache" ]]; then
        systemctl restart httpd || { echo -e "$red Failed to restart Apache. Rolling back... $reset"; rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"; return 1; }
    elif [[ "$Webserver_option_value" == "nginx" ]]; then
        systemctl restart nginx || { echo -e "$red Failed to restart Nginx. Rolling back... $reset"; rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"; return 1; }
    fi

    echo -e "$green Ioncube and Wkhtmltopdf configured successfully $reset"
    sleep 1

    if [[ "$Meili_option_value" == yes ]]; then
        meilisearch "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$MySQL_PASS"
    elif [[ "$Meili_option_value" == no ]]; then
        redis "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$MySQL_PASS"
    fi
}

# Faveo Filesystem Configure:
faveo_configure () {
    local WEBUSER
    WEBUSER=$(webuser)

    echo -e "$yellow Configuring Faveo... $reset"

    FAVEO_ZIP="$PWD/faveo.zip"
    DOWNLOAD_URL="https://billing.faveohelpdesk.com/download/faveo?order_number=$OrderNumber&serial_key=$LicenseCode&release=$ReleaseSelection"

    echo -e "$yellow Downloading Faveo package... $reset"

    if ! curl -fSL "$DOWNLOAD_URL" -o "$FAVEO_ZIP"; then
        echo -e "$red Failed to download Faveo package. $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
        return
    fi

    echo -e "$yellow Download successful. Unzipping to /var/www/faveo... $reset"
    mkdir -p /var/www/faveo /var/www/storage /var/www/faveo/storage/logs

    if ! unzip -o "$FAVEO_ZIP" -d /var/www/faveo >/dev/null 2>&1; then
        echo -e "$red Failed to unzip Faveo package. $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
        return
    fi

    rm -f "$FAVEO_ZIP"

    chown -R "$WEBUSER":"$WEBUSER" /var/www
    find /var/www/faveo -type f -exec chmod 644 {} \;
    find /var/www/faveo -type d -exec chmod 755 {} \;

    echo -e "$green Faveo files configured successfully. $reset"
    sleep 1

    extensions "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$MySQL_PASS"
}

# Attempts to set up and install MariaDB (10.6 or 11.8 only) via the official
# mariadb_repo_setup script, which auto-detects dnf-based systems.
# Returns 0 on success (sets SQL_Version_Installed and Sql_option_value=mariadb),
# 1 on failure. Does NOT rollback - caller decides what to do next.
attempt_mariadb() {
    echo -e "$green Setting up MariaDB repository... $reset"

    # RHEL 10 dropped dnf modularity, and MariaDB.org's own mariadb_repo_setup
    # script explicitly rejects EL10 ("version (10.0) is not supported").
    # RHEL10 ships MariaDB 10.11 natively in AppStream as a plain RPM instead -
    # install that directly rather than going through mariadb_repo_setup.
    if [[ "$OS_MAJOR" -ge 10 ]]; then
        dnf install -y mariadb-server mariadb || {
            echo -e "$yellow MariaDB package installation failed on EL${OS_MAJOR}. $reset"
            return 1
        }
        systemctl enable mariadb && systemctl start mariadb

        SQL_Version_Installed=$(rpm -q --qf '%{VERSION}' mariadb-server 2>/dev/null)
        echo -e "$green MariaDB $SQL_Version_Installed (RHEL${OS_MAJOR} native AppStream package) installed successfully. $reset"

        Sql_option_value="mariadb"
        return 0
    fi

    MariaDB_Allowed_Versions=("10.6" "11.8")
    MariaDB_Version=""

    for v in "${MariaDB_Allowed_Versions[@]}"; do
        curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
        chmod +x mariadb_repo_setup

        if bash mariadb_repo_setup --mariadb-server-version="$v" > mariadb_repo_setup.log 2>&1; then
            MariaDB_Version="$v"
            echo -e "$green MariaDB $v repository configured successfully for $OS_ID $OS_VER. $reset"
            rm -f mariadb_repo_setup mariadb_repo_setup.log
            break
        else
            echo -e "$yellow MariaDB $v is not available for $OS_ID $OS_VER. $reset"
            cat mariadb_repo_setup.log
            rm -f mariadb_repo_setup mariadb_repo_setup.log
        fi
    done

    if [[ -z "$MariaDB_Version" ]]; then
        echo -e "$yellow Neither supported MariaDB version (10.6, 11.8) is available for $OS_ID $OS_VER. $reset"
        rm -f /etc/yum.repos.d/mariadb.repo
        return 1
    fi

    dnf install -y boost-program-options
    dnf install -y MariaDB-server MariaDB-client MariaDB-backup || {
        echo -e "$yellow MariaDB package installation failed. $reset"
        return 1
    }
    systemctl enable mariadb && systemctl start mariadb

    SQL_Version_Installed=$(rpm -q --qf '%{VERSION}' MariaDB-server 2>/dev/null)

    # Final safety check: confirm what actually got installed is one of the
    # two allowed series.
    if [[ ! "$SQL_Version_Installed" =~ ^10\.6\. ]] && [[ ! "$SQL_Version_Installed" =~ ^11\.8\. ]]; then
        echo -e "$yellow Installed MariaDB version ($SQL_Version_Installed) is outside the supported 10.6/11.8 range. $reset"
        return 1
    fi

    Sql_option_value="mariadb"
    return 0
}

# Attempts to set up and install MySQL (8.0 or 8.4 only) via dnf module streams.
# Returns 0 on success (sets SQL_Version_Installed and Sql_option_value=mysql),
# 1 on failure. Does NOT rollback - caller decides what to do next.
attempt_mysql() {
    echo -e "$yellow Setting up MySQL via dnf module stream... $reset"

    # RHEL 10 removed dnf modularity entirely - there is no "mysql:8.4" module
    # to enable. RHEL10 ships MySQL 8.4 natively in AppStream instead, under
    # the renamed package mysql8.4-server (service unit stays "mysqld").
    if [[ "$OS_MAJOR" -ge 10 ]]; then
        dnf install -y mysql8.4-server || {
            echo -e "$yellow MySQL package installation failed on EL${OS_MAJOR}. $reset"
            return 1
        }
        systemctl enable mysqld && systemctl start mysqld

        SQL_Version_Installed=$(rpm -q --qf '%{VERSION}' mysql8.4-server 2>/dev/null)
        if [[ ! "$SQL_Version_Installed" =~ ^8\.4\. ]]; then
            echo -e "$yellow Installed MySQL version ($SQL_Version_Installed) is outside the supported 8.4 range for EL${OS_MAJOR}. $reset"
            return 1
        fi

        echo -e "$green MySQL $SQL_Version_Installed (RHEL${OS_MAJOR} native AppStream package) installed successfully. $reset"
        Sql_option_value="mysql"
        return 0
    fi

    MySQL_Allowed_Versions=("8.0" "8.4")
    MySQL_Version=""

    for v in "${MySQL_Allowed_Versions[@]}"; do
        dnf module reset mysql -y 2>/dev/null
        if dnf module enable -y "mysql:$v" 2>/dev/null; then
            MySQL_Version="$v"
            echo -e "$green MySQL $v module stream is available for $OS_ID $OS_VER. $reset"
            break
        else
            echo -e "$yellow MySQL $v module stream is not available for $OS_ID $OS_VER. $reset"
        fi
    done

    if [[ -z "$MySQL_Version" ]]; then
        echo -e "$yellow Neither supported MySQL version (8.0, 8.4) is available for $OS_ID $OS_VER. $reset"
        dnf module reset mysql -y 2>/dev/null
        return 1
    fi

    dnf install -y mysql mysql-server || {
        echo -e "$yellow MySQL installation failed. $reset"
        dnf module reset mysql -y 2>/dev/null
        return 1
    }
    systemctl enable mysqld && systemctl start mysqld

    SQL_Version_Installed=$(rpm -q --qf '%{VERSION}' mysql-server 2>/dev/null)

    # Final safety check: confirm what actually got installed is one of the
    # two allowed series.
    if [[ ! "$SQL_Version_Installed" =~ ^8\.0\. ]] && [[ ! "$SQL_Version_Installed" =~ ^8\.4\. ]]; then
        echo -e "$yellow Installed MySQL version ($SQL_Version_Installed) is outside the supported 8.0/8.4 range. $reset"
        return 1
    fi

    Sql_option_value="mysql"
    return 0
}

# SQL Installation:
sql_installation() {

    echo -e "$yellow Installing SQL server... $reset"

    # Detect OS and version
    OS_ID=$(grep '^ID=' /etc/os-release | cut -d '=' -f2 | tr -d '"')
    OS_VER=$(grep '^VERSION_ID=' /etc/os-release | cut -d '=' -f2 | tr -d '"')
    OS_MAJOR=${OS_VER%%.*}

    SQL_Version_Installed=""
    Preferred_Sql_option_value="$Sql_option_value"

    if [[ "$Remote_Sql_option_value" == "yes" ]]; then
        # A lightweight client (covers both engines) is enough to reach out to
        # the existing remote server - no local SQL server gets installed.
        dnf install -y mariadb 2>/dev/null || dnf install -y mysql 2>/dev/null

        echo -e "$green Using existing remote SQL server at $MySQL_HOST:${MySQL_PORT:-3306} - skipping local SQL server installation. $reset"
        SQL_Version_Installed="remote ($Sql_option_value @ $MySQL_HOST)"
    else
        # Try the user's chosen engine first (MariaDB: 10.6/11.8, MySQL: 8.0/8.4;
        # on EL10 both attempt_* functions instead install RHEL10's native
        # AppStream package for their engine - see attempt_mariadb/attempt_mysql).
        # If that engine has no supported version available for this OS/release,
        # automatically cross over and try the other engine instead. Only roll
        # back if NONE of the four supported versions are available anywhere.
        if [[ "$Preferred_Sql_option_value" == "mariadb" ]]; then
            if ! attempt_mariadb; then
                echo -e "$yellow MariaDB (10.6/11.8) is not available on $OS_ID $OS_VER. Checking MySQL (8.0/8.4) instead... $reset"
                if ! attempt_mysql; then
                    echo -e "$red None of the supported SQL versions (MariaDB 10.6/11.8, MySQL 8.0/8.4) are available for $OS_ID $OS_VER. Rolling back... $reset"
                    rollback "$Preferred_Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
                    return
                fi
            fi
        else
            if ! attempt_mysql; then
                echo -e "$yellow MySQL (8.0/8.4) is not available on $OS_ID $OS_VER. Checking MariaDB (10.6/11.8) instead... $reset"
                if ! attempt_mariadb; then
                    echo -e "$red None of the supported SQL versions (MySQL 8.0/8.4, MariaDB 10.6/11.8) are available for $OS_ID $OS_VER. Rolling back... $reset"
                    rollback "$Preferred_Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
                    return
                fi
            fi
        fi

        if [[ "$Sql_option_value" != "$Preferred_Sql_option_value" ]]; then
            echo -e "$green Installing $Sql_option_value instead, since $Preferred_Sql_option_value had no supported version for this OS/release. $reset"
        fi
    fi

    echo -e "$yellow Configuring database and users... $reset"

    if [[ "$Remote_Sql_option_value" == "yes" ]]; then
        MySQL_PORT="${MySQL_PORT:-3306}"

        # Build the mysql client SSL flags if a secure connection was requested.
        MYSQL_SSL_ARGS=()
        if [[ "$MySQL_SEC" == "yes" ]]; then
            [[ -n "$MySQL_SSLCA" ]]   && MYSQL_SSL_ARGS+=(--ssl-ca="$MySQL_SSLCA")
            [[ -n "$MySQL_SSLCERT" ]] && MYSQL_SSL_ARGS+=(--ssl-cert="$MySQL_SSLCERT")
            [[ -n "$MySQL_SSLKEY" ]]  && MYSQL_SSL_ARGS+=(--ssl-key="$MySQL_SSLKEY")
            if [[ "$MySQL_SSLVERIFY" == "yes" ]]; then
                MYSQL_SSL_ARGS+=(--ssl-mode=VERIFY_IDENTITY)
            else
                MYSQL_SSL_ARGS+=(--ssl-mode=VERIFY_CA)
            fi
        fi

        DB_AUTH_CMD=(mysql -h "$MySQL_HOST" -P "$MySQL_PORT" -u "$MySQL_USERNAME" -p"$MySQL_PASSWORD" "${MYSQL_SSL_ARGS[@]}")

        if ! "${DB_AUTH_CMD[@]}" -e "SELECT 1;" &>/dev/null; then
            echo -e "$red Could not connect to the remote SQL server at $MySQL_HOST:$MySQL_PORT with the supplied credentials. Rolling back... $reset"
            rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
            return
        fi

        # Generate random password for the faveo application database user
        MySQL_PASS=$(openssl rand -base64 12)

        "${DB_AUTH_CMD[@]}" <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS faveo;
DROP USER IF EXISTS 'faveo'@'%';
CREATE USER 'faveo'@'%' IDENTIFIED BY '$MySQL_PASS';
GRANT ALL PRIVILEGES ON faveo.* TO 'faveo'@'%';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
        SQL_SETUP_STATUS=$?
    else
        # Defaults so downstream consumers (faveocli's artisan install:faveo)
        # always get valid values. "localhost" (not 127.0.0.1) is intentional:
        # it matches the 'faveo'@'localhost' grant below and makes PHP's
        # MySQL drivers connect via the local unix socket rather than TCP.
        MySQL_HOST="${MySQL_HOST:-localhost}"
        MySQL_PORT="${MySQL_PORT:-3306}"
        MySQL_SEC="${MySQL_SEC:-no}"

        # Generate random password
        MySQL_PASS=$(openssl rand -base64 12)

        # SMART AUTHENTICATION CHECK: Detects if database is fresh (root) or pre-existing
        if mysql -u root -proot -e "STATUS" &>/dev/null; then
            # Fresh install scenario: Use placeholder credential 'root'
            DB_AUTH_CMD="mysql -u root -proot"
        else
            # Existing install scenario: Authenticate using native system root process socket
            DB_AUTH_CMD="mysql -u root"
        fi

        # Create database and user using the dynamically discovered auth channel
        $DB_AUTH_CMD <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS faveo;
DROP USER IF EXISTS 'faveo'@'localhost';
CREATE USER 'faveo'@'localhost' IDENTIFIED BY '$MySQL_PASS';
GRANT ALL PRIVILEGES ON faveo.* TO 'faveo'@'localhost';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MySQL_PASS';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
        SQL_SETUP_STATUS=$?
    fi

    if [[ $SQL_SETUP_STATUS -ne 0 ]]; then
        echo -e "$red SQL setup failed. Rolling back... $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
    else
        echo -e "$green SQL server configured successfully (Version: $SQL_Version_Installed) $reset"
        sleep 1
        faveo_configure "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$MySQL_PASS"
    fi
}

# Certbot Apache:
certbot_apache() {
    echo -e "$yellow Obtaining Certificates for $DomainName from Let's Encrypt... $reset"

    dnf install -y python3-certbot-apache certbot
    [[ "$Webserver_option_value" == "apache" ]] && ensure_default_ssl_cert

    certbot run -n --apache --agree-tos -d "$DomainName" -m "$Email" --redirect -q
    if [[ $? -ne 0 ]]; then
        echo -e "$red Failed to obtain SSL certificates for $DomainName. Check firewall/DNS. $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
        return
    fi

    echo -e "$green Certificate obtained successfully for $DomainName. $reset"

    echo "45 2 * * 6 /usr/bin/certbot renew --quiet && /bin/systemctl restart httpd.service" | sudo tee /etc/cron.d/faveo-ssl
    sleep 1

    sql_installation "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value"
}

#Certbot Nginx:
certbot_nginx() {
    echo -e "$yellow Obtaining Certificates for $DomainName from Let's Encrypt... $reset"

    dnf install -y python3-certbot-nginx certbot

    certbot run -n --nginx --agree-tos -d "$DomainName" -m "$Email" --redirect -q
    if [[ $? -ne 0 ]]; then
        echo -e "$red Failed to obtain SSL certificates for $DomainName. Check firewall/DNS. $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
        return
    fi

    echo -e "$green Certificate obtained successfully for $DomainName. $reset"

    echo "45 2 * * 6 /usr/bin/certbot renew --quiet && /bin/systemctl restart nginx.service" | sudo tee /etc/cron.d/faveo-ssl
    sleep 1

    sql_installation "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value"
}

#Self Signed Apache installation:
self_signed_apache() {
    echo -e "$yellow Generating Self Signed SSL certificates for $DomainName... $reset"

    SSL_DIR="/etc/httpd/ssl"
    mkdir -p "$SSL_DIR"

    openssl ecparam -out "$SSL_DIR/faveoroot.key" -name prime256v1 -genkey
    openssl req -new -sha256 -key "$SSL_DIR/faveoroot.key" -out "$SSL_DIR/faveoroot.csr" \
        -subj "/C=IN/ST=Karnataka/L=Bangalore/O=Ladybird Web Solutions Pvt Ltd/OU=Dev Team/CN=$DomainName"
cat > "$SSL_DIR/root_ca.ext" <<EOF
basicConstraints=critical,CA:TRUE
keyUsage=critical,keyCertSign,cRLSign
EOF
    openssl x509 -req -sha256 -days 7300 -in "$SSL_DIR/faveoroot.csr" -signkey "$SSL_DIR/faveoroot.key" \
        -out "$SSL_DIR/faveorootCA.crt" -extfile "$SSL_DIR/root_ca.ext"

    openssl ecparam -out "$SSL_DIR/private.key" -name prime256v1 -genkey
    openssl req -new -sha256 -key "$SSL_DIR/private.key" -out "$SSL_DIR/faveolocal.csr" \
        -subj "/C=IN/ST=Karnataka/L=Bangalore/O=Ladybird Web Solutions Pvt Ltd/OU=Development Team/CN=$DomainName"
cat > "$SSL_DIR/faveolocal.ext" <<EOF
basicConstraints=CA:FALSE
subjectAltName=DNS:$DomainName
extendedKeyUsage=serverAuth
keyUsage=digitalSignature,keyEncipherment
EOF
    openssl x509 -req -in "$SSL_DIR/faveolocal.csr" -CA "$SSL_DIR/faveorootCA.crt" -CAkey "$SSL_DIR/faveoroot.key" \
        -CAcreateserial -out "$SSL_DIR/faveolocal.crt" -days 7300 -sha256 -extfile "$SSL_DIR/faveolocal.ext"

    if [[ $? -ne 0 ]]; then
        echo -e "$red Certificate generation failed $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
        return
    fi

    cp -f "$SSL_DIR/faveorootCA.crt" /etc/pki/ca-trust/source/anchors/
    update-ca-trust extract

    dnf install -y mod_ssl
    ensure_default_ssl_cert

    if [[ "$Nats_option_value" =~ ^(y|yes)$ ]]; then
cat <<EOF > /etc/httpd/conf.d/faveo-ssl.conf
<VirtualHost *:443>
    ServerName $DomainName
    DocumentRoot /var/www/faveo/public
    <Directory /var/www/faveo>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/httpd/faveo-ssl-error.log
    CustomLog /var/log/httpd/faveo-ssl-access.log combined

    Header always unset X-Frame-Options
    Header always set Content-Security-Policy "default-src 'self'; \
style-src 'self' https://fonts.googleapis.com 'unsafe-inline'; \
font-src 'self' https://fonts.gstatic.com data:; \
script-src 'self' https://www.google.com/recaptcha/ https://www.gstatic.com/recaptcha/ https://cdnjs.cloudflare.com 'unsafe-inline' 'unsafe-eval'; \
frame-src https://www.google.com/recaptcha/ https://www.gstatic.com/recaptcha/; \
connect-src 'self'; \
img-src 'self' data: https://secure.gravatar.com; \
frame-ancestors 'self'"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set X-Content-Type-Options "nosniff"
    Header always set Referrer-Policy "strict-origin"
    Header always set Permissions-Policy "geolocation=(), midi=(), sync-xhr=(), microphone=(), camera=(), magnetometer=(), gyroscope=(), fullscreen=(self), payment=()"
    Header edit Set-Cookie ^(.*)$ "$1; HttpOnly; Secure"
    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"

    SSLEngine on
    SSLCertificateFile $SSL_DIR/faveolocal.crt
    SSLCertificateKeyFile $SSL_DIR/private.key
    SSLCertificateChainFile $SSL_DIR/faveorootCA.crt

    ProxyPreserveHost On
    SSLProxyEngine On

    ProxyPass /fc/ http://localhost:6001/fc/ retry=0
    ProxyPassReverse /fc/ http://localhost:6001/fc/

    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteCond %{HTTP:Connection} upgrade [NC]
    RewriteRule ^/fc/(.*) ws://localhost:6001/fc/\$1 [P,L]

    ProxyPass "/natsws" "ws://127.0.0.1:9235/"
    ProxyPassReverse "/natsws" "ws://127.0.0.1:9235/"
    Header always set Upgrade "websocket"
    Header always set Connection "Upgrade"
    Header always set X-Forwarded-Host %{HTTP_HOST}e
    Header always set X-Forwarded-For %{REMOTE_ADDR}e
    Header always set X-Forwarded-Proto %{HTTPS}e
</VirtualHost>
EOF
    else
cat <<EOF > /etc/httpd/conf.d/faveo-ssl.conf
<VirtualHost *:443>
    ServerName $DomainName
    DocumentRoot /var/www/faveo/public
    <Directory /var/www/faveo>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/httpd/faveo-ssl-error.log
    CustomLog /var/log/httpd/faveo-ssl-access.log combined

    Header always unset X-Frame-Options
    Header always set Content-Security-Policy "default-src 'self'; \
style-src 'self' https://fonts.googleapis.com 'unsafe-inline'; \
font-src 'self' https://fonts.gstatic.com data:; \
script-src 'self' https://www.google.com/recaptcha/ https://www.gstatic.com/recaptcha/ https://cdnjs.cloudflare.com 'unsafe-inline' 'unsafe-eval'; \
frame-src https://www.google.com/recaptcha/ https://www.gstatic.com/recaptcha/; \
connect-src 'self'; \
img-src 'self' data: https://secure.gravatar.com; \
frame-ancestors 'self'"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set X-Content-Type-Options "nosniff"
    Header always set Referrer-Policy "strict-origin"
    Header always set Permissions-Policy "geolocation=(), midi=(), sync-xhr=(), microphone=(), camera=(), magnetometer=(), gyroscope=(), fullscreen=(self), payment=()"
    Header edit Set-Cookie ^(.*)$ "$1; HttpOnly; Secure"
    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"

    SSLEngine on
    SSLCertificateFile $SSL_DIR/faveolocal.crt
    SSLCertificateKeyFile $SSL_DIR/private.key
    SSLCertificateChainFile $SSL_DIR/faveorootCA.crt

    ProxyPreserveHost On
    SSLProxyEngine On

    ProxyPass /fc/ http://localhost:6001/fc/ retry=0
    ProxyPassReverse /fc/ http://localhost:6001/fc/

    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteCond %{HTTP:Connection} upgrade [NC]
    RewriteRule ^/fc/(.*) ws://localhost:6001/fc/\$1 [P,L]
</VirtualHost>
EOF
    fi

    systemctl restart php-fpm httpd
    local test
    test=$(curl -ks https://"$DomainName"/test.html)
    if [[ "$test" == "Test" ]]; then
        echo -e "$green Self Signed SSL successfully configured for $DomainName. $reset"
        sleep 1
        sql_installation "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value"
    else
        echo -e "$red Self Signed SSL configuration failed for $DomainName. $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
    fi
}

# Self Signed Nginx installation:
self_signed_nginx() {
    echo -e "$yellow Generating Self Signed SSL certificates for $DomainName... $reset"

    SSL_DIR="/etc/nginx/ssl"
    mkdir -p "$SSL_DIR"

    openssl ecparam -out "$SSL_DIR/faveoroot.key" -name prime256v1 -genkey
    openssl req -new -sha256 -key "$SSL_DIR/faveoroot.key" -out "$SSL_DIR/faveoroot.csr" \
        -subj "/C=IN/ST=Karnataka/L=Bangalore/O=Ladybird Web Solutions Pvt Ltd/OU=Dev Team/CN=$DomainName"
cat > "$SSL_DIR/root_ca.ext" <<EOF
basicConstraints=critical,CA:TRUE
keyUsage=critical,keyCertSign,cRLSign
EOF
    openssl x509 -req -sha256 -days 7300 -in "$SSL_DIR/faveoroot.csr" -signkey "$SSL_DIR/faveoroot.key" \
        -out "$SSL_DIR/faveorootCA.crt" -extfile "$SSL_DIR/root_ca.ext"

    openssl ecparam -out "$SSL_DIR/private.key" -name prime256v1 -genkey
    openssl req -new -sha256 -key "$SSL_DIR/private.key" -out "$SSL_DIR/faveolocal.csr" \
        -subj "/C=IN/ST=Karnataka/L=Bangalore/O=Ladybird Web Solutions Pvt Ltd/OU=Development Team/CN=$DomainName"
cat > "$SSL_DIR/faveolocal.ext" <<EOF
basicConstraints=CA:FALSE
subjectAltName=DNS:$DomainName
extendedKeyUsage=serverAuth
keyUsage=digitalSignature,keyEncipherment
EOF
    openssl x509 -req -in "$SSL_DIR/faveolocal.csr" -CA "$SSL_DIR/faveorootCA.crt" -CAkey "$SSL_DIR/faveoroot.key" \
        -CAcreateserial -out "$SSL_DIR/faveolocal.crt" -days 7300 -sha256 -extfile "$SSL_DIR/faveolocal.ext"

    if [[ $? -eq 0 ]]; then
        echo -e "$green Certificates generated successfully for $DomainName $reset"
    else
        echo -e "$red Certificate generation failed $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
        return
    fi

    cp -f "$SSL_DIR/faveorootCA.crt" /etc/pki/ca-trust/source/anchors/
    update-ca-trust extract

    if [[ "$Nats_option_value" =~ ^(y|yes)$ ]]; then
cat <<EOF > /etc/nginx/conf.d/faveo-ssl.conf
server {
    listen 80;
    listen [::]:80;
    root /var/www/faveo/public;
    index index.php index.html index.htm;
    server_name $DomainName;

    client_max_body_size 100M;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        try_files \$uri =404;
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    listen 443 ssl;
    ssl_certificate $SSL_DIR/faveolocal.crt;
    ssl_certificate_key $SSL_DIR/private.key;
    ssl_trusted_certificate $SSL_DIR/faveorootCA.crt;

    # NATS Proxy
    location ~ ^/natsws {
        proxy_pass http://127.0.0.1:9235;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-Host \$host:\$server_port;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
    else
cat <<EOF > /etc/nginx/conf.d/faveo-ssl.conf
server {
    listen 80;
    listen [::]:80;
    root /var/www/faveo/public;
    index index.php index.html index.htm;
    server_name $DomainName;

    client_max_body_size 100M;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        try_files \$uri =404;
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    listen 443 ssl;
    ssl_certificate $SSL_DIR/faveolocal.crt;
    ssl_certificate_key $SSL_DIR/private.key;
    ssl_trusted_certificate $SSL_DIR/faveorootCA.crt;
}
EOF
    fi

    systemctl restart php-fpm nginx

    local test
    test=$(curl -ks https://"$DomainName"/test.html)
    if [[ "$test" == "Test" ]]; then
        echo -e "$green Self Signed SSL successfully configured for $DomainName. $reset"
        sleep 1
        sql_installation "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value"
    else
        echo -e "$red Self Signed SSL configuration failed for $DomainName. $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
    fi
}

# Paid SSL Apache installation:
paid_ssl_apache() {
    echo -e "$yellow Configuring Paid SSL for $DomainName on Apache... $reset"

    dnf install -y mod_ssl
    ensure_default_ssl_cert

    FAVEO_WEBROOT="/var/www/faveo/public"

    if [[ "$Nats_option_value" =~ ^(y|yes)$ ]]; then
cat <<EOF > /etc/httpd/conf.d/faveo-ssl.conf
<VirtualHost *:443>
    ServerName $DomainName
    DocumentRoot /var/www/faveo/public
    <Directory /var/www/faveo>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/httpd/faveo-ssl-error.log
    CustomLog /var/log/httpd/faveo-ssl-access.log combined

    Header always unset X-Frame-Options
    Header always set Content-Security-Policy "default-src 'self'; \
style-src 'self' https://fonts.googleapis.com 'unsafe-inline'; \
font-src 'self' https://fonts.gstatic.com data:; \
script-src 'self' https://www.google.com/recaptcha/ https://www.gstatic.com/recaptcha/ https://cdnjs.cloudflare.com 'unsafe-inline' 'unsafe-eval'; \
frame-src https://www.google.com/recaptcha/ https://www.gstatic.com/recaptcha/; \
connect-src 'self'; \
img-src 'self' data: https://secure.gravatar.com; \
frame-ancestors 'self'"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set X-Content-Type-Options "nosniff"
    Header always set Referrer-Policy "strict-origin"
    Header always set Permissions-Policy "geolocation=(), midi=(), sync-xhr=(), microphone=(), camera=(), magnetometer=(), gyroscope=(), fullscreen=(self), payment=()"
    Header edit Set-Cookie ^(.*)$ "$1; HttpOnly; Secure"
    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"

    SSLEngine on
    SSLCertificateFile $certfile
    SSLCertificateKeyFile $keyfile
    SSLCertificateChainFile $cacertfile

    ProxyPreserveHost On
    SSLProxyEngine On

    ProxyPass /fc/ http://localhost:6001/fc/ retry=0
    ProxyPassReverse /fc/ http://localhost:6001/fc/

    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteCond %{HTTP:Connection} upgrade [NC]
    RewriteRule ^/fc/(.*) ws://localhost:6001/fc/\$1 [P,L]

    ProxyPass "/natsws" "ws://127.0.0.1:9235/"
    ProxyPassReverse "/natsws" "ws://127.0.0.1:9235/"
    Header always set Upgrade "websocket"
    Header always set Connection "Upgrade"
    Header always set X-Forwarded-Host %{HTTP_HOST}e
    Header always set X-Forwarded-For %{REMOTE_ADDR}e
    Header always set X-Forwarded-Proto %{HTTPS}e
</VirtualHost>
EOF
    else
cat <<EOF > /etc/httpd/conf.d/faveo-ssl.conf
<VirtualHost *:443>
    ServerName $DomainName
    DocumentRoot /var/www/faveo/public
    <Directory /var/www/faveo>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/httpd/faveo-ssl-error.log
    CustomLog /var/log/httpd/faveo-ssl-access.log combined

    Header always unset X-Frame-Options
    Header always set Content-Security-Policy "default-src 'self'; \
style-src 'self' https://fonts.googleapis.com 'unsafe-inline'; \
font-src 'self' https://fonts.gstatic.com data:; \
script-src 'self' https://www.google.com/recaptcha/ https://www.gstatic.com/recaptcha/ https://cdnjs.cloudflare.com 'unsafe-inline' 'unsafe-eval'; \
frame-src https://www.google.com/recaptcha/ https://www.gstatic.com/recaptcha/; \
connect-src 'self'; \
img-src 'self' data: https://secure.gravatar.com; \
frame-ancestors 'self'"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set X-Content-Type-Options "nosniff"
    Header always set Referrer-Policy "strict-origin"
    Header always set Permissions-Policy "geolocation=(), midi=(), sync-xhr=(), microphone=(), camera=(), magnetometer=(), gyroscope=(), fullscreen=(self), payment=()"
    Header edit Set-Cookie ^(.*)$ "$1; HttpOnly; Secure"
    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"

    SSLEngine on
    SSLCertificateFile $certfile
    SSLCertificateKeyFile $keyfile
    SSLCertificateChainFile $cacertfile

    ProxyPreserveHost On
    SSLProxyEngine On

    ProxyPass /fc/ http://localhost:6001/fc/ retry=0
    ProxyPassReverse /fc/ http://localhost:6001/fc/

    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteCond %{HTTP:Connection} upgrade [NC]
    RewriteRule ^/fc/(.*) ws://localhost:6001/fc/\$1 [P,L]
</VirtualHost>
EOF
    fi

    cp "$cacertfile" /etc/pki/ca-trust/source/anchors/
    update-ca-trust extract

    systemctl restart php-fpm httpd

    local test
    test=$(curl -ks https://"$DomainName"/test.html)
    if [[ "$test" == "Test" ]]; then
        echo -e "$green Paid SSL successfully configured for $DomainName. $reset"
        sleep 1
        sql_installation "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value"
    else
        echo -e "$red Paid SSL configuration failed for $DomainName. $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
    fi
}

# Paid SSL Nginx Installation
paid_ssl_nginx() {
    echo -e "$yellow Configuring Paid SSL for $DomainName... $reset"

    FAVEO_WEBROOT="/var/www/faveo/public"

    if [[ "$Nats_option_value" =~ ^(y|yes)$ ]]; then
        cat <<EOF > /etc/nginx/conf.d/faveo-ssl.conf
server {
    listen 80;
    listen [::]:80;
    server_name $DomainName;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    root $FAVEO_WEBROOT;
    index index.php index.html index.htm;
    server_name $DomainName;

    client_max_body_size 100M;

    ssl_certificate $certfile;
    ssl_certificate_key $keyfile;
    ssl_trusted_certificate $cacertfile;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        try_files \$uri =404;
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    # NATS Proxy
    location ~ ^/natsws {
        proxy_pass http://127.0.0.1:9235;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-Host \$host:\$server_port;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
    else
        cat <<EOF > /etc/nginx/conf.d/faveo-ssl.conf
server {
    listen 80;
    listen [::]:80;
    server_name $DomainName;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    root $FAVEO_WEBROOT;
    index index.php index.html index.htm;
    server_name $DomainName;

    client_max_body_size 100M;

    ssl_certificate $certfile;
    ssl_certificate_key $keyfile;
    ssl_trusted_certificate $cacertfile;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        try_files \$uri =404;
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF
    fi

    cp "$cacertfile" /etc/pki/ca-trust/source/anchors/
    update-ca-trust extract

    systemctl restart php-fpm
    systemctl restart nginx

    local test
    test=$(curl -ks https://"$DomainName"/test.html)
    if [[ "$test" == "Test" ]]; then
        echo -e "$green Paid SSL successfully configured for $DomainName. $reset"
        sleep 1
        sql_installation "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value"
    else
        echo -e "$red Paid SSL configuration failed for $DomainName. $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
    fi
}

# Webserver Installation:
web_server_configuration() {
    local FAVEO_WEBROOT="/var/www/faveo/public"

    mkdir -p "$FAVEO_WEBROOT"
    echo "Test" > "$FAVEO_WEBROOT/test.html"
    echo "127.0.0.1      $DomainName" >> /etc/hosts

    # SELinux: switch to permissive so Faveo's proxying/writes are not blocked.
    if command -v getenforce >/dev/null 2>&1 && [[ "$(getenforce)" != "Disabled" ]]; then
        echo -e "$yellow Setting SELinux to permissive mode for Faveo compatibility... $reset"
        setenforce 0 2>/dev/null
        sed -i 's/^SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config 2>/dev/null
    fi

    # Firewalld: open HTTP/HTTPS
    if systemctl is-active --quiet firewalld 2>/dev/null; then
        firewall-cmd --permanent --add-service=http  >/dev/null 2>&1
        firewall-cmd --permanent --add-service=https >/dev/null 2>&1
        firewall-cmd --reload >/dev/null 2>&1
    fi

    verify_web_server() {
        local test_result
        test_result=$(curl -s "http://$DomainName/test.html")
        if [[ "$test_result" != "Test" ]]; then
            echo -e "$red Something went wrong. Check your Internet/Firewall/Domain propagation.$reset"
            echo -e "$red Rolling back... $reset"
            rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
            exit 1
        else
            echo -e "$green Web server configured successfully..$reset"
            sleep 1
        fi
    }

    if [[ "$Webserver_option_value" == "apache" ]]; then
        echo -e "$yellow Installing Apache... $reset"

        dnf install -y httpd httpd-tools

        systemctl enable httpd
        mkdir -p "$FAVEO_WEBROOT"
        if [[ "$Nats_option_value" =~ ^(y|yes)$ ]]; then
            cat <<EOF > /etc/httpd/conf.d/faveo.conf
<VirtualHost *:80>
    ServerName $DomainName
    DocumentRoot $FAVEO_WEBROOT
    <Directory /var/www/faveo>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/httpd/faveo-error.log
    CustomLog /var/log/httpd/faveo-access.log combined

    # NATS Proxy
    ProxyPass "/natsws" "ws://127.0.0.1:9235/"
    ProxyPassReverse "/natsws" "ws://127.0.0.1:9235/"
    Header always set Upgrade "websocket"
    Header always set Connection "Upgrade"
    Header always set X-Forwarded-Host %{HTTP_HOST}e
    Header always set X-Forwarded-For %{REMOTE_ADDR}e
    Header always set X-Forwarded-Proto %{HTTPS}e
</VirtualHost>
EOF
        else
            cat <<EOF > /etc/httpd/conf.d/faveo.conf
<VirtualHost *:80>
    ServerName $DomainName
    DocumentRoot $FAVEO_WEBROOT
    <Directory /var/www/faveo>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/httpd/faveo-error.log
    CustomLog /var/log/httpd/faveo-access.log combined
</VirtualHost>
EOF
        fi

        systemctl restart httpd
        verify_web_server

        case "$Ssl_option_value" in
            certbot) certbot_apache "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" ;;
            self-signed) self_signed_apache "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" ;;
            paid-ssl) paid_ssl_apache "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$certfile" "$keyfile" "$cacertfile" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" ;;
            *) echo -e "$red SSL configuration error.$reset"; exit 1 ;;
        esac

    elif [[ "$Webserver_option_value" == "nginx" ]]; then
        echo -e "$yellow Installing Nginx... $reset"
        systemctl stop httpd > /dev/null 2>&1
        systemctl disable httpd > /dev/null 2>&1
        dnf remove -y httpd > /dev/null 2>&1

        dnf install -y nginx

        systemctl enable nginx
        if [[ "$Nats_option_value" =~ ^(y|yes)$ ]]; then
            cat <<EOF > /etc/nginx/conf.d/faveo.conf
server {
    listen 80;
    root $FAVEO_WEBROOT;
    index index.php index.html index.htm;
    server_name $DomainName;
    client_max_body_size 100M;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        try_files \$uri =404;
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    # NATS Proxy
    location ~ ^/natsws {
        proxy_pass http://127.0.0.1:9235;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-Host \$host:\$server_port;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
        else
            cat <<EOF > /etc/nginx/conf.d/faveo.conf
server {
    listen 80;
    root $FAVEO_WEBROOT;
    index index.php index.html index.htm;
    server_name $DomainName;
    client_max_body_size 100M;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        try_files \$uri =404;
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF
        fi

        systemctl restart nginx
        verify_web_server

        case "$Ssl_option_value" in
            certbot) certbot_nginx "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" ;;
            self-signed) self_signed_nginx "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" ;;
            paid-ssl) paid_ssl_nginx "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$certfile" "$keyfile" "$Php_option_value" "$cacertfile" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" ;;
            *) echo -e "$red SSL configuration error.$reset"; exit 1 ;;
        esac
    else
        echo -e "$red Invalid webserver selection.$reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
        exit 1
    fi
}

dependencies() {
    local WEBUSER
    WEBUSER=$(webuser)

    echo -e "$yellow Installing PHP and necessary extensions... $reset"

    OS_VER=$(grep '^VERSION_ID=' /etc/os-release | cut -d '=' -f2 | tr -d '"')
    OS_MAJOR=${OS_VER%%.*}

    # EPEL + Remi repositories (provide modern PHP versions for RHEL family)
    dnf install -y "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${OS_MAJOR}.noarch.rpm" 2>/dev/null
    if [[ "$OS_MAJOR" == "8" ]]; then
        dnf install -y "https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-8.noarch.rpm" 2>/dev/null
    fi
    dnf install -y dnf-utils "http://rpms.remirepo.net/enterprise/remi-release-${OS_MAJOR}.rpm" || {
        echo -e "$red Failed to add Remi repository for PHP. Rolling back... $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
        return
    }

    # CRB (CodeReady Builder / powertools on EL8) is required by Remi for PHP extension deps.
    # crb command is provided by dnf-utils and works across EL8, EL9, and EL10.
    crb enable 2>/dev/null || dnf config-manager --set-enabled powertools 2>/dev/null || \
        dnf config-manager --set-enabled crb 2>/dev/null || true

    dnf module reset php -y 2>/dev/null
    dnf module enable -y "php:remi-${Php_option_value}" || {
        echo -e "$red PHP $Php_option_value is not available via Remi on this OS. Rolling back... $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
        return
    }

    PHP_PACKAGES=(php php-cli php-common php-fpm php-gd php-mbstring php-mysqlnd php-odbc php-pdo php-xml \
        php-opcache php-imap php-bcmath php-ldap php-pecl-zip php-soap php-redis php-process php-posix \
        php-intl php-gmp php-curl php-pecl-memcached)

    dnf install -y "${PHP_PACKAGES[@]}" || { echo -e "$red PHP installation failed. $reset"; rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"; return; }

    # Configure PHP settings
    if [[ -f /etc/php.ini ]]; then
        sed -i 's/file_uploads =.*/file_uploads = On/' /etc/php.ini
        sed -i 's/allow_url_fopen =.*/allow_url_fopen = On/' /etc/php.ini
        sed -i 's/short_open_tag =.*/short_open_tag = On/' /etc/php.ini
        sed -i 's/memory_limit =.*/memory_limit = 256M/' /etc/php.ini
        sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo = 0/' /etc/php.ini
        sed -i 's/upload_max_filesize =.*/upload_max_filesize = 100M/' /etc/php.ini
        sed -i 's/post_max_size =.*/post_max_size = 100M/' /etc/php.ini
        sed -i 's/max_execution_time =.*/max_execution_time = 360/' /etc/php.ini
    fi

    # PHP-FPM pool: run as the webserver's system user/group, listen on a unix socket
    if [[ -f /etc/php-fpm.d/www.conf ]]; then
        sed -i "s/^user = .*/user = $WEBUSER/"  /etc/php-fpm.d/www.conf
        sed -i "s/^group = .*/group = $WEBUSER/" /etc/php-fpm.d/www.conf
        sed -i "s/^listen.owner = .*/listen.owner = $WEBUSER/" /etc/php-fpm.d/www.conf
        sed -i "s/^listen.group = .*/listen.group = $WEBUSER/" /etc/php-fpm.d/www.conf
        sed -i "s|^listen = .*|listen = /run/php-fpm/www.sock|" /etc/php-fpm.d/www.conf
    fi

    systemctl enable php-fpm
    systemctl restart php-fpm
    if [[ $? -ne 0 ]]; then
        echo -e "$red Something went wrong configuring PHP. Rolling back... $reset"
        rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
        return 1
    fi

    echo -e "$green PHP configured successfully. $reset"
    sleep 1

    web_server_configuration "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$MySQL_PASS"
}

# Nats Installation:
nats_install() {
    local nats_choice="${Nats_option_value,,}"
    local WEBUSER
    WEBUSER=$(webuser)

    if [[ "$nats_choice" =~ ^(y|yes)$ ]]; then
        echo -e "$yellow Installing Network Discovery dependencies... $reset"
        sleep 0.05

        curl -L https://github.com/nats-io/nats-server/releases/download/v2.10.24/nats-server-v2.10.24-linux-amd64.zip -o nats-server.zip || { echo -e "$red Failed to download NATS server.$reset"; rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"; exit 1; }
        unzip -o nats-server.zip -d nats-server || { echo -e "$red Failed to unzip NATS server.$reset"; rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"; exit 1; }
        mkdir -p /usr/local/bin && cp nats-server/nats-server-v2.10.24-linux-amd64/nats-server /usr/local/bin/ || { echo -e "$red Failed to copy NATS server binary.$reset"; rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"; exit 1; }
        rm -rf nats-server nats-server.zip

        cat <<EOF > /etc/systemd/system/nats.service
[Unit]
Description=NATS Server
After=network.target

[Service]
PrivateTmp=true
Type=simple
ExecStart=/usr/local/bin/nats-server -c /var/www/faveo/nats.conf
ExecReload=/usr/bin/kill -s HUP \$MAINPID
ExecStop=/usr/bin/kill -s SIGINT \$MAINPID
User=$WEBUSER
Group=$WEBUSER
Restart=always
RestartSec=5s
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

        mkdir -p /var/www/faveo
        touch /var/www/faveo/nats.conf
        systemctl daemon-reload
        systemctl enable nats
        systemctl is-active --quiet nats || {
        echo -e "$yellow NATS not running. Attempting to start... $reset"
        systemctl start nats > /dev/null 2>&1 || {
            echo -e "$red Failed to start NATS service.$reset"
            rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
            exit 1
            }
        }
        echo -e "$green NATS server installed successfully. $reset"
        sleep 1

        # Open NATS websocket port on firewalld
        if systemctl is-active --quiet firewalld 2>/dev/null; then
            firewall-cmd --permanent --add-port=9235/tcp >/dev/null 2>&1
            firewall-cmd --reload >/dev/null 2>&1
        fi

    else
        echo -e "$yellow Network Discovery dependencies will not be installed. $reset"
    fi

    dependencies "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" \
                             "$Sql_option_value" "$Webserver_option_value" "$Ssl_option_value" \
                             "$Nats_option_value" "$Php_option_value" "$Node_option_value" "$Meili_option_value" \
                             "$certfile" "$keyfile" "$cacertfile"
}

# Node installation:
node_installation() {
    local node_choice="${Node_option_value,,}"

    if [[ "$node_choice" =~ ^(y|yes)$ ]]; then
        echo -e "$yellow Continuing with the Installation $reset"
        echo -e "$yellow Installing and configuring Node.js 22.x... $reset"
        sleep 0.05

        dnf install -y git curl wget zip unzip

        curl -fsSL https://rpm.nodesource.com/setup_22.x | bash - || { echo -e "$red Failed to setup Node.js repo.$reset"; rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"; exit 1; }
        dnf install -y nodejs || { echo -e "$red Failed to install Node.js.$reset"; rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"; exit 1; }

        npm install --location=global --unsafe-perm puppeteer@^24.33.0 || { echo -e "$red Failed to install Puppeteer.$reset"; rollback "$Sql_option_value" "$Php_option_value" "$Meili_option_value" "$Webserver_option_value" "$Node_option_value" "$Nats_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"; exit 1; }

        echo -e "$green Node.js 22.x and Puppeteer installed successfully. $reset"
        sleep 1

    else
        echo -e "$yellow Continuing with the Installation $reset"
        echo -e "$yellow Node.js will not be installed. $reset"
        dnf install -y git curl wget zip unzip
    fi

    nats_install "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" \
                 "$Webserver_option_value" "$Sql_option_value" "$Ssl_option_value" \
                 "$Nats_option_value" "$Php_option_value" "$Node_option_value" "$Meili_option_value" \
                 "$certfile" "$keyfile" "$cacertfile"
}

# SSL Selection Prompt:
ssl_selection() {
    local retries=0
    local max_retries=2
    local ssl_choice=""

    Ssl_option_value=""

    while true; do
        echo -e "                                       "
        echo -e "$cyan Select your preferred SSL certificates for Faveo Helpdesk.$reset"
        sleep 0.05
        echo -e "$green (1) - FreeSSL from Letsencrypt $reset"
        echo -e "$green (2) - Self-Signed SSL $reset"
        echo -e "$green (3) - Paid SSL $reset"
        read -p "$(echo -e "$yellow Please select an option [1,2,3]: $reset")" ssl_choice

        case "${ssl_choice,,}" in
            1)
                Ssl_option_value="certbot"
                echo -e "$green You have selected Lets Encrypt Free SSL $reset"
                break
                ;;
            2)
                Ssl_option_value="self-signed"
                echo -e "$green You have selected Self-Signed SSL $reset"
                break
                ;;
            3)
                Ssl_option_value="paid-ssl"
                echo -e "$green You have selected Paid SSL $reset"

                ssl_files() {
                    local DIR_NAME="/etc/httpd/ssl"
                    mkdir -p "$DIR_NAME"

                    echo -e "$yellow Certificate files will be stored in '$DIR_NAME' (used for both Apache and Nginx). $reset"

                    # Validates PEM content/files with openssl before accepting them.
                    _validate_pem_file() {
                        local file="$1"
                        local kind="$2" # cert|key
                        if [[ "$kind" == "key" ]]; then
                            openssl pkey -noout -in "$file" &>/dev/null
                        else
                            openssl x509 -noout -in "$file" &>/dev/null
                        fi
                    }

                    collect_cert_material() {
                        local file_desc="$1"
                        local dest_file="$2"
                        local out_var="$3"
                        local kind="$4"   # cert|key
                        local retries=0
                        local max_retries=2
                        local mode_choice=""

                        while true; do
                            echo -e "$cyan $file_desc $reset"
                            echo -e "$green (1) - Enter a file path already on this server $reset"
                            echo -e "$green (2) - Paste the content directly $reset"
                            read -p "$(echo -e "$yellow Choose an option [1/2]: $reset")" mode_choice

                            case "$mode_choice" in
                                1)
                                    local source_path=""
                                    local path_retries=0
                                    while true; do
                                        read -p "$(echo -e "$yellow Enter the path of the $file_desc file: $reset")" source_path
                                        if [[ -f "$source_path" ]] && _validate_pem_file "$source_path" "$kind"; then
                                            cp "$source_path" "$dest_file"
                                            chmod 600 "$dest_file"
                                            printf -v "$out_var" '%s' "$dest_file"
                                            echo "Copied '$source_path' to '$dest_file'."
                                            return 0
                                        fi
                                        path_retries=$((path_retries + 1))
                                        echo -e "\e[31mError: '$source_path' does not exist or is not a valid PEM $kind. ($path_retries/$max_retries)\e[0m"
                                        if [ $path_retries -ge $max_retries ]; then
                                            echo -e "\e[31mToo many invalid attempts. Please rerun the script.\e[0m"
                                            exit 1
                                        fi
                                    done
                                    ;;
                                2)
                                    echo -e "$yellow Paste the $file_desc content, then press Ctrl+D on a new line when done: $reset"
                                    local pasted_content
                                    pasted_content=$(cat)
                                    if [[ -z "$pasted_content" ]]; then
                                        echo -e "$red No content received. $reset"
                                    else
                                        printf '%s\n' "$pasted_content" > "$dest_file"
                                        chmod 600 "$dest_file"
                                        if _validate_pem_file "$dest_file" "$kind"; then
                                            printf -v "$out_var" '%s' "$dest_file"
                                            echo -e "$green Saved and validated $file_desc at '$dest_file'. $reset"
                                            return 0
                                        fi
                                        echo -e "$red Pasted content is not a valid PEM $kind. $reset"
                                        rm -f "$dest_file"
                                    fi
                                    ;;
                                *)
                                    echo -e "$red Invalid option. Please select 1 or 2. $reset"
                                    ;;
                            esac

                            retries=$((retries+1))
                            if [ $retries -ge $max_retries ]; then
                                echo -e "\e[31mToo many invalid attempts. Please rerun the script.\e[0m"
                                exit 1
                            fi
                        done
                    }

                    collect_cert_material "certificate.crt" "$DIR_NAME/faveolocal.crt" "certfile" "cert"
                    collect_cert_material "private.key" "$DIR_NAME/private.key" "keyfile" "key"
                    collect_cert_material "ca_bundle.crt" "$DIR_NAME/faveorootCA.crt" "cacertfile" "cert"

                    echo -e "$yellow Continuing with the Installation $reset"

                }

                ssl_files
                break
                ;;
            *)
                retries=$((retries+1))
                echo -e "$red Invalid option. Please select 1, 2, or 3. ($retries/$max_retries)$reset"
                if [ $retries -ge $max_retries ]; then
                    echo -e "$red Too many invalid attempts. Please rerun the script.$reset"
                    exit 1
                fi
                ;;
        esac
        break
    done
}

# Web Server Selection:
web_server_selection() {
    local retries=0
    local max_retries=2
    local webserver_choice=""

    Webserver_option_value=""
    while true; do
        sleep 0.05
        echo -e "                                       "
        echo -e "$cyan Select your preferred web server [Apache or Nginx].$reset"
        echo -e "$green (1) - Apache (Default) $reset"
        sleep 0.05
        echo -e "$green (2) - Nginx $reset"
        echo -e "                                 "

        read -p "$(echo -e "$yellow Enter 1 for Apache or 2 for Nginx: $reset")" webserver_choice
        case "$webserver_choice" in
            1|"")
                Webserver_option_value="apache"
                ;;
            2)
                Webserver_option_value="nginx"
                ;;
            *)
                retries=$((retries + 1))
                echo -e "$red Invalid input. Please enter 1 or 2. ($retries/$max_retries)$reset"
                if [ $retries -ge $max_retries ]; then
                    echo -e "$red Too many invalid attempts. Please re-run the script.$reset"
                    exit 1
                fi
                continue
                ;;
        esac

        echo -e "$green You selected: $Webserver_option_value Webserver $reset"
        break
    done
}

# SQL Selection:
sql_server_selection() {
    local retries=0
    local max_retries=2
    local Sql_option_choice=""

    # Engine choice (mysql/mariadb) - skip if already supplied via --sql.
    if [[ -z "$Sql_option_value" ]]; then
        while true; do
            sleep 0.05
            echo -e "                                       "
            echo -e "$cyan Select your preferred SQL server [MySQL or MariaDB].$reset"
            echo -e "$yellow Supported versions: MySQL 8.0/8.4 and MariaDB 10.6/11.8 only.$reset"
            echo -e "$yellow If your chosen engine has no supported version for this OS/release,$reset"
            echo -e "$yellow the script will automatically try the other engine instead.$reset"

            echo -e "$green (1) - MySQL (default) $reset"
            sleep 0.05
            echo -e "$green (2) - MariaDB $reset"
            echo -e "                                 "
            read -p "$(echo -e "$yellow Enter 1 for MySQL or 2 for MariaDB [default: 1]: $reset")" Sql_option_choice

            case "$Sql_option_choice" in
                1|"")
                    Sql_option_value="mysql"
                    ;;
                2)
                    Sql_option_value="mariadb"
                    ;;
                *)
                    retries=$((retries + 1))
                    echo -e "$red Invalid choice. Please enter 1 or 2. ($retries/$max_retries)$reset"
                    if [ $retries -ge $max_retries ]; then
                        echo -e "$red Too many invalid attempts. Please re-run the script.$reset"
                        exit 1
                    fi
                    continue
                    ;;
            esac

            echo -e "$green You selected: $Sql_option_value $reset"
            break
        done
    fi

    # SQL server location: install locally, or use an existing remote server.
    Remote_Sql_option_value="no"
    if [[ -n "$MySQL_LOCATION" ]]; then
        Remote_Sql_option_value="$MySQL_LOCATION"
        if [[ "$Remote_Sql_option_value" == "yes" ]]; then
            echo -e "$green Remote SQL server selected. $reset"
        else
            echo -e "$green Local SQL server installation selected. $reset"
        fi
    elif [[ -n "$MySQL_HOST" ]]; then
        Remote_Sql_option_value="yes"
        echo -e "$green Remote SQL host supplied via --sqlhost ($MySQL_HOST) - will connect to it instead of installing $Sql_option_value locally. $reset"
    else
        local loc_retries=0
        local loc_choice=""
        while true; do
            echo -e "                                       "
            echo -e "$cyan Where should the SQL server be? $reset"
            echo -e "$green (1) - Install $Sql_option_value locally on this server (default) $reset"
            echo -e "$green (2) - Use an existing remote SQL server $reset"
            read -p "$(echo -e "$yellow Enter 1 for local or 2 for remote [default: 1]: $reset")" loc_choice

            case "$loc_choice" in
                1|"")
                    Remote_Sql_option_value="no"
                    break
                    ;;
                2)
                    Remote_Sql_option_value="yes"
                    break
                    ;;
                *)
                    loc_retries=$((loc_retries + 1))
                    echo -e "$red Invalid choice. Please enter 1 or 2. ($loc_retries/$max_retries)$reset"
                    if [ $loc_retries -ge $max_retries ]; then
                        echo -e "$red Too many invalid attempts. Please re-run the script.$reset"
                        exit 1
                    fi
                    ;;
            esac
        done
    fi

    [[ "$Remote_Sql_option_value" == "no" ]] && return

    # --- Remote server details ---
    local host_re="^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])(\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]))*$"
    local ipv4_re="^((25[0-5]|(2[0-4]|1[0-9]|[1-9])?[0-9])\.){3}(25[0-5]|(2[0-4]|1[0-9]|[1-9])?[0-9])$"

    if [[ -z "$MySQL_HOST" ]]; then
        local h_retries=0
        while true; do
            read -p "$(echo -e "$yellow Remote SQL server hostname (DNS name) or IPv4 address: $reset")" MySQL_HOST
            [[ "$MySQL_HOST" =~ $host_re || "$MySQL_HOST" =~ $ipv4_re ]] && break
            h_retries=$((h_retries + 1))
            echo -e "$red Invalid hostname/IP. Try again. ($h_retries/$max_retries)$reset"
            [[ $h_retries -ge $max_retries ]] && { echo -e "$red Too many failed attempts. Exiting.$reset"; exit 1; }
        done
    fi

    if [[ -z "$MySQL_PORT" ]]; then
        local p_retries=0
        while true; do
            read -p "$(echo -e "$yellow Remote SQL server port [default: 3306]: $reset")" MySQL_PORT
            MySQL_PORT="${MySQL_PORT:-3306}"
            [[ "$MySQL_PORT" =~ ^[0-9]+$ && "$MySQL_PORT" -ge 1 && "$MySQL_PORT" -le 65535 ]] && break
            p_retries=$((p_retries + 1))
            echo -e "$red Invalid port. Must be 1-65535. ($p_retries/$max_retries)$reset"
            MySQL_PORT=""
            [[ $p_retries -ge $max_retries ]] && { echo -e "$red Too many failed attempts. Exiting.$reset"; exit 1; }
        done
    fi

    if [[ -z "$MySQL_USERNAME" ]]; then
        local u_retries=0
        while true; do
            read -p "$(echo -e "$yellow Remote SQL username: $reset")" MySQL_USERNAME
            [[ -n "$MySQL_USERNAME" ]] && break
            u_retries=$((u_retries + 1))
            echo -e "$red Username cannot be empty. ($u_retries/$max_retries)$reset"
            [[ $u_retries -ge $max_retries ]] && { echo -e "$red Too many failed attempts. Exiting.$reset"; exit 1; }
        done
    fi

    if [[ -z "$MySQL_PASSWORD" ]]; then
        read -s -p "$(echo -e "$yellow Remote SQL password: $reset")" MySQL_PASSWORD
        echo ""
    fi

    if [[ -z "$MySQL_SEC" ]]; then
        local s_retries=0
        local s_choice=""
        while true; do
            read -p "$(echo -e "$yellow Use an SSL/TLS secured connection to the remote SQL server? (y/yes or n/no) [default: n]: $reset")" s_choice
            case "${s_choice,,}" in
                y|yes) MySQL_SEC="yes"; break ;;
                n|no|"") MySQL_SEC="no"; break ;;
                *)
                    s_retries=$((s_retries + 1))
                    echo -e "$red Invalid input. ($s_retries/$max_retries)$reset"
                    [[ $s_retries -ge $max_retries ]] && { echo -e "$red Too many failed attempts. Exiting.$reset"; exit 1; }
                    ;;
            esac
        done
    fi

    if [[ "$MySQL_SEC" == "yes" ]]; then
        mkdir -p /etc/my.cnf.d

        # Validates PEM content/files with openssl before accepting them.
        _validate_pem_file() {
            local file="$1"
            local kind="$2" # cert|key
            if [[ "$kind" == "key" ]]; then
                openssl pkey -noout -in "$file" &>/dev/null
            else
                openssl x509 -noout -in "$file" &>/dev/null
            fi
        }

        # Accepts either an existing file path or pasted PEM content for a
        # remote MySQL SSL credential, validating it with openssl.
        _collect_mysql_ssl_material() {
            local label="$1"          # human label
            local dest_file="$2"      # e.g. /etc/my.cnf.d/faveo-mysql-ca.pem
            local out_var="$3"        # variable name to set with final path
            local kind="$4"           # cert|key
            local required="$5"       # yes|no

            local existing_val="${!out_var}"
            if [[ -n "$existing_val" && -f "$existing_val" ]]; then
                if _validate_pem_file "$existing_val" "$kind"; then
                    return 0
                fi
                echo -e "$red The path already supplied for $label does not look like a valid PEM $kind. $reset"
            fi

            local mode_choice=""
            local retries_local=0
            while true; do
                echo -e "$cyan $label $reset"
                echo -e "$green (1) - Enter a file path already on this server $reset"
                echo -e "$green (2) - Paste the content directly $reset"
                [[ "$required" == "no" ]] && echo -e "$green (3) - Skip $reset"
                read -p "$(echo -e "$yellow Choose an option: $reset")" mode_choice

                case "$mode_choice" in
                    1)
                        local src_path=""
                        local path_retries=0
                        while true; do
                            read -p "$(echo -e "$yellow Enter the path of the $label: $reset")" src_path
                            if [[ -f "$src_path" ]] && _validate_pem_file "$src_path" "$kind"; then
                                printf -v "$out_var" '%s' "$src_path"
                                return 0
                            fi
                            path_retries=$((path_retries + 1))
                            echo -e "$red File not found or not a valid PEM $kind. ($path_retries/$max_retries)$reset"
                            [[ $path_retries -ge $max_retries ]] && { echo -e "$red Too many invalid attempts. Please rerun the script.$reset"; exit 1; }
                        done
                        ;;
                    2)
                        echo -e "$yellow Paste the $label content, then press Ctrl+D on a new line when done: $reset"
                        local pasted_content
                        pasted_content=$(cat)
                        if [[ -z "$pasted_content" ]]; then
                            echo -e "$red No content received. $reset"
                        else
                            printf '%s\n' "$pasted_content" > "$dest_file"
                            chmod 600 "$dest_file"
                            if _validate_pem_file "$dest_file" "$kind"; then
                                printf -v "$out_var" '%s' "$dest_file"
                                echo -e "$green Saved and validated $label at '$dest_file'. $reset"
                                return 0
                            fi
                            echo -e "$red Pasted content is not a valid PEM $kind. $reset"
                            rm -f "$dest_file"
                        fi
                        ;;
                    3)
                        if [[ "$required" == "no" ]]; then
                            printf -v "$out_var" '%s' ""
                            return 0
                        fi
                        echo -e "$red This item is required and cannot be skipped. $reset"
                        ;;
                    *)
                        echo -e "$red Invalid option. $reset"
                        ;;
                esac

                retries_local=$((retries_local + 1))
                [[ $retries_local -ge $max_retries ]] && { echo -e "$red Too many invalid attempts. Please re-run the script.$reset"; exit 1; }
            done
        }

        _collect_mysql_ssl_material "MySQL SSL CA certificate (required)" "/etc/my.cnf.d/faveo-mysql-ca.pem" "MySQL_SSLCA" "cert" "yes"
        _collect_mysql_ssl_material "MySQL SSL client certificate (optional)" "/etc/my.cnf.d/faveo-mysql-cert.pem" "MySQL_SSLCERT" "cert" "no"
        _collect_mysql_ssl_material "MySQL SSL client key (optional)" "/etc/my.cnf.d/faveo-mysql-key.pem" "MySQL_SSLKEY" "key" "no"

        if [[ -z "$MySQL_SSLVERIFY" ]]; then
            local v_choice=""
            local v_retries=0
            while true; do
                read -p "$(echo -e "$yellow Verify the remote server's SSL certificate identity? (y/yes or n/no) [default: y]: $reset")" v_choice
                case "${v_choice,,}" in
                    y|yes|"") MySQL_SSLVERIFY="yes"; break ;;
                    n|no) MySQL_SSLVERIFY="no"; break ;;
                    *)
                        v_retries=$((v_retries + 1))
                        echo -e "$red Invalid input. ($v_retries/$max_retries)$reset"
                        [[ $v_retries -ge $max_retries ]] && { echo -e "$red Too many failed attempts. Exiting.$reset"; exit 1; }
                        ;;
                esac
            done
        fi
    fi

    echo -e "$green Remote SQL server configured: $MySQL_HOST:$MySQL_PORT (user: $MySQL_USERNAME, secure: $MySQL_SEC) $reset"
}

# Node option:
node_option() {
    local retries=0
    local max_retries=2
    local Node_option_choice=""

    Node_option_value=""

    while true; do
        sleep 0.05
        echo -e ""
        echo -e "$cyan Faveo supports Graphical Reports for Assets. This feature uses higher server resources.$reset"
        echo -e "$yellow Currently, Faveo supports Node.js 22.x.$reset"
        echo -e "$yellow If the server specs are >= 4 vCPU and 8 GB RAM, you may install it. Default is (Yes).$reset"
        read -p "$(echo -e "$yellow Enter (y/yes) to install or (n/no) to skip [default : y]: $reset")" Node_option_choice

        case "${Node_option_choice,,}" in
            y|yes|"")
                Node_option_value="yes"
                ;;
            n|no)
                Node_option_value="no"
                ;;
            *)
                retries=$((retries + 1))
                echo -e "$red Invalid input. Please enter y/yes or n/no. ($retries/$max_retries)$reset"
                if [ $retries -ge $max_retries ]; then
                    echo -e "$red Too many invalid attempts. Please re-run the script.$reset"
                    exit 1
                fi
                continue
                ;;
        esac

        echo -e "$green You selected: $Node_option_value $reset"
        break
    done
}

# PHP Selection:
php_selection() {
    local retries=0
    local max_retries=2
    local Php_option_choice=""

    Php_option_value=""

    while true; do
        sleep 0.05
        echo -e ""
        echo -e "$cyan Faveo currently supports PHP 8.4.$reset"
        echo -e "$cyan You may choose your preferred PHP version (e.g., 8.2, 8.4, x.x) available via the Remi repository. Default is 8.4.$reset"
        read -p "$(echo -e "$yellow Enter PHP version [default: 8.4]: $reset")" Php_option_choice

        if [[ -z "$Php_option_choice" ]]; then
            Php_option_choice="8.4"
        fi

        if [[ "$Php_option_choice" =~ ^([8-9]|[1-9][0-9])\.[0-9]+$ ]]; then
            Php_option_value="$Php_option_choice"
            echo -e "$green You have selected PHP version $Php_option_value $reset"
            break
        else
            retries=$((retries + 1))
            echo -e "$red Invalid PHP version. Please enter a version 8.2 or above. ($retries/$max_retries)$reset"
            if [ $retries -ge $max_retries ]; then
                echo -e "$red Too many invalid attempts. Please re-run the script.$reset"
                exit 1
            fi
        fi
    done
}

# Nats Selection
nats_installation() {
    local retries=0
    local max_retries=2
    local Nats_option_choice=""

    Nats_option_value=""

    while true; do
        echo -e ""
        echo -e "$cyan If you wish to use Agent Software with Faveo, select Yes or No. Default is No.$reset"
        sleep 0.05
        read -p "$(echo -e "$yellow Enter (y/yes) to install or (n/no) to skip Network Discovery dependencies [default: n]: $reset")" Nats_option_choice

        case "${Nats_option_choice,,}" in
            y|yes)
                Nats_option_value="yes"
                ;;
            n|no|"")
                Nats_option_value="no"
                ;;
            *)
                retries=$((retries + 1))
                echo -e "$red Invalid input. Please enter y/yes or n/no. ($retries/$max_retries)$reset"
                if [ $retries -ge $max_retries ]; then
                    echo -e "$red Too many invalid attempts. Please re-run the script.$reset"
                    exit 1
                fi
                continue
                ;;
        esac

        echo -e "$green You selected: $Nats_option_value $reset"
        break
    done
}

# Meilisearch Option:
meili_option() {
    local retries=0
    local max_retries=2
    local Meili_option_choice=""

    Meili_option_value=""

    while true; do
        echo -e ""
        echo -e "$cyan Faveo has a search module for high data size (example: above 100 tickets per day), Please select 'Yes' if the expected data size is high enough. [Default : Y].$reset"
        read -p "$(echo -e "$yellow Enter (y/Yes) for Yes or (n/No) for No [default: y]: $reset")" Meili_option_choice

        case "${Meili_option_choice,,}" in
            y|yes|"")
                Meili_option_value="yes"
                ;;
            n|no)
                Meili_option_value="no"
                ;;
            *)
                retries=$((retries + 1))
                echo -e "$red Invalid input. Please enter y/Yes or n/No. ($retries/$max_retries)$reset"
                if [ $retries -ge $max_retries ]; then
                    echo -e "$red Too many invalid attempts. Please re-run the script.$reset"
                    exit 1
                fi
                continue
                ;;
        esac

        echo -e "$green You selected: $Meili_option_value $reset"
        break
    done
}

# Release Selection:
release_selection() {
    local retries=0
    local max_retries=2
    local release_choice=""

    ReleaseSelection=""

    while true; do
        echo -e ""
        echo -e "$yellow Select the release type for installation:$reset"
        echo -e "$cyan 1) Official (stable - recommended)$reset"
        echo -e "$cyan 2) RC (Release Candidate)$reset"
        echo -e "$cyan 3) Beta (testing)$reset"

        read -p "$(echo -e "$yellow Enter 1/2/3 [default: 1]: $reset")" release_choice

        case "${release_choice,,}" in
            1|"")
                ReleaseSelection="official"
                ;;
            2)
                ReleaseSelection="rc"
                ;;
            3)
                ReleaseSelection="beta"
                ;;
            *)
                retries=$((retries + 1))
                echo -e "$red Invalid input. Please enter 1, 2, or 3. ($retries/$max_retries)$reset"
                if [ $retries -ge $max_retries ]; then
                    echo -e "$red Too many invalid attempts. Please re-run the script.$reset"
                    exit 1
                fi
                continue
                ;;
        esac

        echo -e "$green You selected: $ReleaseSelection $reset"
        break
    done
}

# Faveo Environment Selection:
faveo_env_selection() {
    local retries=0
    local max_retries=2
    local env_choice=""

    ENV_SETUP=""

    while true; do
        echo -e ""
        echo -e "$yellow Select the Faveo application environment:$reset"
        echo -e "$cyan 1) Production (default)$reset"
        echo -e "$cyan 2) Development$reset"
        echo -e "$cyan 3) Testing$reset"

        read -p "$(echo -e "$yellow Enter 1/2/3 [default: 1]: $reset")" env_choice

        case "${env_choice,,}" in
            1|"")
                ENV_SETUP="production"
                ;;
            2)
                ENV_SETUP="development"
                ;;
            3)
                ENV_SETUP="testing"
                ;;
            *)
                retries=$((retries + 1))
                echo -e "$red Invalid input. Please enter 1, 2, or 3. ($retries/$max_retries)$reset"
                if [ $retries -ge $max_retries ]; then
                    echo -e "$red Too many invalid attempts. Please re-run the script.$reset"
                    exit 1
                fi
                continue
                ;;
        esac

        echo -e "$green You selected: $ENV_SETUP $reset"
        break
    done
}

# Getting product details for Faveo Installation:
# shows a full summary and launches the installation directly.
attributes () {
    local max_retries=2
    local retries
    local _input

    # Verify this is actually a supported RHEL-family OS before continuing
    if [[ -f /etc/os-release ]]; then
        OS_ID_CHECK=$(grep '^ID=' /etc/os-release | cut -d '=' -f2 | tr -d '"')
        if [[ ! "$OS_ID_CHECK" =~ ^(rhel|almalinux|rocky|centos)$ ]]; then
            echo -e "$red This script is intended for RHEL, AlmaLinux, Rocky Linux, or CentOS only. Detected: $OS_ID_CHECK $reset"
            exit 1
        fi
    fi

    # Domain Name
    if [[ -z "$DomainName" ]]; then
        retries=0
        while true; do
            echo -e "$cyan Enter the following details required by the Faveo Helpdesk Installation. $reset"
            read -p "$(echo -e "$yellow Domain Name [For Faveo Installation without https://]: $reset")" DomainName
            [[ -n "$DomainName" ]] && break
            retries=$((retries+1))
            echo -e "$red Invalid domain. Try again. ($retries/$max_retries)$reset"
            [[ $retries -ge $max_retries ]] && { echo -e "$red Too many failed attempts. Exiting.$reset"; exit 1; }
        done
    fi

    # Email
    local _email_re="^[A-Za-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[A-Za-z0-9!#\$%&'*+/=?^_\`{|}~-]+)*@([A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z]{2,}$"
    if [[ -z "$Email" ]]; then
        retries=0
        while true; do
            read -p "$(echo -e "$yellow Email [Valid email address for Server Side Installation]: $reset")" Email
            [[ "$Email" =~ $_email_re ]] && break
            retries=$((retries+1))
            echo -e "$red Invalid email format. Try again. ($retries/$max_retries)$reset"
            [[ $retries -ge $max_retries ]] && { echo -e "$red Too many failed attempts. Exiting.$reset"; exit 1; }
        done
    fi

    # License Code
    if [[ -z "$LicenseCode" ]]; then
        retries=0
        while true; do
            read -p "$(echo -e "$yellow License Code (16 chars) This can be obtained from [https://billing.faveohelpdesk.com]: $reset")" LicenseCode
            [[ ${#LicenseCode} -eq 16 ]] && break
            retries=$((retries+1))
            echo -e "$red Must be exactly 16 characters. ($retries/$max_retries)$reset"
            [[ $retries -ge $max_retries ]] && { echo -e "$red Too many failed attempts. Exiting.$reset"; exit 1; }
        done
    fi

    # Order Number
    if [[ -z "$OrderNumber" ]]; then
        retries=0
        while true; do
            read -p "$(echo -e "$yellow Order Number (8 chars) This can be obtained from [https://billing.faveohelpdesk.com]: $reset")" OrderNumber
            [[ ${#OrderNumber} -eq 8 ]] && break
            retries=$((retries+1))
            echo -e "$red Must be exactly 8 characters. ($retries/$max_retries)$reset"
            [[ $retries -ge $max_retries ]] && { echo -e "$red Too many failed attempts. Exiting.$reset"; exit 1; }
        done
    fi

    # Release type  (default: official)
    if [[ -z "$ReleaseSelection" ]]; then
        release_selection
    fi

    # Faveo environment  (default: production)
    if [[ -z "$ENV_SETUP" ]]; then
        faveo_env_selection
    fi

    # Meilisearch  (default: yes)
    if [[ -z "$Meili_option_value" ]]; then
        meili_option
    fi

    # NATS / Network Discovery  (default: no)
    if [[ -z "$Nats_option_value" ]]; then
        nats_installation
    fi

    # PHP version  (default: 8.4)
    if [[ -z "$Php_option_value" ]]; then
        php_selection
    fi

    # Node.js  (default: yes)
    if [[ -z "$Node_option_value" ]]; then
        node_option
    fi

    # SQL server (default: mysql) - always run this so remote/local location
    # and any remote connection details get resolved, even if --sql was
    # supplied on the command line.
    sql_server_selection

    # Web server
    if [[ -z "$Webserver_option_value" ]]; then
        web_server_selection
    fi

    # SSL type
    if [[ -z "$Ssl_option_value" ]]; then
        ssl_selection
    fi

    echo ""
    echo -e "${cyan}${bold}╔══════════════════════════════════════════════════════╗${reset}"
    echo -e "${cyan}${bold}       Faveo Installation Summary (RHEL-family)        ${reset}"
    echo -e "${cyan}${bold}╚══════════════════════════════════════════════════════╝${reset}"
    printf "${yellow}  %-22s${green}%s${reset}\n" "Domain:"          "$DomainName"
    printf "${yellow}  %-22s${green}%s${reset}\n" "Email:"           "$Email"
    printf "${yellow}  %-22s${green}%s${reset}\n" "License Code:"    "$LicenseCode"
    printf "${yellow}  %-22s${green}%s${reset}\n" "Order Number:"    "$OrderNumber"
    echo -e "${cyan}  ──────────────────────────────────────────────────────${reset}"
    printf "${yellow}  %-22s${green}%s${reset}\n" "Release:"         "$ReleaseSelection"
    printf "${yellow}  %-22s${green}%s${reset}\n" "Environment:"     "$ENV_SETUP"
    printf "${yellow}  %-22s${green}%s${reset}\n" "Meilisearch:"     "$Meili_option_value"
    printf "${yellow}  %-22s${green}%s${reset}\n" "NATS:"            "$Nats_option_value"
    printf "${yellow}  %-22s${green}%s${reset}\n" "PHP Version:"     "$Php_option_value"
    printf "${yellow}  %-22s${green}%s${reset}\n" "Node.js:"         "$Node_option_value"
    printf "${yellow}  %-22s${green}%s${reset}\n" "SQL Server:"      "$Sql_option_value"
    if [[ "$Remote_Sql_option_value" == "yes" ]]; then
        printf "${yellow}  %-22s${green}%s${reset}\n" "SQL Location:"    "Remote ($MySQL_HOST:${MySQL_PORT:-3306})"
        printf "${yellow}  %-22s${green}%s${reset}\n" "SQL Secure:"      "$MySQL_SEC"
    else
        printf "${yellow}  %-22s${green}%s${reset}\n" "SQL Location:"    "Local (installed on this server)"
    fi
    printf "${yellow}  %-22s${green}%s${reset}\n" "Web Server:"      "$Webserver_option_value"
    printf "${yellow}  %-22s${green}%s${reset}\n" "SSL Type:"        "$Ssl_option_value"
    if [[ "$Ssl_option_value" == "paid-ssl" ]]; then
        printf "${yellow}  %-22s${green}%s${reset}\n" "Certificate:"    "$certfile"
        printf "${yellow}  %-22s${green}%s${reset}\n" "Key File:"       "$keyfile"
        printf "${yellow}  %-22s${green}%s${reset}\n" "CA Bundle:"      "$cacertfile"
    fi
    echo -e "${cyan}${bold}╚══════════════════════════════════════════════════════╝${reset}"

    # Base packages required throughout the install
    dnf update -y && dnf install -y unzip wget nano yum-utils curl openssl zip git tar

    node_installation "$DomainName" "$Email" "$LicenseCode" "$OrderNumber" "$ReleaseSelection" "$Meili_option_value" "$Nats_option_value" "$Php_option_value" "$Node_option_value" "$Sql_option_value" "$Webserver_option_value" "$Ssl_option_value" "$certfile" "$keyfile" "$cacertfile"
}
parse_args "$@"
attributes
}
rhel_block "$@"

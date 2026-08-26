#!/bin/bash
##---------- Author : Vishwas S & Thirumoorthi Duraipandi------------------------------------##
##---------- Email : vishwas.s@ladybirdweb.com,thirumoorthi.duraipandi@ladybirdweb.com-------##
##---------- Github page : https://github.com/ladybirdweb/faveo-server-images/---------------##
##---------- Purpose : Auto Install Faveo Helpdesk in a linux system.------------------------##
##---------- Tested on : RHEL9/8/7, Rocky 9/8, Ubuntu22/20/18, CentOS 9 Stream, Debian 11----## 
##---------- Updated version : v1.0 (Updated on 2nd Dec 2022) -------------------------------##
##-----NOTE: This script requires root privileges, otherwise one could run the script -------##
##---------- as a sudo user who got root privileges. ----------------------------------------##
##----USAGE: "sudo /bin/bash faveo-autoscript.sh" -------------------------------------------##


# Colour variables for the script.

red=$(tput setaf 1)

green=$(tput setaf 2)

yellow=$(tput setaf 11)

skyblue=$(tput setaf 14)

reset=$(tput sgr0)

echo -e "$skyblue Faveo Helpdesk AUTO-INSTALLER v1.0 $reset"
# Faveo Banner.

echo -e "$skyblue                                                                                                                         $reset";
sleep 0.05
echo -e "$skyblue                                        _______ _______ _     _ _______ _______                                          $reset";
sleep 0.05
echo -e "$skyblue                                       (_______|_______|_)   (_|_______|_______)                                         $reset";
sleep 0.05
echo -e "$skyblue                                        _____   _______ _     _ _____   _     _                                          $reset";
sleep 0.05
echo -e "$skyblue                                       |  ___) |  ___  | |   | |  ___) | |   | |                                         $reset";
sleep 0.05
echo -e "$skyblue                                       | |     | |   | |\ \ / /| |_____| |___| |                                         $reset";
sleep 0.05
echo -e "$skyblue                                       |_|     |_|   |_| \___/ |_______)\_____/                                          $reset";
sleep 0.05
echo -e "$skyblue                                                                                                                         $reset";
sleep 0.05
echo -e "$skyblue                               _     _ _______ _       ______ ______  _______  ______ _     _                            $reset";
sleep 0.05
echo -e "$skyblue                             (_)   (_|_______|_)     (_____ (______)(_______)/ _____|_)   | |                            $reset";
sleep 0.05
echo -e "$skyblue                              _______ _____   _       _____) )     _ _____  ( (____  _____| |                            $reset";
sleep 0.05
echo -e "$skyblue                             |  ___  |  ___) | |     |  ____/ |   | |  ___)  \____ \|  _   _)                            $reset";
sleep 0.05
echo -e "$skyblue                             | |   | | |_____| |_____| |    | |__/ /| |_____ _____) ) |  \ \                             $reset";
sleep 0.05
echo -e "$skyblue                             |_|   |_|_______)_______)_|    |_____/ |_______|______/|_|   \_)                            $reset";
sleep 0.05
echo -e "$skyblue                                                                                                                         $reset";
sleep 0.05
echo -e "$skyblue                                                                                                                         $reset";



echo -e "$yellow                   This is a automated Installation Script for Faveo Helpdesk products which runs on Linux Distro's $reset";
echo -e "                                                                                                          "
sleep 0.05
echo -e "$yellow    At the end of this script you will get the details for the faveo GUI configuration please copy those information for future use $reset";
sleep 0.05




# Detect Debian users running the script with "sh" instead of bash.
    
echo -e " ";
if readlink /proc/$$/exe | grep -q "dash"; then
	echo "&red This installer needs to be run with 'bash', not 'sh'. $reset";
	exit 1
fi

# Checking for the Super User.
    
echo -e " ";
if [[ $EUID -ne 0 ]]; then
   echo -e "$red This script must be run as root $reset";
   exit 1
fi

################################# DEBIAN BLOCK ##########################################

debian_block ()
{
rollback ()
{
    rm -rf /var/lib/mysql /etc/cron.d/faveo* #Avoiding prompt to delete Database that is created by this script and removing cronjobs.
    apt purge apache2 -y
    apt purge mariadb* redis supervisor php8.1* -y  && apt autoremove -y
    apt purge wkhtmltox -y 
    rm -rf $PWD/*.deb /etc/apt/sources.list.d/mariadb*  /etc/apt/trusted.gpg.d/sury-keyring.gpg /etc/cron.d/faveo-ssl /var/www/faveo /usr/local/share/ca-certificates/*
    update-ca-certificates --fresh 
    echo -e "$red Contact Faveo Technical Support. $reset"
    echo -e "$red Rolled Back. $reset"
    exit 1
}

# Prompting Final Credentials.
credentials ()
{
    echo "Your URL: https://$1" >> "$PWD"/credentials.txt
    echo "Database Username: faveo" >> /"$PWD"/credentials.txt
    echo "Database Password: $2" >> "$PWD"/credentials.txt
    echo -e "$skyblue Faveo Helpdesk successfully installed. Please visit $1 and finish the GUI Installation$reset"
    echo -e "$skyblue Faveo Database name: faveo $reset"
    echo -e "$skyblue Database Username:   faveo $reset"
    echo -e "$skyblue Database Password:   $2 $reset"
    echo -e "$green You can find this details saved in $PWD/credentials.txt.$reset"
    exit 0
}

redis ()
{
    echo -e "$green Installing and Configuring Redis. $reset"
    apt install redis supervisor -y  
    systemctl enable redis-server
    systemctl enable supervisor
cat <<  EOF > /etc/supervisor/conf.d/faveo-worker.conf
[program:faveo-Horizon]
process_name=%(program_name)s
command=php /var/www/faveo/artisan horizon
autostart=true
autorestart=true
user=www-data
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/horizon-worker.log
EOF
systemctl restart supervisor
if [[ $? != 0 ]]; then
    echo -e "\n";
    echo -e "$red Something went wrong. Configuring Redis and Supervisor. $reset"
    echo -e "$red Rolling Back..... $reset"
    rollback
    echo -e "\n";
else
    echo -e "$green Redis & Supervisor configured. $reset"
    echo -e "$green Configuring Faveo Cronjob $reset"
    (sudo -u www-data crontab -l 2>/dev/null; echo "* * * * * /usr/bin/php /var/www/faveo/artisan schedule:run 2>&1") | sudo -u www-data crontab -
    credentials "$1" "$2"
fi
}

extensions ()
{
    wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz   
    tar -zxf "$PWD"/ioncube_loaders_lin_x86-64.tar.gz
    \cp "$PWD"/ioncube/ioncube_loader_lin_8.1.so /usr/lib/php/20210902/
    rm -rf "$PWD"/ioncube*
    sed -i '2 a zend_extension = "/usr/lib/php/20210902/ioncube_loader_lin_8.1.so"' /etc/php/8.1/apache2/php.ini
    sed -i '2 a zend_extension = "/usr/lib/php/20210902/ioncube_loader_lin_8.1.so"' /etc/php/8.1/cli/php.ini
    sed -i '2 a zend_extension = "/usr/lib/php/20210902/ioncube_loader_lin_8.1.so"' /etc/php/8.1/fpm/php.ini
    derivative=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
    if [[ $derivative == 2004 ]]; then
        apt-get install wkhtmltopdf -y
        if [[ $? != 0 ]]; then
            echo -e "\n";
            echo -e "$red Something went wrong. Configuring PDF Plugin. $reset"
            echo -e "$red Rolling Back..... $reset"
            rollback
        fi
        rm -f "$PWD"/wkhtmltox_0.12.6-1.focal_amd64.deb
    elif [[ $derivative == 2204 ]]; then
        apt-get install libfontenc1 xfonts-75dpi xfonts-base xfonts-encodings xfonts-utils -y
        wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb     
        dpkg -i wkhtmltox_0.12.6.1-3.jammy_amd64.deb
        apt --fix-broken install -y
        if [[ $? != 0 ]]; then
            echo -e "\n";
            echo -e "$red Something went wrong. Configuring PDF Plugin. $reset"
            echo -e "$red Rolling Back..... $reset"
            rollback
        fi
        rm -f "$PWD"/wkhtmltox_0.12.6-1.focal_amd64.deb
    else
        apt-get install wkhtmltopdf -y
        systemctl restart apache2
    fi
}


dependencies ()
{   
    echo -e "$green Installing PHP and configuring necessary extensions. $reset"
    if grep -qs "ubuntu" /etc/os-release; then
        add-apt-repository --yes ppa:ondrej/php  ; 
        apt update && apt-get install -y php8.1 libapache2-mod-php8.1 php8.1-mysql \
        php8.1-cli php8.1-common php8.1-fpm php8.1-soap php8.1-gd \
        php8.1-opcache  php8.1-mbstring php8.1-zip \
        php8.1-bcmath php8.1-intl php8.1-xml php8.1-curl  \
        php8.1-imap php8.1-ldap php8.1-gmp php8.1-redis  
    elif grep -qs "debian" /etc/os-release; then
        echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/sury-php.list
        curl -fsSL  https://packages.sury.org/php/apt.gpg| sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/sury-keyring.gpg --yes
        apt update && apt install -y php8.1 libapache2-mod-php8.1 php8.1-mysql \
        php8.1-cli php8.1-common php8.1-fpm php8.1-soap php8.1-gd \
        php8.1-opcache  php8.1-mbstring php8.1-zip \
        php8.1-bcmath php8.1-intl php8.1-xml php8.1-curl  \
        php8.1-imap php8.1-ldap php8.1-gmp php8.1-redis  
    fi
    if [[ $? != 0 ]]; then
        echo -e "\n";
        echo -e "$red Something went wrong Configuring PHP. $reset"
        echo -e "$red Rolling Back..... $reset"
        rollback
        echo -e "\n";
    else
        sed -i 's/file_uploads =.*/file_uploads = On/g' /etc/php/8.1/fpm/php.ini
        sed -i 's/allow_url_fopen =.*/allow_url_fopen = On/g' /etc/php/8.1/fpm/php.ini
        sed -i 's/short_open_tag =.*/short_open_tag = On/g' /etc/php/8.1/fpm/php.ini
        sed -i 's/memory_limit =.*/memory_limit = 256MB/g' /etc/php/8.1/fpm/php.ini
        sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo = 0/g' /etc/php/8.1/fpm/php.ini
        sed -i 's/upload_max_filesize =.*/upload_max_filesize = 100M/g' /etc/php/8.1/fpm/php.ini
        sed -i 's/post_max_size =.*/post_max_size = 100M/g' /etc/php/8.1/fpm/php.ini
        sed -i 's/max_execution_time =.*/max_execution_time = 360/g' /etc/php/8.1/fpm/php.ini
        sed -i 's/max_execution_time =.*/max_execution_time = 360/g' /etc/php/8.1/apache2/php.ini  
        sed -i 's/file_uploads =.*/file_uploads = On/g' /etc/php/8.1/cli/php.ini
        sed -i 's/allow_url_fopen =.*/allow_url_fopen = On/g' /etc/php/8.1/cli/php.ini
        sed -i 's/short_open_tag =.*/short_open_tag = On/g' /etc/php/8.1/cli/php.ini
        sed -i 's/memory_limit =.*/memory_limit = -1/g' /etc/php/8.1/cli/php.ini
        sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo = 0/g' /etc/php/8.1/cli/php.ini
        sed -i 's/upload_max_filesize =.*/upload_max_filesize = 100M/g' /etc/php/8.1/cli/php.ini
        sed -i 's/post_max_size =.*/post_max_size = 100M/g' /etc/php/8.1/cli/php.ini
        sed -i 's/max_execution_time =.*/max_execution_time = 360/g' /etc/php/8.1/cli/php.ini
        sed -i 's/file_uploads =.*/file_uploads = On/g' /etc/php/8.1/apache2/php.ini
        sed -i 's/allow_url_fopen =.*/allow_url_fopen = On/g' /etc/php/8.1/apache2/php.ini
        sed -i 's/short_open_tag =.*/short_open_tag = On/g' /etc/php/8.1/apache2/php.ini
        sed -i 's/memory_limit =.*/memory_limit = -1/g' /etc/php/8.1/apache2/php.ini
        sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo = 0/g' /etc/php/8.1/apache2/php.ini
        sed -i 's/upload_max_filesize =.*/upload_max_filesize = 100M/g' /etc/php/8.1/apache2/php.ini
        sed -i 's/post_max_size =.*/post_max_size = 100M/g' /etc/php/8.1/apache2/php.ini
        sed -i 's/max_execution_time =.*/max_execution_time = 360/g' /etc/php/8.1/apache2/php.ini 
        extensions
        if [[ $? != 0 ]]; then
                echo -e "\n";
                echo -e "$red Something went wrong.Cronfiguring PHP. $reset"
                echo -e "$red Rolling Back..... $reset"
                rollback
                echo -e "\n";
            else
                systemctl restart php8.1-fpm
                systemctl restart apache2
                echo -e "$green PHP is configured. $reset"
        fi            
    fi
    echo "$green Updating MariaDB-10.6 Repository.$reset"
        curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup   
        bash mariadb_repo_setup --mariadb-server-version=10.6        
        if [[ $? != 0 ]]; then
            echo -e "\n";
            echo -e "$red Something went wrong. Configuring MariaDB-10.6. $reset"
            echo -e "$red Rolling Back..... $reset"
            rollback
            echo -e "\n";
        else
            apt update; apt install mariadb-server mariadb-client -y
            systemctl enable mariadb
            systemctl start mariadb
            rm -f "$PWD"/mariadb_repo_setup 
            PASS=$(openssl rand -base64 12)
            mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE faveo;
CREATE USER 'faveo'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON faveo.* TO 'faveo'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

            if [[ $? != 0 ]]; then
                echo -e "\n";
                echo -e "$red Something went wrong.Creating Database user. $reset"
                echo -e "$red Rolling Back..... $reset"
                rollback
                echo -e "\n";
            else
                echo -e "$green MariaDB-10.6 is configured. $reset"
                redis  "$1" "$PASS"
            fi
    fi
}

faveo_configure ()
{
    #echo $1 $2 $3 
    curl https://billing.faveohelpdesk.com/download/faveo\?order_number\=$3\&serial_key\=$2 --output $PWD/faveo.zip 
    unzip $PWD/faveo.zip -d /var/www/faveo  >>/dev/null
    rm -f $PWD/faveo.zip
    mkdir /var/www/storage
    if [[ $? != 0 ]]; then
        echo -e "\n";
        echo -e "$red Something went wrong. Downloading Faveo Helpdesk package. $reset"
        echo -e "$red Rolling Back..... $reset"
        rollback
        echo -e "\n";
    else
        chown -R www-data:www-data /var/www
        dependencies "$1"
    fi   
}

certbot_apache ()
{
    #echo "$1" "$2" "$3" "$4" 
    echo -e "$green Obtaining Certificates for $1 from Letsencrypt. $reset"
    apt-get install python3-certbot-apache -y  
    certbot run -n --apache --agree-tos -d "$1"  -m  "$2" --redirect -q
    if [[ $? != 0 ]]; then
    echo -e "$red Failed to obtain SSL certificates $reset";
    rollback
    else 
    echo -e "$green Certificate Obtained. $reset"
    echo "45 2 * * 6 /etc/letsencrypt/ && ./certbot renew && /bin/systemctl restart apache2.service" | sudo tee /etc/cron.d/faveo-ssl
    faveo_configure "$1" "$3" "$4" 
    fi
}

self_signed_apache ()
{
    echo "$1" "$2" "$3" "$4" 
    echo -e "$green Generating Self Signed SSL certificates for $1. $reset"
    mkdir -p /etc/apache2/ssl
    openssl ecparam -out /etc/apache2/ssl/faveoroot.key -name prime256v1 -genkey
    openssl req -new -sha256 -key /etc/apache2/ssl/faveoroot.key -out /etc/apache2/ssl/faveoroot.csr -subj "/C=/ST=/L=/O=/OU=/CN="
    openssl x509 -req -sha256 -days 7300 -in /etc/apache2/ssl/faveoroot.csr -signkey /etc/apache2/ssl/faveoroot.key -out /etc/apache2/ssl/faveorootCA.crt
    openssl ecparam -out /etc/apache2/ssl/private.key -name prime256v1 -genkey
    openssl req -new -sha256 -key /etc/apache2/ssl/private.key -out /etc/apache2/ssl/faveolocal.csr -subj "/C=IN/ST=Karnataka/L=Bangalore/O=Ladybird Web Solutions Pvt Ltd/OU=Development Team/CN=$1"
    openssl x509 -req -in /etc/apache2/ssl/faveolocal.csr -CA  /etc/apache2/ssl/faveorootCA.crt -CAkey /etc/apache2/ssl/faveoroot.key -CAcreateserial -out /etc/apache2/ssl/faveolocal.crt -days 7300 -sha256
    openssl x509 -in /etc/apache2/ssl/faveolocal.crt -text -noout
    if [[ $? -eq 0 ]]; then
        echo -e "$green Certificates generated successfully for $1 $reset"
    else
        echo -e "$red Certification generation failed. $reset"
        rollback
    fi;

    cp /etc/apache2/ssl/faveorootCA.crt /usr/local/share/ca-certificates/
    update-ca-certificates
cat <<  EOF > /etc/apache2/sites-available/faveo-ssl.conf
<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerName $1
    DocumentRoot /var/www/faveo/public
    <Directory /var/www/faveo>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/apache2/faveo-ssl-error.log
    CustomLog /var/log/apache2/faveo-ssl-access.log combined

SSLCertificateFile /etc/apache2/ssl/faveolocal.crt
SSLCertificateKeyFile /etc/apache2/ssl/private.key
</VirtualHost>
</IfModule>
EOF
    a2enmod ssl
    a2ensite faveo-ssl.conf
    systemctl restart apache2
    test=$(curl -ks https://"$1"/test.html)
        if [[ "$test" == "Test" ]]; then
            echo -e "\n";
            echo -e "$green Self Signed SSL Configured for $1. $reset."
            faveo_configure "$1" "$3" "$4" 
        else
            echo -e "$red Self Signed SSL Configuration failed. $reset"
            rollback
        fi
}

paid_ssl_apache ()
{
    echo "$1" "$2" "$3" "$4" "$5" "$6"
    echo -e "$green Configuring SSL Certificates for $1. $reset"
cat <<  EOF > /etc/apache2/sites-available/faveo-ssl.conf
<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerName $1
    DocumentRoot /var/www/faveo/public
    <Directory /var/www/faveo>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/apache2/faveo-ssl-error.log
    CustomLog /var/log/apache2/faveo-ssl-access.log combined

SSLCertificateFile $5
SSLCertificateKeyFile $6
</VirtualHost>
</IfModule>
EOF
    a2enmod ssl
    a2ensite faveo-ssl.conf
    systemctl restart apache2
    test=$(curl -ks https://"$1"/test.html)
        if [[ "$test" == "Test" ]]; then
            echo -e "\n";
            echo -e "$green SSL Configured for $1. $reset."
            faveo_configure "$1" "$3" "$4" 
        else
            echo -e "$red SSL Configuration failed. $reset"
            rollback
        fi
}

web_server_configuration ()
{
    echo "$1" #domain
    echo "$2" #email
    echo "$3" #license
    echo "$4" #orderno
    echo "$5" #web_server
    echo "$6" #ssl_type
    echo "$7" #certfile
    echo "$8" #keyfile

    if [[ "$5" == "apache" ]]; then
        echo -e "\n";
        echo -e "$green Installing Apache. $reset";
        echo -e "                       ";
    
        ### Ubuntu 22.04 needrestart configuration
        if [[ $(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.') == 2204 ]]; then
            sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
            sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/g" /etc/needrestart/needrestart.conf
        fi
        ### APACHE Installation
        apt-get update  && apt-get upgrade -y  && apt-get install lsb-release \
        ca-certificates apt-transport-https software-properties-common gnupg2 wget zip unzip curl nano -y 
        if grep -qs "ubuntu" /etc/os-release; then
            add-apt-repository --yes ppa:ondrej/apache2 
            apt-get update   && apt-get install apache2 -y 
            systemctl enable apache2  
        elif grep -qs "debian" /etc/os-release; then
            curl -sSLo /usr/share/keyrings/deb.sury.org-apache2.gpg https://packages.sury.org/apache2/apt.gpg
            sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-apache2.gpg] https://packages.sury.org/apache2/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/apache2.list'
            apt-get update  && apt-get install apache2 -y 
            systemctl enable apache2
            if [[ $? != 0 ]]; then
                echo -e "\n";
                echo -e "$red Apache Installation Failed.Check your Internet connection/Firewall/Domain Propagaion. $reset"
                echo -e "$red Rolling Back..... $reset"
                rollback
                echo -e "\n";
            fi
        fi
    ### Creating Temporary Index file for Testing
    mkdir -p /var/www/faveo/public
    echo "Test" > /var/www/faveo/public/test.html      
    ### Apache configuration.
    touch /etc/apache2/sites-available/faveo.conf
    echo "127.0.0.1      $1" >> /etc/hosts
    
cat <<  EOF > /etc/apache2/sites-available/faveo.conf
<VirtualHost *:80>
    ServerName $1
    DocumentRoot /var/www/faveo/public
    <Directory /var/www/faveo>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/apache2/faveo-error.log
    CustomLog /var/log/apache2/faveo-access.log combined
</VirtualHost>
EOF
    a2enmod rewrite
    a2dissite 000-default.conf
    a2ensite faveo.conf
    systemctl restart apache2
    test=$(curl -s http://"$1"/test.html)
        if [[ "$test" == "Test" ]]; then
        echo -e "\n";
        echo -e "$green Apache Configured. $reset"
            if [[ "$6" == "certbot" ]]; then
                certbot_apache "$1" "$2" "$3" "$4" 
            elif [[ "$6" == "self-signed" ]]; then
                self_signed_apache "$1" "$2" "$3" "$4" 
            elif [[ "$6" == "paid-ssl" ]]; then
                #echo "$1" "$2" "$3" "$4" "$7" "$8"
                paid_ssl_apache "$1" "$2" "$3" "$4" "$7" "$8"
            else
                echo -e "$red Something went wrong in SSL Selection. $reset"
                exit 1
            fi
        else
        echo -e "\n";
        echo -e "$red Something went wrong. Check your Internet connection/Firewall/Domain Propagaion. $reset"
        echo -e "$red Rolling Back..... $reset"
        rollback
        echo -e "\n";
        fi
    elif [[ "$1" == "nginx" ]]; then
        echo -e "\n";
        echo -e "$red Installing Nginx. $reset"
        ### NGINX Installation
        apt-get update  && apt-get upgrade -y  && apt-get install lsb-release \
        ca-certificates apt-transport-https software-properties-common gnupg2 wget zip unzip curl nano -y
        add-apt-repository --yes ppa:ondrej/nginx  
        apt-get update && apt install nginx -y  
        systemctl enable nginx && systemctl start nginx
        echo -e "                       "
            if [[ $? != 0 ]]; then
                echo -e "\n";
                echo -e "$red Something went wrong. Check your Internet connection/Firewall/Domain Propagaion. $reset"
                echo -e "$red Rolling Back..... $reset"
                rollback
                echo -e "\n";
            fi
    else
        echo -e "$red Something went wrong. Check your Internet connection. $reset"
        echo -e "$red Rolling Back....... $reset"
        rollback
    fi
            
}



# SSL Selection Prompt
ssl_selection ()
{
    echo -e "                                       "
    echo -e "$skyblue Select your preferred SSL certficates for Faveo Helpdesk.$reset";
    sleep 0.05
    echo -e "$green Press (A) for FreeSSL from Letsencrypt $reset";
    echo -e "$green Press (B) for Self-Signed SSL $reset";
    echo -e "$green Press (C) for Paid SSL $reset";
    read -p "$yellow Please select from available options [A,B,C]:" ssl
    if [[ "$ssl" =~ ^(A|a)$ ]]; then
        echo -e "$green You have selected Lets Encrypt Free SSL $reset";
        ssl_type=certbot
        web_server_configuration "$1" "$2" "$3" "$4" "$5" "$ssl_type"
    elif [[ "$ssl" =~ ^(B|b)$ ]]; then 
        echo -e "$green You have selected Self-Signed SSL $reset";
        ssl_type=self-signed
        web_server_configuration "$1" "$2" "$3" "$4" "$5" "$ssl_type"
    elif [[ "$ssl" =~ ^(C|c)$ ]]; then
        echo -e "$green You have selected Paid SSL $reset";
        ssl_files ()
        {
            read -p "$yellow Input the Absolute Path to Certificate file for $1 : $reset" certfile
            read -p "$yellow Input the Absolute Path to Certificate Key file for $1: $reset" keyfile
            ssl_type=paid-ssl
            #echo "$1" "$2" "$3" "$4" "$5" "$ssl_type" "$certfile" "$keyfile"
            web_server_configuration "$1" "$2" "$3" "$4" "$5" "$ssl_type" "$certfile" "$keyfile"
        }
        ssl_files "$1" "$2" "$3" "$4" "$5"
    else 
        echo -e "$red Please select a valid option: $reset";
        ssl_selection
    fi
    
}

# Webserver selection prompt
web_server_selection ()
{
    sleep 0.05
    echo -e "                                       "
    echo -e "$skyblue Select your preferred web server[APACHE or NGINX].$reset";
    sleep 0.05
    echo -e "$green (1) - Apache $reset";
    sleep 0.05
    echo -e "$green (2) - Nginx $reset";
    echo -e "                                 "
    read -p "$yellow Enter 1 for Apache, 2 for Nginx: $reset" webserver
            echo -e "                                 "
    if [[ "$webserver" == "1" ]]; then
        web_server="apache"
        echo -e "$green You have selected Apache Webserver $reset";
        ssl_selection "$1" "$2" "$3" "$4" "$web_server"
    elif [[ "$webserver" == "2" ]]; then
        web_server="nginx"
        echo -e "$green You have selected Nginx Webserver $reset";
        ssl_selection "$1" "$2" "$3" "$4" "$web_server"
    else 
        echo -e "$red Please select your preferred Web Server. $reset";
        web_server_selection
    fi
    sleep 0.05
}
attributes ()
{
    sleep 0.05
    echo -e "                                 "
    echo -e "$skyblue Enter the following details required by the Faveo Helpdesk Installaion. $reset";
    sleep 0.05
#Enter Domain:
    echo -e "                                 "
    read -p "$yellow Domain Name: $reset" DomainName
    sleep 0.05
#Enter Email:
    regex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"
    echo -e "                                 "
    read -p "$yellow Email:  $reset" Email
    if [[ $Email =~ $regex ]] ; then
        echo "                                "
        sleep 0.05
    else
        echo -e "$red Please Enter a Valid Email$reset"
        echo "                                "
        attributes
    fi

#Enter License code:
    echo "$yellow You can find the License and Order Number of your product by visiting https://billing.faveohelpdesk.com $reset";
    echo -e "                                   "
    read -n 16 -p "$yellow License Code:  $reset" LicenseCode
    echo -e "                                 "
    sleep 0.05
#Enter Order No:
    echo -e "                                 "
    read -n 8 -p "$yellow Order Number: $reset" OrderNumber
    sleep 0.05
#Confirming the entered details:
    echo -e "                                 "
    echo -e "\n";
    echo -e "Confirm the Entered details:\n";
    sleep 0.05
    echo -e "============================\n";
    sleep 0.05
    echo -e "                                 "
    echo "Domain Name    :$yellow $DomainName $reset";
    sleep 0.05
    echo -e "                                 "
    echo "Email          :$yellow $Email $reset";
    sleep 0.05
    echo -e "                                 "
    echo "License Code   :$yellow $LicenseCode $reset";
    sleep 0.05
    echo -e "                                 "
    echo "Order Number   :$yellow $OrderNumber $reset";
    echo -e "                                 "
    sleep 0.05
    
    read -p "Continue ($green y $reset/$red n $reset)?" REPLY
    if [[ ! $REPLY =~ ^(yes|y|Yes|YES|Y) ]]; then
        attributes
    else
        echo -e "                                 "
        web_server_selection "$DomainName" "$Email" "$LicenseCode" "$OrderNumber"
        echo -e "                                 "
    fi;    
}
attributes
}


############################## REDHAT BLOCK ############################################

redhat_block ()
{
rollback ()
{
    rm -rf /var/lib/mysql /etc/cron.d/faveo* /etc/pki/ca-trust/source/anchors/faveo* #Avoiding prompt to delete Database that is created by this script and removing cronjobs.
    yum remove httpd epel-release mod_ssl remi-release mariadb* redis supervisor php-* php* -y
    rm -rf /etc/httpd /var/www/faveo
    update-ca-trust --force-enable
    echo -e "$red Contact Faveo Technical Support. $reset"
    echo -e "$red Rolled Back. $reset"
    exit 1
}

credentials ()
{
    echo "Your URL: https://$1" >> "$PWD"/credentials.txt
    echo "Database Username: faveo" >> /"$PWD"/credentials.txt
    echo "Database Password: $2" >> "$PWD"/credentials.txt
    echo -e "$skyblue Faveo Helpdesk successfully installed. Please visit $1 and finish the GUI Installation$reset"
    echo -e "$skyblue Faveo Database name: faveo $reset"
    echo -e "$skyblue Database Username:   faveo $reset"
    echo -e "$skyblue Database Password:   $2 $reset"
    echo -e "$green You can find this details saved in $PWD/credentials.txt.$reset"
    exit 0
}

redis ()
{
    echo -e "$green Installing and Configuring Redis. $reset"
    yum install redis supervisor -y  
    systemctl enable redis
    systemctl enable supervisord
cat <<  EOF > /etc/supervisord.d/faveo-worker.ini
[program:faveo-Horizon]
process_name=%(program_name)s
command=php /var/www/faveo/artisan horizon
autostart=true
autorestart=true
user=apache
redirect_stderr=true
stdout_logfile=/var/www/faveo/storage/logs/horizon-worker.log
EOF
systemctl restart supervisord
if [[ $? != 0 ]]; then
    echo -e "\n";
    echo -e "$red Something went wrong. Configuring Redis and Supervisor. $reset"
    echo -e "$red Rolling Back..... $reset"
    rollback
    echo -e "\n";
else
    echo -e "$green Redis & Supervisor configured. $reset"
    echo -e "$green Configuring Faveo Cronjob $reset"
    (sudo -u apache crontab -l 2>/dev/null; echo "* * * * * /usr/bin/php /var/www/faveo/artisan schedule:run 2>&1") | sudo -u www-data crontab -
    credentials "$1" "$2"
fi
}

extensions ()
{
    # Configuring Ioncube PHP Extension
    wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz   
    tar -zxf "$PWD"/ioncube_loaders_lin_x86-64.tar.gz
    \cp "$PWD"/ioncube/ioncube_loader_lin_8.1.so /usr/lib64/php/modules
    rm -rf "$PWD"/ioncube*
    sed -i '2 a zend_extension = "/usr/lib64/php/modules/ioncube_loader_lin_8.1.so"' /etc/php.ini
    #Configuring PDF Plugin
    yum install -y xorg-x11-fonts-75dpi xorg-x11-fonts-Type1 libpng libjpeg openssl icu libX11 libXext libXrender xorg-x11-fonts-Type1 xorg-x11-fonts-75dpi
    wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox-0.12.6.1-2.almalinux9.x86_64.rpm
    rpm -vh wkhtmltox-0.12.6.1-2.almalinux9.x86_64.rpm
    if [[ $? != 0 ]]; then
        echo -e "\n";
        echo -e "$red Something went wrong.Cronfiguring Ioncube and PDF Plugin. Contact Faveo Support for Troubleshooting. $reset"
    else
        rm -f $PWD/wkhtmltox-0.12.6.1-2.almalinux9.x86_64.rpm
    fi
}

dependencies ()
{   
    echo -e "$green Installing PHP and configuring necessary extensions. $reset"
    yum install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm
    yum module list php -y
    dnf module install php:remi-8.1 -y
    yum -y install php php-cli php-common php-fpm php-gd php-mbstring php-pecl-mcrypt php-mysqlnd php-odbc php-pdo php-xml  php-opcache php-imap php-bcmath php-ldap php-pecl-zip php-soap php-redis
    if [[ $? != 0 ]]; then
        echo -e "\n";
        echo -e "$red Something went wrong Configuring PHP. $reset"
        echo -e "$red Rolling Back..... $reset"
        rollback
        echo -e "\n";
    else
        sed -i 's/file_uploads =.*/file_uploads = On/g' /etc/php.ini
        sed -i 's/allow_url_fopen =.*/allow_url_fopen = On/g' /etc/php.ini
        sed -i 's/short_open_tag =.*/short_open_tag = On/g' /etc/php.ini
        sed -i 's/memory_limit =.*/memory_limit = 256MB/g' /etc/php.ini
        sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo = 0/g' /etc/php.ini
        sed -i 's/upload_max_filesize =.*/upload_max_filesize = 100M/g' /etc/php.ini
        sed -i 's/post_max_size =.*/post_max_size = 100M/g' /etc/php.ini
        sed -i 's/max_execution_time =.*/max_execution_time = 360/g' /etc/php.ini
        extensions
        if [[ $? != 0 ]]; then
                echo -e "\n";
                echo -e "$red Something went wrong.Cronfiguring PHP. $reset"
                echo -e "$red Rolling Back..... $reset"
                rollback
                echo -e "\n";
            else
                systemctl restart httpd
                echo -e "$green PHP is configured. $reset"
        fi            
    fi
    echo "$green Updating MariaDB-10.6 Repository.$reset"
        curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup   
        bash mariadb_repo_setup --mariadb-server-version=10.6        
        if [[ $? != 0 ]]; then
            echo -e "\n";
            echo -e "$red Something went wrong. Configuring MariaDB-10.6. $reset"
            echo -e "$red Rolling Back..... $reset"
            rollback
            echo -e "\n";
        else
            dnf install boost-program-options -y
            dnf module reset mariadb -y
            yum install MariaDB-server MariaDB-client MariaDB-backup -y
            systemctl enable --now mariadb
            systemctl start mariadb
            rm -f "$PWD"/mariadb_repo_setup 
            PASS=$(openssl rand -base64 12)
            mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE faveo;
CREATE USER 'faveo'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON faveo.* TO 'faveo'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

            if [[ $? != 0 ]]; then
                echo -e "\n";
                echo -e "$red Something went wrong.Creating Database User. $reset"
                echo -e "$red Rolling Back..... $reset"
                rollback
                echo -e "\n";
            else
                echo -e "$green MariaDB-10.6 is configured. $reset"
                redis  "$1" "$PASS"
            fi
    fi
}

faveo_configure ()
{
    #echo $1 $2 $3 
    curl https://billing.faveohelpdesk.com/download/faveo\?order_number\=$3\&serial_key\=$2 --output $PWD/faveo.zip 
    unzip $PWD/faveo.zip -d /var/www/faveo  >>/dev/null
    rm -f $PWD/faveo.zip
    mkdir /var/www/storage
    if [[ $? != 0 ]]; then
        echo -e "\n";
        echo -e "$red Something went wrong. Downloading Faveo Helpdesk package. $reset"
        echo -e "$red Rolling Back..... $reset"
        rollback
        echo -e "\n";
    else
        chown -R apache:apache /var/www
        dependencies "$1"
    fi   
}

certbot_apache ()
{
    #echo "$1" "$2" "$3" "$4" 
    echo -e "$green Obtaining Certificates for $1 from Letsencrypt. $reset"
    yum install python3-certbot-apache -y  
    certbot run -n --apache --agree-tos -d "$1"  -m  "$2" --redirect -q
    if [[ $? != 0 ]]; then
    echo -e "$red Failed to obtain SSL certificates $reset";
    rollback
    else 
    echo -e "$green Certificate Obtained. $reset"
    echo "45 2 * * 6 /etc/letsencrypt/ && ./certbot renew && /bin/systemctl restart httpd" | sudo tee /etc/cron.d/faveo-ssl
    echo "Certificates Obtained"
    faveo_configure "$1" "$3" "$4" 
    fi
}
self_signed_apache ()
{
    echo "$1" "$2" "$3" "$4" 
    echo -e "$green Generating Self Signed SSL certificates for $1. $reset"
    mkdir -p /etc/httpd/ssl
    openssl ecparam -out /etc/httpd/ssl/faveoroot.key -name prime256v1 -genkey
    openssl req -new -sha256 -key /etc/httpd/ssl/faveoroot.key -out /etc/httpd/ssl/faveoroot.csr -subj "/C=/ST=/L=/O=/OU=/CN="
    openssl x509 -req -sha256 -days 7300 -in /etc/httpd/ssl/faveoroot.csr -signkey /etc/httpd/ssl/faveoroot.key -out /etc/httpd/ssl/faveorootCA.crt
    openssl ecparam -out /etc/httpd/ssl/private.key -name prime256v1 -genkey
    openssl req -new -sha256 -key /etc/httpd/ssl/private.key -out /etc/httpd/ssl/faveolocal.csr -subj "/C=IN/ST=Karnataka/L=Bangalore/O=Ladybird Web Solutions Pvt Ltd/OU=Development Team/CN=$1"
    openssl x509 -req -in /etc/httpd/ssl/faveolocal.csr -CA  /etc/httpd/ssl/faveorootCA.crt -CAkey /etc/httpd/ssl/faveoroot.key -CAcreateserial -out /etc/httpd/ssl/faveolocal.crt -days 7300 -sha256
    openssl x509 -in /etc/httpd/ssl/faveolocal.crt -text -noout
    if [[ $? -eq 0 ]]; then
        echo -e "$green Certificates generated successfully for $1 $reset"
    else
        echo -e "$red Certification generation failed. $reset"
        rollback
    fi;

    cp /etc/httpd/ssl/faveorootCA.crt /etc/pki/ca-trust/source/anchors/
    update-ca-trust extract
cat <<  EOF > /etc/httpd/conf.d/faveo-ssl.conf
<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerName $1
    DocumentRoot /var/www/faveo/public
    <Directory /var/www/faveo>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/httpd/faveo-ssl-error.log
    CustomLog /var/log/httpd/faveo-ssl-access.log combined

SSLCertificateFile /etc/httpd/ssl/faveolocal.crt
SSLCertificateKeyFile /etc/httpd/ssl/private.key
</VirtualHost>
</IfModule>
EOF
    systemctl restart httpd
    test=$(curl -ks https://"$1"/test.html)
        if [[ "$test" == "Test" ]]; then
            echo -e "\n";
            echo -e "$green Self Signed SSL Configured for $1. $reset."
            faveo_configure "$1" "$3" "$4" 
        else
            echo -e "$red Self Signed SSL Configuration failed. $reset"
            rollback
        fi
}

paid_ssl_apache ()
{
    echo "$1" "$2" "$3" "$4" "$5" "$6"
    echo -e "$green Configuring SSL Certificates for $1. $reset"
cat <<  EOF > /etc/httpd/conf.d/faveo-ssl.conf
<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerName $1
    DocumentRoot /var/www/faveo/public
    <Directory /var/www/faveo>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/httpd/faveo-ssl-error.log
    CustomLog /var/log/httpd/faveo-ssl-access.log combined

SSLCertificateFile $5
SSLCertificateKeyFile $6
</VirtualHost>
</IfModule>
EOF
    systemctl restart httpd
    test=$(curl -ks https://"$1"/test.html)
        if [[ "$test" == "Test" ]]; then
            echo -e "\n";
            echo -e "$green SSL Configured for $1. $reset."
            faveo_configure "$1" "$3" "$4" 
        else
            echo -e "$red SSL Configuration failed. $reset"
            rollback
        fi
}

web_server_configuration ()
{
    echo "$1" #domain
    echo "$2" #email
    echo "$3" #license
    echo "$4" #orderno
    echo "$5" #web_server
    echo "$6" #ssl_type
    echo "$7" #certfile
    echo "$8" #keyfile

    if [[ "$5" == "apache" ]]; then
        echo -e "\n";
        echo -e "$green Installing Apache. $reset";
        echo -e "                       ";
        ### APACHE Installation
        dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
        yum install httpd mod_ssl wget zip unzip curl nano -y 
        systemctl enable httpd
        if [[ $? != 0 ]]; then
                echo -e "\n";
                echo -e "$red Apache Installation Failed. Check your Internet connection/Firewall/Domain Propagaion. $reset"
                echo -e "$red Rolling Back..... $reset"
                rollback
                echo -e "\n";
        fi
        ### Creating Temporary Index file for Testing
        mkdir -p /var/www/faveo/public
        echo "Test" > /var/www/faveo/public/test.html      
        ### Apache configuration.
        touch /etc/httpd/conf.d/faveo.conf
        echo "127.0.0.1      $1" >> /etc/hosts
    
cat <<  EOF > /etc/httpd/conf.d/faveo.conf
<VirtualHost *:80>
    ServerName $1
    DocumentRoot /var/www/faveo/public
    <Directory /var/www/faveo>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/httpd/faveo-error.log
    CustomLog /var/log/httpd/faveo-access.log combined
</VirtualHost>
EOF
    # Setting selinux to permissive mode.

    echo -e "$yellow Setting Selinux to permissive mode $reset";
    setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config

    #  Adding Rewrite engine to the apache config.
    echo "* * * * * www-data /usr/bin/php /var/www/faveo/artisan schedule:run 2>&1" | sudo tee /etc/cron.d/faveo

    ls /etc/httpd/modules | grep mod_rewrite 
    if [[ $? != 0 ]]; then
        echo -e "$red mod_rewrite is not in apache folder. $reset";
        rollback
    fi
    grep -i LoadModule /etc/httpd/conf/httpd.conf | grep rewrite
    if [[ $? != 0 ]]; then
    echo -e "LoadModule rewrite_module modules/mod_rewrite.so" >> /etc/httpd/conf/httpd.conf
    fi   
    sed -i '125s/AllowOverride.*/AllowOverride All/g' /etc/httpd/conf/httpd.conf
    sleep 0.5

    systemctl restart httpd
    test=$(curl -s http://"$1"/test.html)
        if [[ "$test" == "Test" ]]; then
        echo -e "\n";
        echo -e "$green Apache Configured. $reset"
            if [[ "$6" == "certbot" ]]; then
                certbot_apache "$1" "$2" "$3" "$4" 
            elif [[ "$6" == "self-signed" ]]; then
                self_signed_apache "$1" "$2" "$3" "$4" 
            elif [[ "$6" == "paid-ssl" ]]; then
                #echo "$1" "$2" "$3" "$4" "$7" "$8"
                paid_ssl_apache "$1" "$2" "$3" "$4" "$7" "$8"
            else
                echo -e "$red Something went wrong in SSL Selection. $reset"
                exit 1
            fi
        else
        echo -e "\n";
        echo -e "$red Something went wrong. Check your Internet connection/Firewall/Domain Propagaion. $reset"
        echo -e "$red Rolling Back..... $reset"
        rollback
        echo -e "\n";
        fi
    elif [[ "$1" == "nginx" ]]; then
        echo -e "\n";
        echo -e "$red Installing Nginx. $reset"
        ### NGINX Installation
        apt-get update  && apt-get upgrade -y  && apt-get install lsb-release \
        ca-certificates apt-transport-https software-properties-common gnupg2 wget zip unzip curl nano -y
        add-apt-repository --yes ppa:ondrej/nginx  
        apt-get update && apt install nginx -y  
        systemctl enable nginx && systemctl start nginx
        echo -e "                       "
            if [[ $? != 0 ]]; then
                echo -e "\n";
                echo -e "$red Something went wrong. Check your Internet connection/Firewall/Domain Propagaion. $reset"
                echo -e "$red Rolling Back..... $reset"
                rollback
                echo -e "\n";
            fi
    else
        echo -e "$red Something went wrong. Check your Internet connection. $reset"
        echo -e "$red Rolling Back....... $reset"
        rollback
    fi
            
}

# SSL Selection Prompt
ssl_selection ()
{
    echo -e "                                       "
    echo -e "$skyblue Select your preferred SSL certficates for Faveo Helpdesk.$reset";
    sleep 0.05
    echo -e "$green Press (A) for FreeSSL from Letsencrypt $reset";
    echo -e "$green Press (B) for Self-Signed SSL $reset";
    echo -e "$green Press (C) for Paid SSL $reset";
    read -p "$yellow Please select from available options [A,B,C]:" ssl
    if [[ "$ssl" =~ ^(A|a)$ ]]; then
        echo -e "$green You have selected Lets Encrypt Free SSL $reset";
        ssl_type=certbot
        web_server_configuration "$1" "$2" "$3" "$4" "$5" "$ssl_type"
    elif [[ "$ssl" =~ ^(B|b)$ ]]; then 
        echo -e "$green You have selected Self-Signed SSL $reset";
        ssl_type=self-signed
        web_server_configuration "$1" "$2" "$3" "$4" "$5" "$ssl_type"
    elif [[ "$ssl" =~ ^(C|c)$ ]]; then
        echo -e "$green You have selected Paid SSL $reset";
        ssl_files ()
        {
            read -p "$yellow Input the Absolute Path to Certificate file for $1 : $reset" certfile
            read -p "$yellow Input the Absolute Path to Certificate Key file for $1: $reset" keyfile
            ssl_type=paid-ssl
            #echo "$1" "$2" "$3" "$4" "$5" "$ssl_type" "$certfile" "$keyfile"
            web_server_configuration "$1" "$2" "$3" "$4" "$5" "$ssl_type" "$certfile" "$keyfile"
        }
        ssl_files "$1" "$2" "$3" "$4" "$5"
    else 
        echo -e "$red Please select a valid option: $reset";
        ssl_selection
    fi   
}

web_server_selection ()
{
    sleep 0.05
    echo -e "                                       "
    echo -e "$skyblue Select your preferred web server[APACHE or NGINX].$reset";
    sleep 0.05
    echo -e "$green (1) - Apache $reset";
    sleep 0.05
    echo -e "$green (2) - Nginx $reset";
    echo -e "                                 "
    read -p "$yellow Enter 1 for Apache, 2 for Nginx: $reset" webserver
            echo -e "                                 "
    if [[ "$webserver" == "1" ]]; then
        web_server="apache"
        echo -e "$green You have selected Apache Webserver $reset";
        ssl_selection "$1" "$2" "$3" "$4" "$web_server"
    elif [[ "$webserver" == "2" ]]; then
        web_server="nginx"
        echo -e "$green You have selected Nginx Webserver $reset";
        ssl_selection "$1" "$2" "$3" "$4" "$web_server"
    else 
        echo -e "$red Please select your preferred Web Server. $reset";
        web_server_selection
    fi
    sleep 0.05
}

attributes ()
{
    sleep 0.05
    echo -e "                                 "
    echo -e "$skyblue Enter the following details required by the Faveo Helpdesk Installaion. $reset";
    sleep 0.05
#Enter Domain:
    echo -e "                                 "
    read -p "$yellow Domain Name: $reset" DomainName
    sleep 0.05
#Enter Email:
    regex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"
    echo -e "                                 "
    read -p "$yellow Email:  $reset" Email
    if [[ $Email =~ $regex ]] ; then
        echo "                                "
        sleep 0.05
    else
        echo -e "$red Please Enter a Valid Email$reset"
        echo "                                "
        attributes
    fi

#Enter License code:
    echo "$yellow You can find the License and Order Number of your product by visiting https://billing.faveohelpdesk.com $reset";
    echo -e "                                   "
    read -n 16 -p "$yellow License Code:  $reset" LicenseCode
    echo -e "                                 "
    sleep 0.05
#Enter Order No:
    echo -e "                                 "
    read -n 8 -p "$yellow Order Number: $reset" OrderNumber
    sleep 0.05
#Confirming the entered details:
    echo -e "                                 "
    echo -e "\n";
    echo -e "Confirm the Entered details:\n";
    sleep 0.05
    echo -e "============================\n";
    sleep 0.05
    echo -e "                                 "
    echo "Domain Name    :$yellow $DomainName $reset";
    sleep 0.05
    echo -e "                                 "
    echo "Email          :$yellow $Email $reset";
    sleep 0.05
    echo -e "                                 "
    echo "License Code   :$yellow $LicenseCode $reset";
    sleep 0.05
    echo -e "                                 "
    echo "Order Number   :$yellow $OrderNumber $reset";
    echo -e "                                 "
    sleep 0.05
    
    read -p "Continue ($green y $reset/$red n $reset)?" REPLY
    if [[ ! $REPLY =~ ^(yes|y|Yes|YES|Y) ]]; then
        attributes
    else
        echo -e "                                 "
        web_server_selection "$DomainName" "$Email" "$LicenseCode" "$OrderNumber"
        echo -e "                                 "
    fi;    
}
attributes
}


# OS validation for Faveo Helpdesk Compatability.
os_check ()
{
# Ubuntu OS:

    echo -e " ";
    echo -e "$yellow Checking OS Compatability for Faveo Helpdesk.$reset";
    sleep 0.05
    if grep -qs "ubuntu" /etc/os-release; then
    	os="ubuntu"
    	os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
        Os_Version=$(hostnamectl | grep 'Operating System')
        if [[ "$os" == "ubuntu" && "$os_version" -lt 2004 ]]; then
            echo "[OS Detected] : $red $Os_Version $reset"
    	    echo "$red Ubuntu 20.04 or higher is required to use this installer. This version of Ubuntu is too old and unsupported.$reset";
            exit 1;
        else
            sleep 0.05
            echo -e "                                 "
            echo -e "[Detected OS] : $green $Os_Version $reset";
            sleep 0.05
            echo -e "                                 "
            echo -e "Faveo Helpdesk Compatability Check:$green [OK] $reset"
            debian_block
        fi

# Debian OS:

    elif [[ -e /etc/debian_version ]]; then
    	os="debian"
    	os_version=$(grep -oE '[0-9]+' /etc/debian_version | head -1)
        Os_Version=$(hostnamectl | grep 'Operating System')
        if [[ "$os" == "debian" && "$os_version" -lt 11 ]]; then
            echo "[OS Detected] : $red $Os_Version $reset"
    	    echo "$red Debian 11 or higher is required to use this installer. This version of Debian is Unsupported.$reset";
            exit 1;
        else
            sleep 0.05
            echo -e "                                 "
            echo -e "[Detected OS] : $green $Os_Version $reset";
            sleep 0.05
            echo -e "                                 "
            echo -e "Faveo Helpdesk Compatability Check:$green [OK] $reset"
            debian_block
        fi

# Rocky OS

    elif grep -qs "rocky" /etc/os-release; then
    	os="rocky"
    	os_version=$(grep -shoE '[0-9]+'  /etc/rocky-release | head -1)
    	group_name="nobody"
        Os_Version=$(hostnamectl | grep 'Operating System')
    	group_name="nogroup"
        sleep 1
        echo -e "                                 "
        echo -e "[OS Detected] : $green $Os_Version $reset";
        sleep 1 
        echo -e "                                 "
        echo -e "Supported OS Version [CHECK :$green OK $reset]"
        redhat_block

# Redhat OS

    elif grep -qs "red" /etc/os-release; then
    	os="redhat"
    	os_version=$(grep -shoE '[0-9]+'  /etc/redhat-release | head -1)
    	group_name="nobody"
        Os_Version=$(hostnamectl | grep 'Operating System')
    	group_name="nogroup"
        sleep 1
        echo -e "                                 "
        echo -e "[OS Detected] : $green $Os_Version $reset";
        sleep 1
        echo -e "                                 "
        echo -e "Supported OS Version [CHECK :$green OK $reset]"
        redhat_block

    # If the required OS and version is not detected the below response will be passed to the user.

    else
    	echo "$red This installer seems to be running on an unsupported distribution. Supported distros are Ubuntu, Debian, Rocky Linux, CentOS and Fedora.$reset";
    	exit
    fi
}
sleep 0.05
os_check

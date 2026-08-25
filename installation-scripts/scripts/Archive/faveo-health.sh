#!/bin/bash
##---------- Author : Vishwas S--------------------------------------------------------------##
##---------- Email : vishwas.s@ladybirdweb.com ----------------------------------------------##
##---------- Github page : https://github.com/ladybirdweb/faveo-server-images/ --------------##
##---------- Purpose : To quickly check and report health status in a linux system.----------##
##---------- Tested on : RHEL9/8/7, Rocky 9/8, Ubuntu22/20/18, CentOS 9 Stream, Debian 11----## 
##---------- Updated version : v1.0 (Updated on 2nd Dec 2022) -------------------------------##
##-----NOTE: This script requires root privileges, otherwise one could run the script -------##
##---------- as a sudo user who got root privileges. ----------------------------------------##
##----USAGE: "sudo /bin/bash faveo-health.sh" -----------------------------------------------##



# Colour variables for the script.

red=$(tput setaf 1)

green=$(tput setaf 2)

yellow=$(tput setaf 11)

skyblue=$(tput setaf 14)

reset=$(tput sgr0)

echo -e " ";
if [[ $(id -u) -ne 0 ]]; then
   echo -e "$red This script must be run as root or sudo user $reset";
   exit 1
fi
echo -e "$skyblue Faveo Helpdesk HEALTH CHECK v1.0 $reset"
#------variables used------#
S="************************************"
D="-------------------------------------"
COLOR="y"

MOUNT=$(mount|egrep -iw "ext4|ext3|xfs|gfs|gfs2|btrfs"|grep -v "loop"|sort -u -t' ' -k1,2)
FS_USAGE=$(df -PThl -x tmpfs -x iso9660 -x devtmpfs -x squashfs|awk '!seen[$1]++'|sort -k6n|tail -n +2)
IUSAGE=$(df -iPThl -x tmpfs -x iso9660 -x devtmpfs -x squashfs|awk '!seen[$1]++'|sort -k6n|tail -n +2)

if [ $COLOR == y ]; then
{
 GCOLOR="\e[47;32m ------ OK/HEALTHY \e[0m"
 WCOLOR="\e[43;31m ------ WARNING \e[0m"
 CCOLOR="\e[47;31m ------ CRITICAL \e[0m"
}
else
{
 GCOLOR=" ------ OK/HEALTHY "
 WCOLOR=" ------ WARNING "
 CCOLOR=" ------ CRITICAL "
}
fi

#--------Print Operating System Details--------#
echo -e "$skyblue Checking Operating System Details $reset"
echo -e "$D"
echo -en "$skyblue \n Operating System :             $reset"
[ -f /etc/os-release ] && echo   $(egrep -w "NAME|VERSION" /etc/os-release|awk -F= '{ print $2 }'|sed 's/"//g') || cat /etc/system-release 

echo -e "$skyblue Kernel Version :               $reset"$(uname -r) 
# printf "OS Architecture :"$(arch | grep x86_64 &> /dev/null) && printf " 64 Bit OS\n"  || printf " 32 Bit OS\n"

#--------Print system uptime-------#
UPTIME=$(uptime)
echo -en "$skyblue System Uptime :                $reset"
echo $skyblue $UPTIME|grep day $reset &> /dev/null
if [ $? != 0 ]; then
  echo  $UPTIME|grep -w min &> /dev/null && echo -en $(echo $UPTIME|awk '{print $2" by "$3}'|sed -e 's/,.*//g') minutes \
   || echo -en $(echo $UPTIME|awk '{print $2" by "$3" "$4}'|sed -e 's/,.*//g') hours 
else
  echo -en $(echo $UPTIME|awk '{print $2" by "$3" "$4" "$5" hours"}'|sed -e 's/,//g')
fi
echo -e "\n$skyblue Current System Date & Time :   $reset"$(date +%c) 

#--------Check disk usage on all mounted file systems--------#
echo -e "\n\n$skyblue Checking CPU and RAM details:$reset"
echo -e "$D$D"
echo -e "$skyblue CPU Cores: $reset $(grep -c ^processor /proc/cpuinfo)"
echo -e "$skyblue RAM Usage: $reset"
echo -e "$(free -h)"


#--------Check disk usage on all mounted file systems--------#
echo -e "\n\n$skyblue Checking For Disk Usage On Mounted File System[s] $reset"
echo -e "$D$D"
echo -e "($green 0-85% = OK/HEALTHY$reset,$yellow  85-95% = WARNING $reset,$red  95-100% = CRITICAL $reset)"
echo -e "$D$D"
echo -e "$skyblue Mounted File System[s] Utilization (Percentage Used):\n $reset"

COL1=$(echo "$FS_USAGE"|awk '{print $1 " "$7}')
COL2=$(echo "$FS_USAGE"|awk '{print $6}'|sed -e 's/%//g')

for i in $(echo "$COL2"); do
{
  if [ $i -ge 95 ]; then
    COL3="$(echo -e $i"% $CCOLOR\n$COL3")"
  elif [[ $i -ge 85 && $i -lt 95 ]]; then
    COL3="$(echo -e $i"% $WCOLOR\n$COL3")"
  else
    COL3="$(echo -e $i"% $GCOLOR\n$COL3")"
  fi
}
done
COL3=$(echo "$COL3"|sort -k1n)
paste  <(echo "$COL1") <(echo "$COL3") -d' '|column -t

#--------Check for any zombie processes--------#
echo -e "\n$skyblue Checking For Zombie Processes$reset"
echo -e "$D"
ps -eo stat|grep -w Z 1>&2 > /dev/null
if [ $? == 0 ]; then
  echo -e "$red Number of zombie process on the system are :" $(ps -eo stat|grep -w Z|wc -l) $reset
  echo -e "\n$red Details of each zombie processes found   $reset"
  echo -e "  $D"
  ZPROC=$(ps -eo stat,pid|grep -w Z|awk '{print $2}')
  for i in $(echo "$ZPROC"); do
      ps -o pid,ppid,user,stat,args -p $i
  done
else
 echo -e "$green No zombie processes found on the system.$reset"
fi

#--------Check for load average (current data)--------#
echo -e "\n$skyblue Checking For Load Average $reset"
echo -e "$D"
echo -e "$skyblue Current Load Average : $(uptime|grep -o "load average.*"|awk '{print $3" " $4" " $5}') $reset"

#--------Print top 5 Memory & CPU consumed process threads---------#
#--------excludes current running program which is hwlist----------#
echo -e "\n$skyblue Top 5 Memory Resource Hog Processes $reset"
echo -e "$D$D"
ps -eo pmem,pid,ppid,user,stat,args --sort=-pmem|grep -v $$|head -6 #|sed 's/$/\n/'

echo -e "\n$skyblue Top 5 CPU Resource Hog Processes $reset"
echo -e "$D$D"
ps -eo pcpu,pid,ppid,user,stat,args --sort=-pcpu|grep -v $$|head -6 #|sed 's/$/\n/'


deb ()
{

    if [[ $(systemctl is-active apache2) == "active" ]]; then
        echo -e "$green Apache is Running $reset"
    elif [[ $(systemctl is-active nginx) == "active" ]]; then
        echo -e "$green Nginx is Running $reset"
    else
        echo -e "$red Web Server is not Running $reset"
    fi

    if [[ $(systemctl is-active mariadb) == "active" ]]; then
        echo -e "$green MariaDB Database server is Running $reset"
        echo -e "$skyblue $(mysql -V) $reset"
    elif [[ $(systemctl is-active mysql) == "active" ]]; then
        echo -e "$green MySQL Database is Running $reset"
        echo -e "$skyblue $(mysql -V) $reset"
    else
        echo -e "$red Database is not Running $reset"
    fi

    if [[ $(systemctl is-active redis) == "active" ]]; then
        echo -e "$green Redis is Running $reset"
    else
        echo -e "$red Redis is not Running $reset"
    fi

    if [[ $(systemctl is-active supervisor) == "active" ]]; then
        echo -e "$green Supervisor is Running $reset"
        echo -e "\n\n$skyblue Checking Supervisor Jobs status$reset"
        echo -e "$D"
        echo -e "$(supervisorctl status)"
    else
        echo -e "$red Supervisor is not Running $reset"
    fi
}

rpm ()
{

    if [[ $(systemctl is-active httpd) == "active" ]]; then
        echo -e "$green Apache Web Server is Running $reset"
    elif [[ $(systemctl is-active nginx) == "active" ]]; then
        echo -e "$green Nginx Web Server is Running $reset"
    else
        echo -e "$red Web Server is not Running $reset"
    fi
    
    if [[ $(systemctl is-active mariadb) == "active" ]]; then
        echo -e "$green MariaDB Database server is Running $reset"
        echo -e "$skyblue $(mysql -V) $reset"
    elif [[ $(systemctl is-active mysqld) == "active" ]]; then
        echo -e "$green MySQL Database is Running $reset"
        echo -e "$skyblue $(mysql -V) $reset"
    else
        echo -e "$red Database is not Running $reset"
    fi
    
    if [[ $(systemctl is-active redis) == "active" ]]; then
        echo -e "$green Redis is Running $reset"
    else
        echo -e "$red Redis is not Running $reset"
    fi
    
    if [[ $(systemctl is-active supervisor) == "active" ]]; then
        echo -e "$green Supervisor is Running $reset"
        echo -e "\n\n$skyblue Checking Supervisor Jobs status$reset"
        echo -e "$D"
        echo -e "$(supervisorctl status)"
    else
        echo -e "$red Supervisor is not Running $reset"
    fi
}

echo -e " ";
echo -e "$skyblue Checking Daemon services for Faveo Helpdesk $reset";
echo -e "$D"
sleep 0.5
#if grep -qs "ubuntu" /etc/os-release; then
if [[ $(cat /etc/issue | awk '{print $1}') == "Ubuntu" || $(cat /etc/issue | awk '{print $1}') == "Debian" ]]; then
    sleep 0.5
    deb
elif [[ -e /etc/redhat-release || -e /etc/rocky-release ]]; then
    sleep 0.5
    rpm
else # If the required OS and version is not detected the below response will be passed to the user.
	echo "$red This installer seems to be running on an unsupported distribution. Supported distros are Ubuntu, Debian, Rocky Linux, CentOS and Fedora.$reset";
	exit
fi






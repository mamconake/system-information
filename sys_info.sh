#!/bin/bash
# Define colors
white="\033[1;23m"
cyan="\033[1;36m"
reset="\033[0m"

# System information
echo " "
echo -e "${white}------------------------------------------------------------------System Information--------------------------------------------------------------${reset}"
echo -e "${cyan}Hostname:${reset}\t\t$(hostname -f)"
echo -e "${cyan}IP Address:${reset}\t\t$(hostname -I)"
echo -e "${cyan}Uptime:${reset}\t\t$(uptime | awk '{print $3,$4}' | sed 's/,//')"
echo -e "${cyan}Cores:${reset}\t\t$(grep -c ^processor /proc/cpuinfo)"
echo -e "${cyan}CPUs:${reset}\t\t$(lscpu | grep "^CPU(s):" | awk '{print $2}')"
echo -e "${cyan}Memory:${reset}\t\t$(free -h | awk '/^Mem:/{print $2}')"
echo -e "${cyan}Disk Space:${reset}"
df -h | grep '^/dev/'
echo -e "${cyan}Model Name:${reset}\t\t$(awk -F':' '/^model name/ {print $2}' /proc/cpuinfo | uniq | sed -e 's/^[ \t]*//')"
echo -e "${cyan}Product Name:${reset}\t\t$(cat /sys/class/dmi/id/product_name)"
echo -e "${cyan}Serial Number:${reset}\t\t$(cat /sys/class/dmi/id/product_serial)"
echo -e "${cyan}BIOS Version:${reset}\t\t$(dmidecode -s bios-version)"
echo -e "${cyan}BIOS Release Date:${reset}\t\t$(dmidecode -s bios-release-date)"
echo -e "${cyan}Kernel Version:${reset}\t\t$(uname -r)"
echo -e "${cyan}Redhat Release:${reset}\t\t$(cat /etc/redhat-release)"
echo -e "${cyan}RPM Version:${reset}\t\t$(rpm --version)"
echo -e "${cyan}idRAC IP:${reset}\t\t$(ipmitool lan print | grep 'IP Address   ' | awk '{print $4}')"
echo " "

# Resource usage
echo -e "${white}------------------------------------------------------------------Resource Usage--------------------------------------------------------------${reset}"
echo -e "${cyan}CPU Usage:${reset}\t\t$(awk -v RS="" '{u1=$2+$4; t1=$2+$4+$5; getline; u2=$2+$4; t2=$2+$4+$5; print (u2-u1) * 100 / (t2-t1) "%"}' <(grep 'cpu ' /proc/stat) <(sleep 1; grep 'cpu ' /proc/stat))"
echo -e "${cyan}Memory Usage:${reset}\t\t$(free | awk '/Mem/{printf("%.2f%"), $3/$2*100}')"
echo -e "${cyan}Swap Usage:${reset}\t\t$(free | awk '/Swap/{printf("%.2f%"), $3/$2*100}')"

# Top processes by CPU and memory usage
echo -e "${cyan}Top 5 Processes by CPU Usage:${reset}"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
echo -e "${cyan}Top 5 Processes by Memory Usage:${reset}"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6

# Disk I/O
echo -e "${cyan}Disk I/O:${reset}"
iostat -x | head -n 10

# Network usage
echo -e "${cyan}Network Usage:${reset}"
netstat -i | grep -vE '^Kernel|Iface|lo'

# Active network connections
echo -e "${cyan}Active Network Connections:${reset}"
netstat -ant | grep 'ESTABLISHED'

# Swap activity
echo -e "${cyan}Swap Activity:${reset}"
vmstat 1 5

# Zombie processes
echo -e "${cyan}Zombie Processes:${reset}\t\t"
ps aux | awk '{ if ($8 == "Z") print $0; }'

# System temperature (make sure the 'sensors' command is installed)
if command -v sensors > /dev/null; then
    echo -e "${cyan}System Temperature:${reset}\t\t$(sensors)"
else
    echo -e "${cyan}System Temperature:${reset}\t\t'sensors' command not found"
fi

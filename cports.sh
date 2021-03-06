#!/bin/bash


if [ -z $1 ];then
echo "\n\tUsage: ./cports.sh [nmap_file] [OPTIONAL_export_file]"
exit 1
else

ip="$(/usr/bin/cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u)"
ports="$(/usr/bin/cat $1 | grep -oP '\d{1,5}/open' | awk '{print$1}' FS='/' | xargs | tr ' ' ',')"

echo $ports | tr -d '\n' | xclip -sel clip

echo "\n\tIP_Address : $ip"
echo "\tOpen_ports : $ports"
echo "\n\tPorts copied to clipboard.\n\n"
fi
if [ ! -z $2 ]; then
echo "\tExporting to $2..."

echo "\tIP_Address : $ip" >> $2
echo "\tOpen_ports : $ports" >> $2

fi

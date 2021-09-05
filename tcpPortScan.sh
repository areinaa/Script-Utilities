#!/bin/bash


if [ -z $1 ];then
echo -e "\n\tUsage: ./tcpPortScan.sh [ip_address]"
exit 1

else

echo -e "\n\t Fast tcp scan\n\n\t Ip_address : $1"
echo -e -n "\n\t Open ports discovered : "
for i in $(seq 1 65535);
do

timeout 1 bash -c "echo ' ' > /dev/tcp/$1/$i" 2>/dev/null && echo -n "$i," && echo -n "$i," >> openports.tmp


done; wait

cat openports.tmp | tr -d '\n' | xclip -sel clip
echo -e "\n\n\t 65535 ports scanned. Open ports copied to clipboard."

rm openports.tmp

fi

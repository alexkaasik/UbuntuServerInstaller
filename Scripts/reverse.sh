ip=$( echo $1 | sed 's/\./ /g')
read -ra ipaddres <<< "$ip"

echo "$ipaddres[2].$ipaddres[1].$ipaddres[0]"
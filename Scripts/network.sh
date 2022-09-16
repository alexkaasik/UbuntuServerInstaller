#!/bin/bash

bit=$1

ip=$( echo $2 | sed 's/\./ /g')
read -ra ipaddres <<< "$ip"

octet1=${ipaddres[0]}
octet2=${ipaddres[1]}
octet3=${ipaddres[2]}
octet4=${ipaddres[3]}
octet=0

if [[ $bit -ge 8 ]]; then
	#echo "first octet filled"
	octet=$((octet+1))
	if [[ $bit -ge 16 ]]; then
		#echo "second octet filled"
		octet=$((octet+1))
		if [[ $bit -ge 24 ]]; then
			#echo "third octet filled"
			octet=$((octet+1))
			if [[ $bit -eq 32 ]]; then
				#echo "forth octet filled"
				octet=$((octet+=1))
			fi
		fi
	fi
fi	

function minhost() {
	mask=$1
	byte=$(( (($octet + 1)*8) - $bit))
	b=0
	while true; do
		if [[ $mask -ge $(( (2**$byte)*$b )) &&  $mask -lt $(( ((2**($byte)*$b)+( 2**($byte))) )) ]]; then
			final_octet=$(( (2**$byte)*$b ))
			break
		fi
		b=$(( $b + 1 ))
	done
}

case $octet in
	0)
		minhost $octet1
		octet1=$final_octet
		octet2=0
		octet3=0
		octet4=1
		;;
	1)
		minhost $octet2
		octet2=$final_octet
		octet3=0
		octet4=1
		;;
	2)
		minhost $octet3
		octet3=$final_octet
		octet4=1
		;;
	3)
		minhost $octet4
		octet4=$final_octet
		;;
esac

echo "$octet1.$octet2.$octet3.$octet4"
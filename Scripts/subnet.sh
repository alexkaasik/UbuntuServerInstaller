#!/bin/bash

bit=$1

octet=0
octet1=0
octet2=0
octet3=0
octet4=0
if [[ $bit -ge 8 ]]; then
	#echo "first octet filled"
	octet=$((octet+1))
	octet1=255
	if [[ $bit -ge 16 ]]; then
		#echo "second octet filled"
		octet=$((octet+1))
		octet2=255
		if [[ $bit -ge 24 ]]; then
			#echo "third octet filled"
			octet=$((octet+1))
			octet3=255
			if [[ $bit -eq 32 ]]; then
				#echo "forth octet filled"
				octet=$((octet+=1))
				octet4=255
			fi
		fi
	fi
fi	

final_octet=$(( 255-(2**(((octet+1)*8)-bit)-1) ))

case $octet in
	0)
		octet1=$final_octet;;
	1)
		octet2=$final_octet;;
	2)
		octet3=$final_octet;;
	3)
		octet4=$final_octet;;
esac
answer="$octet1.$octet2.$octet3.$octet4"

echo $answer

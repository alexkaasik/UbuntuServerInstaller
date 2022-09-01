#!/bin/sh

#read -r -p "A user sudo password need to be enter:" password

read service
read -ra test <<< "$service"
Arr=('0')
#Remove_All=( ${test[@]/all/})
#echo ${Remove_All[@]}

for i in "${test[@]}"; do
    if [[ "${test[i]}" == "all" ]]; then
        Arr=('0' '1' '2' '3' '4' '5' '6' '7' '8' '9')
        Remove_All=( ${test[@]/all/} )
        for i in "${Remove_All[@]}"; do
            Arr=( ${Arr[@]/$i/} )
        done
        break
    else
        Arr=( ${test[@]} )
    fi
done

for r in "${Arr[@]}"; do
        printf "$r\n"
done
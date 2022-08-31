#!/bin/sh

#read -r -p "A user sudo password need to be enter:" password

read service
read -ra test <<< "$service"

#Remove_All=( ${test[@]/all/})
#echo ${Remove_All[@]}

for i in "${test[@]}"; do
    if [[ "${test[i]}" == "all" ]]; then
        Arr=('0' '1' '2' '3' '4' '5' '6' '7' '8' '9')
        Remove_All=( ${test[@]/all/} )
        echo ${Remove_All[@]}
        for i in "${Remove_All[@]}"; do
            echo $i
            Arr=( ${Arr[@]/$i/} )
        done
    fi
done

echo ${Arr[@]}

#echo ${Remove_Arr[@]}
#
#if [ $service == 'all' ]; then
#    Arr=('0' '1' '2' '3' '4' '5' '-6' '7' '8' '9')
#else
#    read -ra Arr <<< "$service"
#fi
#
#
#for i in "${Arr[@]}"; do
#   if [ $i < 0 ]; then
#        printf "$i\n"
#    fi
#done

for i in "${Arr[@]}"; do
        printf "$i\n"
done
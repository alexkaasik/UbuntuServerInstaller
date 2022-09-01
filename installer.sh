#!/bin/sh

#read -r -p "A user sudo password need to be enter:" password

read service
read -ra service <<< "$service"

for i in "${service[@]}"; do
    if [[ "${service[i]}" == "all" ]]; then
        Arr=('0' '1' '2' '3' '4' '5' '6' '7' '8' '9')
        Remove_All=( ${service[*]/all/} )
        for i in "${Remove_All[@]}"; do
            Arr=( ${Arr[@]/$i/} )
        done
        break
    else
        Arr=( ${service[@]} )
    fi
done

for i in "${Arr[@]}"; do
    case $i in
        0)
            echo "$i is nat";;
        1)
            echo "$i is dhcp service";;
        2)
            echo "$i is dns service";;
        3)
            echo "$i is ntp service";;
        4)
            echo "$i is samba service";;
        5)
            echo "$i is iptables service";;
        6)
            echo "$i is apache service";;
        7)
            echo "$i is ngix service";;
        8)
            echo "$i is active directory service";;
        9)
            echo "$i is raid service";;
        *)
            echo "$i no service is available";;
    esac
done
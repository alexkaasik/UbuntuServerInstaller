#!/bin/sh

#read -r -s -p "A user sudo password need to be enter:" password

column -t -s "," column.txt

echo "all option add all services, but adding a number before/after all will not include that service"

read service
read -ra service <<< "$service"

dhcp_call(){
    sudo -S <<< $password apt install isc-dhcp-server
    sudo -S <<< $password sed -i 's/INTERFACESv4=""/INTERFACESv4="enp0s8/' /etc/default/ isc-dhcp-server
    sudo -S <<< $password mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.backup
    sudo -S <<< $password cp dhcp.txt /etc/dhcp/dhcpd.conf

    sudo -S <<< $password systemctl restart isc-dhcp-server
    sudo -S <<< $password systemctl status isc-dhcp-server
}

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
            (dhcp_call1);;
        *)
            echo "$i no service is available";;
    esac
done
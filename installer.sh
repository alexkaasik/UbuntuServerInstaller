#!/bin/bash

#read -r -s -p "A user sudo password need to be enter:" password

column -t -s "," column.txt

echo "all option add all services, but adding a number before/after all will not include that service"

read service
read -ra service <<< "$service"

function dhcp_call(){
    sudo -S <<< $password apt install -y isc-dhcp-server
    sudo -S <<< $password sed -i 's/INTERFACESv4=""/INTERFACESv4="enp0s8"/' /etc/default/isc-dhcp-server
    sudo -S <<< $password mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.backup
    sudo -S <<< $password cp DHCP/dhcp.txt /etc/dhcp/dhcpd.conf

    sudo -S <<< $password systemctl restart isc-dhcp-server
    sudo -S <<< $password systemctl status isc-dhcp-server
}
function samba_call(){
    sudo -S <<< $password apt install -y samba
    sudo -S <<< $password mv /etc/samba/smb.conf /etc/samba/smb.conf
    sudo -S <<< $password cp SAMBA/samba.txt /etc/samba/smb.conf
    sudo -S <<< $password Systemctl restart smbd
    sudo -S <<< $password Systemctl enable smbd
    sudo -S <<< $password Systemctl status smbd
}
function dns_call(){
    sudo -S <<< $password apt install -y bind9 dnsutils
    sudo -S <<< $password enable bind9
    sudo -S <<< $password start bind9

    sudo -S <<< $password dns_option.txt > /etc/bind/named.conf.option
    
    sudo -S <<< $password DNS/dns.localrevtxt >> /etc/bind/named.conf.local
    sudo -S <<< $password DNS/dns.localfor.txt >> /etc/bind/named.conf.local
    sudo -S <<< $password DNS/dns.option.txt > /etc/bind/named.conf.option

    sudo -S <<< $password mkdir -p /etc/bind/dns-zones 
    sudo -S <<< $password cp DNS/forward.txt /etc/bind/dns-zones/kaasik.loc
    sudo -S <<< $password cp DNS/reverse.txt /etc/bind/dns-zones/12.168.192-rev

    sudo -S <<< $password systemctl restart bind9
    sudo -S <<< $password systemctl status bind9 
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
            (dhcp_call);;
        1)
            (samba_call);;
        2)
            (dns_call);;
        *)
            echo "$i no service is available";;
    esac
done
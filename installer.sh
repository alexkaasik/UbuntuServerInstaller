#!/bin/bash

read -r -s -p "A user sudo password need to be enter:" password

column -t -s "," column.txt

echo "all option add all services, but adding a number before/after all will not include that service"
read -p "pick a service" service
read -ra service <<< "$service"

read -p "ip and subnet: " network 
network=$( echo $network | sed 's/\// /g')
read -ra network <<< "$network"

function dhcp_call(){
    sudo -S <<< $password apt install -y isc-dhcp-server
    
    echo $( ip addr )
    read -p "pick a interface: " interface

    sudo -S <<< $password sed -i "s/INTERFACESv4=""/INTERFACESv4="$interface"/" /etc/default/isc-dhcp-server
    sudo -S <<< $password mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.backup
    sudo -S <<< $password cp DHCP/dhcp.txt /etc/dhcp/dhcpd.conf

    sudo -S <<< $password sed -i 's/subnet!/${network[0]}/g' /etc/dhcp/dhcpd.conf
    netmask=$( bash Scripts/subnet.sh ${network[1]})
    sudo -S <<< $password sed -i 's/netmask!/$netmask/g' /etc/dhcp/dhcpd.conf

    sudo -S <<< $password systemctl restart isc-dhcp-server
    sudo -S <<< $password systemctl status isc-dhcp-server
}
function samba_call(){
    sudo -S <<< $password apt install -y samba
    sudo -S <<< $password mv /etc/samba/smb.conf /etc/samba/smb.conf.backup
    sudo -S <<< $password cp SAMBA/samba.txt /etc/samba/smb.conf

    read -p "how many smb folder do you want?: " smb_folder

    for (( i= 0; i < $smb_folder; i++ )); do
        smb_txt="Should this smb folder be"
        yes_or_no="yes or no"
        cat SAMBA/smb.txt | sudo tee -a /etc/samba/smb.conf
        read -p "Enter a name for a network drive: " net
        sudo -S <<< $password sed -i "s/test!/$net/g"  /etc/samba/smb.conf
        read -p "Give a path to your folder: /mnt/" path
        sudo -S <<< $password sed -i "s/path!/$path/g"  /etc/samba/smb.conf
        read -p "$smb_txt browsable $yes_or_no: " browser
        sudo -S <<< $password sed -i "s/brow!/$browser/g"  /etc/samba/smb.conf
        read -p "$smb_txt writeable $yes_or_no: " write 
        sudo -S <<< $password sed -i "s/writ!/$write/g"  /etc/samba/smb.conf
        read -p "$smb_txt guest to use this folder $yes_or_no: " guest
        sudo -S <<< $password sed -i "s/guest!/$guest/g" /etc/samba/smb.conf
        read -p "$smb_txt read only $yes_or_no: " red
        sudo -S <<< $password sed -i "s/read!/$red/g"  /etc/samba/smb.conf
        read -p "$smb_txt who should have access adding if name has @ make it a group or without makes a user: " who
        sudo -S <<< $password sed -i "s/who!/$who/g"   /etc/samba/smb.conf
    done

    sudo -S <<< $password Systemctl restart smbd
    sudo -S <<< $password Systemctl enable smbd
    sudo -S <<< $password Systemctl status smbd
}
function dns_call(){
    sudo -S <<< $password apt install -y bind9 dnsutils
    sudo -S <<< $password systemctl enable bind9
    sudo -S <<< $password systemctl start bind9

    read -p "Inter a domain name: " domain_name
    read -ra domain_name <<< "$domain_name"

    cat DNS/dns.option.txt | sudo tee /etc/bind/named.conf.option
    cat DNS/dns.localrev.txt | sudo tee -a /etc/bind/named.conf.local
    sudo -S <<< $password mkdir -p /etc/bind/dns-zones 

    for i in "${domain_name[@]}"; do
        cat DNS/dns.localfor.txt | sudo tee -a /etc/bind/named.conf.local
        sudo -S <<< $password sed -i "s/@.loc/$i/g" /etc/bind/named.conf.local

        sudo -S <<< $password cp DNS/forward.txt /etc/bind/dns-zones/$i
        sudo -S <<< $password sed -i "s/@.loc/$i/g" /etc/bind/dns-zones/$i

        sudo -S <<< $password cp DNS/reverse.txt /etc/bind/dns-zones/12.168.192-rev
        sudo -S <<< $password sed -i "s/@.loc/${domain_name[0]}/g" /etc/bind/dns-zones/12.168.192-rev
    done

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
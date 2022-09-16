#!/bin/bash

read -r -s -p "A user sudo password need to be enter:" password
echo ""
column -t -s "," column.txt

echo "all option add all services, but adding a number before/after all will not include that service"
read -p "pick a service: " -ra service

# Function Installing DHCP
function dhcp_call(){
    sudo -S <<< $password apt install -y isc-dhcp-server

    sudo -S <<< $password systemctl start isc-dhcp-server
    sudo -S <<< $password systemctl enable isc-dhcp-server

    clear

    echo "$( ip addr )"
    read -p "pick a interface: " interface

    read -p "ip and subnet: " network 
    network=$( echo $network | sed 's/\// /g')
    read -ra network <<< "$network"

    #sudo -S <<< $password sed -i s/INTERFACESv4=\"\"/INTERFACESv4="$interface"/g /etc/default/isc-dhcp-server
    sudo -S <<< $password sed -i s/\"\"/\"$interface\"/g /etc/default/isc-dhcp-server
    sudo -S <<< $password mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.backup
    sudo -S <<< $password cp DHCP/dhcp.txt /etc/dhcp/dhcpd.conf

    network_host=$( bash Scripts/network.sh ${network[1]} ${network[0]})
    sudo -S <<< $password sed -i s/subnet!/$network_host/g /etc/dhcp/dhcpd.conf

    netmask=$( bash Scripts/subnet.sh ${network[1]})
    sudo -S <<< $password sed -i s/netmask!/$netmask/g /etc/dhcp/dhcpd.conf

    maxhost=$( bash Scripts/maxhost.sh ${network[1]} ${network[0]} )
    sudo -S <<< $password sed -i s/maxhost!/$maxhost/g /etc/dhcp/dhcpd.conf

    minhost=$( bash Scripts/minhost.sh ${network[1]} ${network[0]} )
    sudo -S <<< $password sed -i s/minhost!/$minhost/g /etc/dhcp/dhcpd.conf

    broadcast_address=$( bash Scripts/broadcast.sh ${network[1]} ${network[0]} )
    sudo -S <<< $password sed -i s/broadcast-address!/$broadcast_address/g /etc/dhcp/dhcpd.conf

    read -p "Inter a default getway a for DHCP: " router_ip
    sudo -S <<< $password sed -i s/router_ip!/$router_ip/g /etc/dhcp/dhcpd.conf  

    read -p "Inter a DNS servers get a for DHCP: " dns_ip
    sudo -S <<< $password sed -i s/dns_ip!/$dns_ip/g /etc/dhcp/dhcpd.conf 
  
    read -p "Inter a domain name for for DHCP: " domain_name
    sudo -S <<< $password sed -i s/domain_name!/$domain_name/g /etc/dhcp/dhcpd.conf 
  
    sudo -S <<< $password systemctl restart isc-dhcp-server
    sudo -S <<< $password systemctl status isc-dhcp-server
    sleep 5
    clear
}
# Function Installing Samba
function samba_call(){
    sudo -S <<< $password apt install -y samba
    sudo -S <<< $password mv /etc/samba/smb.conf /etc/samba/smb.conf.backup
    sudo -S <<< $password cp SAMBA/samba.txt /etc/samba/smb.conf

    clear

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
        clear
    done

    sudo -S <<< $password systemctl restart smbd
    sudo -S <<< $password systemctl enable smbd
    sudo -S <<< $password systemctl status smbd

    sleep 5
    clear
}
# Function Installing DNS 
function dns_call(){
    sudo -S <<< $password apt install -y bind9 dnsutils
    sudo -S <<< $password systemctl enable bind9
    sudo -S <<< $password systemctl start bind9

    clear

    read -p "Inter a domain name: " -ra domain_name

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
# Function Installing Web-server like apache or nginx
function web_call(){
    read -p "pick one apache or nginx: " web_server

    read -p "Inter a domain name: " -ra domain_name
    
    for i in "${domain_name[@]}"; do    
        sudo -S <<< $password mkdir -p /var/www/$i/
        sudo -S <<< $password cp WEB/index.html /var/www/$i/index.html
        sudo -S <<< $password sed -i s/site_name!/$i/g /var/www/$i/index.html
    done    
    if [ $web_server == "apache" ]; then
        sudo -S <<< $password apt install -y apache2

        for i in "${domain_name[@]}"; do
            sudo -S <<< $password cp WEB/apache.txt /etc/apache2/sites-available/$i.conf
            sudo -S <<< $password sed -i s/example!/$i/g /etc/apache2/sites-available/$i.conf 
            sudo -S <<< $password a2ensite $i.conf 
        done

        sudo -S <<< $password a2dissite 000-default.conf 
        sudo -S <<< $password systemctl restart apache2 
        sudo -S <<< $password systemctl status apache2

        sleep 5
        clear

    elif [ $web_server == "nginx" ]; then
        sudo -S <<< $password apt install -y nginx
        sudo -S <<< $password ufw app list
        sudo -S <<< $password ufw allow 'Nginx HTTP'
        sudo -S <<< $password ufw status

        sudo -S <<< $password systemctl status nginx

        for i in "${domain_name[@]}"; do
            sudo -S <<< $password cp WEB/nginx.txt /etc/nginx/sites-available/$i
            sudo -S <<< $password sed -i s/example!/$i/g /etc/nginx/sites-available/$i
            sudo -S <<< $password ln -s /etc/nginx/sites-available/$i /etc/nginx/sites-enabled/
            sudo -S <<< $password nginx -t 
        done
        
        sudo -S <<< $password sed -i "/server_names/hash_bucket_size 64/s/#//g" /etc/nginx/nginx.conf
        sudo -S <<< $password systemctl restart nginx 
        sudo -S <<< $password systemctl status nginx 

        sleep 5
        clear

    else
        echo unknown

    fi
}

# A filters to remove what number after/before adding option all
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
# Checks what service to call
for i in "${Arr[@]}"; do
    case $i in
        0)
            (dhcp_call);;
        1)
            (samba_call);;
        2)
            (dns_call);;
        3)
            (web_call);;
        *)
            echo "$i no service is available";;
    esac
done
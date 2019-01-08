#!/bin/bash
host_name=$1
disk_size=$2
number_of_cpus=$3
amount_of_ram=$4
iso_name=$5

mac_address=$(openssl rand -hex 6 | sed 's/\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)/\1:\2:\3:\4:\5:\6/')
echo "Trying mac: $mac_address"
known_mac_addresses=$(sudo nmap -sn 10.30.0.* | grep -Po '(?<=MAC Address: )[^ (]*')
while [[ ${mac_address^^} == *"$known_mac_addresses"* ]]; do
   echo "Picked a mac that's already known on the network... trying again..."
   mac_address=$(openssl rand -hex 6 | sed 's/\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)/\1:\2:\3:\4:\5:\6/')
done
echo "Chose mac address: $mac_address"

((next_available_vnc_port=$(grep -hrPo '(?<=-vnc :)[^-k]*' | sort -rn | head -n 1  | bc) +1))
((next_available_tap=$(grep -hrPo '(?<=ifname=tap)[^. \\]*' | sort -rn | head -n 1  | bc) +1))
echo "Chose vnc port: $next_available_vnc_port"
echo "Chose tap number: $next_available_tap"
sudo qemu-img create -f qcow2 /var/lib/libvirt/images/$host_name.qcow2 ${disk_size}G

echo "qemu-system-x86_64 -name $host_name -enable-kvm -m $amount_of_ram -cpu host -smp $number_of_cpus \\
 -daemonize \\
 -boot once=dc \\
 -rtc base=localtime \\
 -vnc :$next_available_vnc_port -k en-gb \\
 -device ich9-ahci,id=ahci \\
 -device ide-drive,drive=d0,bus=ahci.0 \\
 -device rtl8139,netdev=net0,mac=${mac_address} \\
 -netdev tap,id=net0,ifname=tap${next_available_tap} \\
 -drive file=/var/lib/libvirt/images/${host_name}.qcow2,id=d0,format=qcow2,if=none \\
 -device ide-cd,drive=c0 \\
 -drive file=/andre/nasbox/ISOs/$iso_name,id=c0,media=cdrom,if=none" > ${host_name}

sudo chmod +x $host_name

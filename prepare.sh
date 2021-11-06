#!/bin/bash

set -e

vm_url="https://az792536.vo.msecnd.net/vms/VMBuild_20190311/VirtualBox/MSEdge/MSEdge.Win10.VirtualBox.zip"
vm_name="win10-prepare"
ova_path="$vm_name.ova"
vnc_password="pfanne"
#today=`date "+%Y-%m-%d"`

box_name="win10"
vm_store=`VBoxManage list systemproperties | grep -i "default machine folder:" | cut -b 24- | awk '{gsub(/^ +| +$/,"")}1'`
vm_path="$vm_store/$vm_name"

if [ ! -e adapter_name ] ; then
    vboxmanage hostonlyif create | awk '{print substr($2,2,length($2)-2)}' > adapter_name
    adapter_name=`cat adapter_name`
    vboxmanage hostonlyif ipconfig "$adapter_name" --ip 192.168.56.1
    vboxmanage dhcpserver add --ifname "$adapter_name" --ip 192.168.56.1 --netmask 255.255.255.0 --lowerip 192.168.56.100 --upperip 192.168.56.100
    vboxmanage dhcpserver modify --ifname "$adapter_name" --enable
fi

adapter_name=`cat adapter_name`


if [ "$1" == 'create' ]; then
    running=`vboxmanage list runningvms | grep "\"$vm_name\"" | wc -l`
    if (( running )) ; then
        echo "target vm is running"
        exit 1
    fi

    if [ ! -e "$ova_path" ] ; then
        curl -o "$ova_path.zip" "$vm_url"
        mkdir ova_temp
        unzip -d ova_temp "$ova_path.zip"
        mv ova_temp/*.ova "$ova_path"
        rm -rf ova_temp

    fi

    vboxmanage unregistervm "$vm_name" --delete || /bin/true
    rm -rf "$vm_path"

    vboxmanage import "$ova_path" --vsys 0 --vmname "$vm_name" --cpus 2 --settingsfile="$vm_path/$vm_name.vbox"
    vboxmanage list vms
    vboxmanage modifyvm "$vm_name" --vrde on
    vboxmanage modifyvm "$vm_name" --vrdeproperty VNCPassword="$vnc_password"
    vboxmanage modifyvm "$vm_name" --vram 64

    vboxmanage sharedfolder add "$vm_name" --name prepare --hostpath `pwd`/share --automount

    #guestmount -v -a "$vm_path/MSEdge - Win10-disk001.vmdk" -m /dev/sda1 --rw mnt
    #cp vagrant.pub mnt/
    #cp sshd_config mnt/
    #cp fixpolicy.bat mnt/
    #guestunmount mnt

    vboxmanage modifyvm "$vm_name" --nic1 hostonly
    vboxmanage modifyvm "$vm_name" --hostonlyadapter1 "$adapter_name"
fi

if [ "$1" == 'info' ]; then
    vboxmanage showvminfo "$vm_name"
fi

if [ "$1" == 'start' ]; then
    # using vnc somehow causes crash at machine shutdown
    # vboxmanage setproperty vrdeextpack VNC
    vboxmanage setproperty vrdeextpack "Oracle VM VirtualBox Extension Pack"
    vboxheadless --startvm "$vm_name"
fi

if [ "$1" == 'connect_rdp' ]; then
    vinagre localhost:5940
fi

if [ "$1" == 'package' ]; then
    vboxmanage modifyvm "$vm_name" --nic1 nat
    vboxmanage modifyvm "$vm_name" --hostonlyadapter1 ''

    vboxmanage sharedfolder remove "$vm_name" --name prepare

    rm -f "$box_name.box"
    vagrant package --base "$vm_name" --output "$box_name.box" "$box_name"
    #vagrant box add "$box_name.box" --name "$box_name" --force
fi

if [ "$1" == 'cleanup' ]; then
    vboxmanage unregistervm "$vm_name" --delete || /bin/true
    rm -rf "$vm_path"
    if [ -e adapter_name ] ; then
        vboxmanage hostonlyif remove "$adapter_name"
        rm adapter_name
    fi
fi

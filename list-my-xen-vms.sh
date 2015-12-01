#!/bin/bash
##################################################################################################
##How to use##
#1.Upload it to Xenserver compute node
#2.Give appropriate permissions chmod u+x list-my-xen-vms.sh
#3.Run ./list-my-xen-vms.sh (to print to screen)
#OR
#3.Run ./list-my-xen-vms.sh > myexisting-vm-list.txt (to print to myexisting-vm-list.txt text file in current script location)
#Script by: Kibui Kenneth utafitini.com/home/user/mainakibui - 01/dec/2015
####################################################################################################

echo "==========================================="
echo hv_name=`/opt/xensource/bin/xe host-list params=name-label|grep name-label|cut -c 23-|head -n1`
echo " "
list=`/opt/xensource/bin/xe vm-list | grep uuid | awk -F: '{print $2}'`
list=$(echo $list | tr ' ' '\n' | sort -nu)
for item in $list
do
  echo "==========================================="
  echo "VM:"
  echo "-------------------------------------------"
  echo vm_name=`/opt/xensource/bin/xe vm-list params=name-label uuid=$item|grep "name-label"|cut -c 23-`
  echo power_state=`/opt/xensource/bin/xe vm-list params=power-state uuid=$item|grep "power-state"|cut -c 23-`
  echo os_version=`/opt/xensource/bin/xe vm-list params=os-version uuid=$item|grep "os-version"|cut -c 29-`
  echo VCPUs_number=`/opt/xensource/bin/xe vm-list params=VCPUs-number uuid=$item|grep "VCPUs-number"|cut -c 25-`
  memory_size=`xe vm-list params=memory-static-max uuid=$item|grep "memory-static-max"|cut -c 30-`
  memory_size_calc=$(($memory_size/1024/1024/1024))
  echo "Memory size = $memory_size Bytes  $memory_size_calc GB"
  echo " "
  echo "==========================================="
  echo "VDI's list':"
  echo "-------------------------------------------"
  echo " "

  #Loop though the VM disks and find SR name and Size allocation
  vm_disks=`/opt/xensource/bin/xe vbd-list vm-uuid=$item type=Disk params=vdi-uuid|grep "vdi-uuid"|cut -c 21-`
  vm_disks=$(echo $vm_disks | tr ' ' '\n' | sort -nu)

  for item2 in $vm_disks
  do
    echo "uuid=$item2"
    echo sr_name=`/opt/xensource/bin/xe vdi-list  uuid=$item2 params=sr-name-label|grep "sr-name-label"|cut -c 26-`
    disk_size=`/opt/xensource/bin/xe vdi-list uuid=$item2 params=physical-utilisation|grep "physical-utilisation"|cut -c 33-`
    disk_size_calc=$(($disk_size/1024/1024/1024))
    echo "Disk size $disk_size Bytes  $disk_size_calc GB"
    echo "********************************************"
  done

done

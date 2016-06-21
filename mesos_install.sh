#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo 
  echo "================================================================"
  echo "                  NO ARGUMENTS PROVIDED"
  echo 
  echo "Usage:"
  echo " ./mesos_install.sh single  -  installs single Mesos Master node"
  echo " ./mesos_install.sh cluster -  installs 3x Mesos Master cluster "
  echo "================================================================"
  echo 
  exit 1
fi

export ANSIBLE_HOST_KEY_CHECKING=False

# Creating VM instances
ansible-playbook create_vm.yaml --extra-vars "ha=$1"

#Wait for VM running
echo " Waiting while nodes started"
sleep 40

#Clear known_hots file from existing host keys
nova --os-project-name=Mesos list | grep -P '\d' | awk '{print $13}' > all.ip
while read line; do
    ssh-keygen -f "/root/.ssh/known_hosts" -R $line
    ssh-keyscan -H $line >> ~/.ssh/known_hosts
done < all.ip
rm -f all.ip

#Add hosts ip to /etc/hosts file
ansible-playbook update_ansible_hosts.yaml

#Deploy common configuration
ansible-playbook common_install.yaml

#Deploy Master node software
ansible-playbook master_install.yaml

#Deploy Slave node software
ansible-playbook slave_install.yaml

#Install dockers on Slave nodes
ansible-playbook docker_install.yaml

#Reboot all mesos hosts
ansible-playbook reboot_all.yaml

mesos_ip=`nova --os-project-name=Mesos list |  grep 'Master' | awk '{print $13}'` 
echo "===================================================="
echo " Mesos cluster running on:     http://$mesos_ip:5050"
echo "===================================================="
echo " Marathon cluster running on:  http://$mesos_ip:8080"
echo "===================================================="
 


#!/bin/bash

export ANSIBLE_HOST_KEY_CHECKING=False

# Creating VM instances
ansible-playbook create_vm.yaml

#Wait for VM running
echo "Waiting while all node services started"
sleep 40

#Updating Ansible hosts file
source keystonerc_
echo "[mesos_master]" >> /etc/ansible/hosts
nova --os-project-name=Mesos list | grep Master | awk '{print $13}' >> /etc/ansible/hosts
echo "" >> /etc/ansible/hosts
echo "[mesos_slave]" >> /etc/ansible/hosts
nova --os-project-name=Mesos list | grep Slave | awk '{print $13}' >> /etc/ansible/hosts

#Clear known_hots file from existing host keys
nova --os-project-name=Mesos list | grep -P '\d' | awk '{print $13}' > all.ip
while read line; do
    ssh-keygen -f "/root/.ssh/known_hosts" -R $line
    ssh-keyscan -H $line >> ~/.ssh/known_hosts
done < all.ip
rm -f all.ip

#Add hosts ip to /etc/hosts file
ansible-playbook update_hosts_file.yaml

#Deploy common configuration
ansible-playbook common_install.yaml

#Deploy Master node software
ansible-playbook master_install.yaml

#Deploy Slave node software
ansible-playbook slave_install.yaml

#Reboot all mesos hosts
ansible-playbook reboot_all.yaml

mesos_ip=`nova --os-project-name=Mesos list |  grep 'Master-1' | awk '{print $13}'` 
echo "===================================================="
echo " Mesos cluster running on:     http://$mesos_ip:5050"
echo "===================================================="
echo " Marathon cluster running on:  http://$mesos_ip:8080"
echo "===================================================="
 


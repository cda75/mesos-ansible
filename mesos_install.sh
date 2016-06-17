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

#Get all ip-s in one file for future processing
#nova --os-project-name=Mesos list |  awk '{print $4"=",$13}' > /etc/ansible/mesos/floating.ip

#Clear known_hots file from existing host keys
#while read line; do
#    ssh-keygen -f "/root/.ssh/known_hosts" -R $line
#    ssh-keyscan -H $line >> ~/.ssh/known_hosts
#done < all.ip
#rm -f all.ip

#Add hosts ip to /etc/hosts file
ansible-playbook update_hosts_file.yaml

#Deploy common configuration
ansible-playbook common_install.yaml

#Deploy Master node software
ansible-playbook master_install.yaml

#Deploy Slave node software
ansible-playbook slave_install.yaml

mesos_ip=`nova --os-project-name=Mesos list |  grep 'Master-1' | awk '{print $13}'` 
echo "Now you can connect to Mesos cluster on"
echo "http://$mesos_ip:5050"


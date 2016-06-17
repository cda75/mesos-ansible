#!/bin/bash

export ANSIBLE_HOST_KEY_CHECKING=False

# Creating VM instances
ansible-playbook /etc/ansible/mesos/create_vm.yaml

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
nova --os-project-name=Mesos list |  awk '{print $4"=",$13}' > /etc/ansible/mesos/floating.ip

#Clear known_hots file from existing host keys
#while read line; do
#    ssh-keygen -f "/root/.ssh/known_hosts" -R $line
#    ssh-keyscan -H $line >> ~/.ssh/known_hosts
#done < all.ip
#rm -f all.ip

#Update host files on node VMs
ansible-playbook update_hosts.yaml

#Deploy common configuration
ansible-playbook install_common.yaml

#Deploy Master node software
ansible-playbook master_install.yaml

#Deploy Slave node software
ansible-playbook slave_install.yaml




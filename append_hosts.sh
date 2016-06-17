#!/bin/bash

source /home/ansible/keystonerc_admin
echo "[mesos_master]" >> /etc/ansible/hosts
nova --os-project-name=Mesos list | grep Master | awk '{print $13}' >> /etc/ansible/hosts
echo "" >> /etc/ansible/hosts
echo "[mesos_slave]" >> /etc/ansible/hosts
nova --os-project-name=Mesos list | grep Slave | awk '{print $13}' >> /etc/ansible/hosts



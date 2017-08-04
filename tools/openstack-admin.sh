#!/bin/bash
# Juan Manuel Torres - https://github.com/Tedezed

if [ $1 = 'create-user' ]; then
	user=$2
	pass=$3
	email=$4

	if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
		echo "Example: openstack-admin.sh create-user nom_user pass_user email_user"
	else
		openstack project create --enable $user
		openstack user create --project $user --password $pass --email $email --enable $user
		tenant_id=$(openstack project list | grep test | awk '{ print $2 }')
		neutron router-create router1-$user --tenant-id $tenant_id
		neutron router-gateway-set router1-$user external_network --tenant-id $tenant_id
		neutron net-create private_network-$user --tenant-id $tenant_id
		neutron subnet-create --name private_subnet-$user --dns-nameserver 8.8.8.8 private_network-$user 192.168.100.0/24 --tenant-id $tenant_id
		neutron router-interface-add router1-$user private_subnet-$user --tenant-id $tenant_id
	fi
else
	echo "Command Line Arguments:"
	for i in "- create-user"
	do
		echo $i
	done
fi

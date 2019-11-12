#!/bin/bash

# make output verbose
set -x

if [ ! "$2" ]
  then
    echo "usage: $0 cluster_name key_name"
    exit 1
fi

# tweak settings
master_flavor="p2.xlarge"
master_count="1"
node_count="1"
node_flavor="p2.xlarge"
name="$1"
keypair="$2"

# you can re-use this for multiple clusters
cidr="10.65.0.0/24"
dhcp_start="10.65.0.1"
dhcp_end="10.65.0.20"

# when using a name is breaks because it cannot find os_distro?
image="ac6c15cc-9073-4537-98d9-00f4ccfefa25"

# create network and disable port security because of Contrail issue
openstack network create --no-share --disable-port-security ${name}-network

# create subnet
openstack subnet create --dhcp --network ${name}-network --subnet-range $cidr --allocation-pool start=${dhcp_start},end=${dhcp_end} ${name}-subnet

# we always first need a template, we need to define our networks, if magnum makes one for us, it will apply security groups
openstack coe cluster template create --image "$image" --external-network public --fixed-network ${name}-network --fixed-subnet ${name}-subnet --dns-nameserver 8.8.8.8 --master-flavor $master_flavor --flavor $node_flavor --coe kubernetes --volume-driver cinder --network-driver flannel --docker-volume-size 40 ${name}-template

# finally, create the cluster
openstack coe cluster create --cluster-template ${name}-template --master-count $master_count --node-count $node_count --keypair $keypair ${name}-cluster


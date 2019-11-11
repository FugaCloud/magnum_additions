#!/bin/bash

set -x

if [ ! "$1" ]
  then
    echo "usage: $0 cluster_name"
    exit 1
fi

# tweak settings
master_flavor="c2.large"
master_count="1"
node_count="1"
node_flavor="c2.large"
name="$1"

# you can re-use this for multiple clusters
cidr="10.65.0.0/24"
dhcp_start="10.65.0.1"
dhcp_end="10.65.0.20"
image="1ddac6e6-e4ae-4251-be13-e1f450485760"


# disable port security because of Contrail issue
openstack network create --no-share --disable-port-security ${name}-network

openstack subnet create --dhcp --network ${name}-network --subnet-range $cidr --allocation-pool start=${dhcp_start},end=${dhcp_end} ${name}-subnet

openstack coe cluster template create --image $image --external-network public --fixed-network ${name}-network --fixed-subnet ${name}-subnet --dns-nameserver 8.8.8.8 --master-flavor $master_flavor --flavor $node_flavor --coe kubernetes --volume-driver cinder --network-driver flannel --docker-volume-size 40 ${name}-template

openstack coe cluster create --cluster-template ${name}-template --master-count $master_count --node-count $node_count --keypair mac ${name}-cluster



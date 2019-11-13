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
node_count="2"
node_flavor="p2.xlarge"
name="$1"
keypair="$2"

# you can re-use this for multiple clusters
cidr="10.65.0.0/24"
dhcp_start="10.65.0.1"
dhcp_end="10.65.0.20"

# when using a name is breaks because it cannot find os_distro?
image="ac6c15cc-9073-4537-98d9-00f4ccfefa25"

if ! openstack coe cluster template create --image "$image" \
  --external-network public \
  --master-flavor $master_flavor \
  --flavor $node_flavor \
  --coe kubernetes \
  --volume-driver cinder \
  --network-driver flannel \
  --docker-volume-size 40 \
  ${name}-template

  then
    echo "error while creating the cluster template"
    exit 1
fi

# create the cluster
if ! openstack coe cluster create --cluster-template ${name}-template -–master-lb-enabled --master-count 1 --node-count $node_count --keypair $keypair ${name}-cluster
  then
    echo "error while creating cluster"
    exit 1
fi


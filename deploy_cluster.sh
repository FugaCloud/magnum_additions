#!/bin/bash

if [ ! "$2" ]
  then
    echo "usage: $0 cluster_name key_name"
    exit 1
fi

# tweak settings
master_flavor="p2.xlarge"
node_count="2"
node_flavor="p2.xlarge"
# currently the only verified version which deploys a working
# cloud controller is 1.11.1
version_tag="v1.11.1"

name="$1"
keypair="$2"

# you can re-use this for multiple clusters
cidr="10.65.0.0/24"
dhcp_start="10.65.0.1"
dhcp_end="10.65.0.20"

# when using a name is breaks because it cannot find os_distro?
image="ac6c15cc-9073-4537-98d9-00f4ccfefa25"

create_template() {
  if ! openstack coe cluster template create --image "$image" \
    --external-network public \
    --master-flavor $master_flavor \
    --flavor $node_flavor \
    --coe kubernetes \
    --volume-driver cinder \
    --network-driver flannel \
    --docker-volume-size 40 \
    --labels kube_dashboard_enabled=0,kube_tag=${version_tag} \
    ${name}
    then
      echo "error: failed to create template"
      exit 1
  fi
}

# verify if the template exists, a user might re-use the name
templates="$(openstack coe cluster template list -f json | jq -r .[].name)"

echo $templates
dupe=""
for template in $templates
do
  if [ "$template" == "$name" ]
    then
      dupe="true"
  fi
done
if [ ! "$dupe" == "true" ]
  then
    create_template
  else
    echo "found a cluster template with the same name, skipping creation"
fi
echo "failsafe"
exit 0
# create the cluster
if ! openstack coe cluster create --cluster-template ${name} --master-count 1 --node-count $node_count --keypair $keypair ${name}
  then
    echo "error while creating cluster"
    exit 1
fi


#!/bin/bash

if [ ! "$2" ]
  then
    echo "usage: $0 cluster_name key_name [kube_version_tag]"
    echo -e "\nExample: $0 mycluster mykeypair v1.16.2 (experimental)"
    echo -e "\nExample: $0 mycluster mykeypair (installs 1.11.6)"
    exit 1
fi

# if a user defines the version_tag, use it
if [ "$3" ]
  then
    version_tag="$3"
  else
    version_tag="v1.11.6"
fi

if [ "$4" ]
  then
    node_count="$4"
  else
    node_count="1"
fi

# tweak settings
master_flavor="p2.xlarge"
node_flavor="p2.xlarge"

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

verify_template() {
  # verify if the template exists, a user might re-use the name
  dupe="0"
  templates="$(openstack coe cluster template list -f json | jq -r .[].name)"
  for template in $templates
  do
    if [ "$template" == "$name" ]
      then
        dupe="1"
    fi
  done
  return $dupe
}

if verify_template
  then
    create_template
  else
    echo "found a cluster template with the same name, skipping creation"
fi

# create the cluster
if ! openstack coe cluster create --cluster-template ${name} --master-count 1 --node-count $node_count --keypair $keypair ${name}
  then
    echo "error while creating cluster"
    exit 1
fi

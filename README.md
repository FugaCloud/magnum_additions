Magnum additions
----------------


# TODO
#
# - loadbalancer deployed has default sgroup

Requirements:
------------

jq - binary to parse json, included in most OS/distro's
Python - adviced to install a virtualenv with required modules



Python
------
To install a new virtualenv:

python3 -m venv ~/virtualenv/openstack
. ~/virtualenv/openstack/bin/activate
pip install -U pip
pip install openstackclient python-magnumclient 


kubectl
-------

Please refer to the installation page on how to install it for your OS/disto.
Make sure  you deploy the same version as the kubernetes version you plan
to use. It can cause issues when they are different.

https://kubernetes.io/docs/tasks/tools/install-kubectl/


deploy_cluster.sh
-----------------

To deploy a cluster template and cluster, you can run the script. Its adviced
to stick to the default version of v1.13.10. If you do not specify a tag,
it will use v1.13.10 at this time.

./deploy_cluster.sh $name_of_cluster $keypair_name [$version_tag]

To monitor the installation you can view the heat stack or cluster status

openstack coe cluster list
openstack coe cluster show $name
openstack stack list

After the installation is complete, usually around 20 minutes, you can retrieve
the cluster config:

openstack coe cluster config $name

(if you see path names in your config instead of a base64 cert,
 you are using a very old openstack client, see the section about Python)

This will place 'config' in your current dir. Start using it:

export KUBECONFIG=$(pwd)/config

kubectl get nodes

This should now should your cluster


node.sh
--------

make sure that if you run kubectl get nodes, you see the nodes you expect.
This will label all found nodes with label: 

failure-domain.beta.kubernetes.io/zone=nova

This is (still) required for peristent volumes from Cinder to work.
(work in progress, might not be required in the future)

storageclass.yaml
-----------------

If you apply this, Kubernetes can use Cinder for pv's. It will become the
default storage class.

kubectl apply -f storageclass.yaml


nginx_example.yaml
------------------

A complete deployment with persistent volume, load balancer and pod.

kubectl apply -f nginx_example.yaml

(if you get errors, make sure kubectl versions match)

This should create a pvc, pv, svc and deployment. Once allocated it will show
the external IP of the loadbalancer in the output:

kubectl get svc

After a short while, at least a few minutes, you should be able to

curl $ip_of_loadbalancer

(If this does not work, open port 80 in the default sgroup. It might be
that there is a different sgroup assigned to your lb, please check)


deletion
--------

Make sure you first delete your objects, e.g. svc/pvc. If you don't,
it might get stuck deleting, and you have to manual go through them.



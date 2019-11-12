Magnum additions
----------------

These are files to aid in using our installation of Magnum in OpenStack.  We
are currently in 'internal-beta' mode and these files can help you get started
with Magnum.

Make sure you have a working openstack-cli ready and a kubectl matching 1.11.1.

Currently we create our network and subnet ourselves before we run Magnum.
This is because Magnum still enables port security on the created network,
and we are now using network without it, because of the Contrail 'addres pair
limitation'.

deploy_cluster.sh
---------

This will create a network, subnet, template and cluster.
After the installation is complete, usually around 20 minutes, you can retrieve
the cluster config:

openstack coe cluster config $name

This will place 'config' in your current dir. Start using it:

export KUBECONFIG=$(pwd)/config

kubectl get nodes

This should now should your cluster


nodes.sh
--------

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
This should create a pvc, pv, svc and deployment. Once allocated it will show
the external IP of the loadbalancer in the output:

kubectl get svc

After a short while, at least a few minutes, you should be able to

curl $ip_of_loadbalancer




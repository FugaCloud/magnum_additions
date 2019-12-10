Magnum additions
----------------

These are files to aid in using our installation of Magnum in OpenStack.  We
are currently in 'internal-beta' mode and these files can help you get started
with Magnum.

deploy_cluster.sh
-----------------

First make sure the openstack command works and you have all the required
Python modules (openstack modules, python-magnumclient)

./deploy_cluster.sh $name_of_cluster $keypair_name [$version_tag]

tested version is v1.13.10, this is also the default in the script, other
versions can cause issues, please avoid them for now.

To monitor the installation you can view the heat stack or cluster status

openstack coe cluster list
openstack coe cluster show $name
openstack stack list

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




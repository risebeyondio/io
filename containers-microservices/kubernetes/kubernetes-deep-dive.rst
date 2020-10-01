|

**kubernetes deep dive**

------------------------

|

`home <https://github.com/risebeyondio/io>`_

|

.. contents:: contents
  :depth: 10

|

architecture
-------------

|

master / worker architecture
   - master / control plane node - one or more, 1+
   
   - worker node - zero or more, 0+ - kubernetes and container runtime only
   
   within a worker node a **pod** resides that contains one or more containers that run an application
   
   abstraction from infrastructure - the difference can not be seen if application deployment is involving a single node or few thousand nodes cluster - to the user, it seems that all is run one single giant machine
   
   kubernetes takes care of
   
   - service discovery
   - scaling
   - load balancing
   - self healing
   - leader election 

|

master node - control plane 
   four components
   
   - api server - communication hub for all cluster components
   
   - scheduler - assigns an application to a worker node, decides which node is to run a pod, based on resource requirements, hardware constraints, etc 
   
   - controller manager - maintenance and handling of a cluster, failed nodes, replication, desired state
   
   - etcd - datastore storing cluster configuration, recommended having etcd backed up in case of cluster failures
   
   a master can never contain pods or run un application components
   
   it is recommended to have a master node replication for high availability
   
   the master initiates and follows instructions in line with specifications to deploy pods and their containers
   
worker node(s)
   runs, monitor and provide services needed for un application
   
   three components
   
   - kubelet - runs and manages containers on the node, communicates with api server
   
   - kube-proxy / service proxy - traffic load balancing among application components
   
   - container runtime - program running containers (docker, rkt, containerd) 
   
|

*application runing on kubernetes [source linuxacademy.com]*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes_application_run.png

   :align: center
   :alt: application runing on kubernetes

|

contents_

|

api
---

|

kubectl
   is a tool that translates cli commands to api calls being send to api server

|

api server
   the only component that talks with etcd datastore
   
   all other components communicate with etcd and each other through api server only
   
   provides create, read, update, delete CRUD interface for querying and modifying the cluster state over a restful api
   
   ``kebectl`` command can be used to create, updtate, delete and get / read api objects - CRUD

   all objects like pods or services are persistent enteties being represented by declarative intent - desired state
   
   api version and software version are not directly related
   
|

spec - desired state - declarative intent - yaml
   all indentation in yaml is achieved by 2 spaces not tabs
   
   if at any time specific object status does not match the object's spec, the cluster master / control plane will work on corrections to make the match
   
   to create object based on existing spec yaml file run ``kubectl create -f nginx-spec-file.yaml``
   
   ``kubectl`` command converts any yaml format into json as api request body must contain json 
   
   show specific deployment in yaml ``kubectl get deployment myDeployment -o yaml``
   
   objects always have a matadata, at minimum name and uid
   
   object name - user given and uid - cluster given, must be unique for a particular kind of objects, no two pods named identically 
   
   name - up to 253 characters, can contain dashes and periods `- .`
   
   spec's conteiner value specifies
   
   - container image
   
   - volumes
   
   - exposed ports
   
   labels - to be applied to better orginize objects, key-value pairs that can be attached to objects during creation or after,  if multiple - no keys duplication on a single object, 
   
   to apply new label (here env) to specific pod use ``kubectl label pods $podName env=prod`` 
   
   label selector can be used to filter through the cluster objects ``kubectl get pods --show-labels``
   
   annotations can be also added to object metadata value, as in example ``kubectl annotate deployment $deploymentName myCorp/annotation='piotr'``
   
filtering with field selectors
   ``kubectl get pods --field-selector status.phase=Running``
   
   ``kubectl get services --field-selector metadata.namespace=default``
   
   ``kubectl get pods --field-selector status.phase=Running,metadata.namespace=default``
   
   ``kubectl get pods --field-selector status.phase!=Running,metadata.namespace!=default``

|

contents_

|

services
--------

|

service
   dynamically access a group of replicated pods
   
   each service has one consistent IP address and port pair whereas pods can be created, destroyed frequently and changing IP addresses
   
   service IP address is virtual - not associated with physical NIC
   
   if an old pod failes, gets destroyed, the service decides how to route traffic to a new pod
   
   to start service from existing spec file run ``kubectl create -f $myService.yaml``
   
   to verify run ``kubectl get services`` or ``kubectl get services $myService.yaml``

   in case of nginx, service can be verified with ``curl localhost:30080``
   
|

sample service spec, associated with label selector - app

|

.. code-block:: yaml
   
   apiVersion: v1
   kind: Service
   metadata:
     name: nginx-nodeport
   spec:
     type: NodePort
     ports:
     - protocol: TCP
       port: 80
       targetPort: 80
       nodePort: 30080
     selector:
       app: nginx
       
|

*services and replica pods [source linuxacademy.com]*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes-services.png
   :align: center
   :alt: services and replica pods
   
|

kube-proxy
----------

|

kube-proxy
   handles traffic associated witha service or other cluster component / object by creating iptables rules
   
|

*initialization of new service in a cluster [source linuxacademy.com]*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes-kube-proxy.png
   :align: center
   :alt: initialization of new service in a cluster
   
|

contents_

|

build
-----

|

build
   can be done on
   
   - physical / bare metal
   
   or 
   
   - cloud server

|

custom solution
   - from scratch - manually
   
   - own network fabric configuration without flannel or other network overlay
   
   - build own images in private registry
   
   - secure cluster communication - https
   
   - kubelet is the only component that has to run on the system not as a pod as it is responsible to run everything else as pods 

|

pre-build
   - minikube
   quickiest and simplest - for single node local testing
   
   - minishift
   
   - microK8s
   
   - ubuntu on lxd
   
   - GCP, AWS,other
   
|

contents_

|

cluster configuration
=====================

|

*master and 2 worker nodes - OS - ubuntu* 

|

.. code-block:: shell
   
      # all nodes
      
      
      # get docker gpg key
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

      #add docker repository
      sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linuxubuntu $(lsb_release -cs) stable"

      # get kubernetes gpg key
      curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

      #add kubernetes repository
      cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
      deb https://apt.kubernetes.io/ kubernetes-xenial main
      EOF

      # update packages
      sudo apt-get update

      # install docker, kubelet, kubeadm, and kubectl
      sudo apt-get install -y docker-ce=5:19.03.12~3-0~ubuntu-bionic kubelet=1.17.8-00 kubeadm=1.17.8-00 kubectl=1.17.8-00

      # lock their current version:
      sudo apt-mark hold docker-ce kubelet kubeadm kubectl

      # add iptables rule to sysctl.conf:
      echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf

      # enable iptables instantly
      sudo sysctl -p


      # master only


      # initialize  cluster
      sudo kubeadm init --pod-network-cidr=10.244.0.0/16

      # set up local kubeconfig
      mkdir -p $HOME/.kube
      sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
      sudo chown $(id -u):$(id -g) $HOME/.kube/config

      # apply Calico CNI network overlay
      kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml

      # workers only

      # join worker nodes to cluster
      sudo kubeadm join [your unique string from the kubeadm init command]

      # verify wether worker nodes have joined the cluster
      kubectl get nodes

|

contents_

|

high availability
=================

|

*high availability in kubernetes [source linuxacademy.com] *

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes-ha.png
   :align: center
   :alt: kubernetes high availability

|

contents_

|

*******************************
ha, leader elections, endpoints
*******************************

|

high availability
   each master / control plane node component can be replicated
   
   some components have to stay in standby state to avoid conflicts with other replicated components
   
   - scheduler
   
   - control manager
   
   both of above actively observe cluster state and apply actions when it changes
   
   if these two coponents were both replicated and worked in tandem they could start competing and create resource dupicates, etc.
   
   only a single scheduler and control manager can be active at a time and this is managed by leader election mechanism

|

leader elect mechanism and endpoint resource
   manages which replicated coponent is in active and which in standby

   elected component becomes a leader and is set as acitive component

   active component is set to true by default

   endpoint resource
      needs to be created to enable leader election functionality

   to verify status of scheduler endpoint run ``kubectl get endpoints kube-scheduler -n kube-system -o yaml``

|

contents_

|

****************
etcd replication
****************

|

etcd replication
   due to distributed aspect of etcd, its replication must be achieved as stacked or external topology

|

stacked topology
   each master node creates local etcd member, this member talks anly with api server of this / own node
   
   installation of stacked topology
      - download, extract and move etcd binaries to ``/usr/local/bin``
      
      - create 2 directories ``/etc/etcd`` and ``/var/lib/etcd``
      
      - create systemd unit file for etcd
      
      - enable and start etcd service
      
      - once above steps are completed, progress to install other kubernetes components

|      

stacked etcd topology - kubeadm configuration
   - create a file - kubeadm-config.yaml
   
.. code-block:: yaml

   apiVersion: kubeadm.k8s.io/v1beta2
   kind: ClusterConfiguration
   kubernetesVersion: stable
   controlPlaneEndpoint: "LOAD_BALANCER_DNS:LOAD_BALANCER_PORT"
   etcd:
       external:
           endpoints:
           - https://ETCD_0_IP:2379
           - https://ETCD_1_IP:2379
           - https://ETCD_2_IP:2379
           caFile: /etc/kubernetes/pki/etcd/ca.crt
           certFile: /etc/kubernetes/pki/apiserver-etcd-client.crt
           keyFile: /etc/kubernetes/pki/apiserver-etcd-client.key      
   
- run ``kubeadm init --config=kubeadm-config.yaml``

- watch pods being created ``kubectl get pods -n kube-system -w``

|
   
external topology
   etcd is external to kubernetes cluster

|

raft consensus algorithm
   used by etcd election process

   requires majority to progress to the other state

   more than half of nodes need to take part in the state change

   to have a majority, number of etcd instances must be odd (with onlly 2 etcd instances, no transition can happen as majority is not possible)

   having exactly 2 etcd instances is worse than having a single one - no consensus and state transition possible 
   
   even in large entrprise deployments maximum of 7 etcd instances is enough 
      
|

*etcd replication [source linuxacademy.com]*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes-etcd-ha.png
   :align: center
   :alt: etcd replication

|

contents_

|

secure cluster api communications
=================================

|

*api access security [source linuxacademy.com]*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes-api-security.png
   :align: center
   :alt: api access security

|

all requests origin from either
   - a client / user
   
   or 
   
   - a pod

|

api communication break down
   - request issued via ``kubectl`` command or a pod itself gets translated into api POST request that hits api server
   
   - the request goes through 3 stages, each contains number of plugins that are called by the api server one by one 
      - authentication - who
         - api server calls plugins until it determins who is sending the request
      
         - authentication method is to be determined by http header or the certificate 
         
         - once found, the request feeds user id and groups the user / client belongs to back to api server
      
      - authorization - what
         - verifies if the authenticated user is allowed to perform the requested activity on the requested resource
      
      - admission control
         - takes place only in case of create, modify, delete a resource
         
         - admission is bypassed if the request is read only
      
   - resource validation 

   - new state gets stored in etcd
   
   - final result gets returned in output

|

self signed certificates can be used to pass authentication phase and seen by running ``cat .kube/config | more`` 

|

role based access control - rbac
   used in requests issued by users not pods
   
   to prevent unauthorized users changing the state of cluster

   roles - what
      define what can be done
      
      user can be associated with single or multiple roles

   role bindings - who and what
      define who can do whar
      
   roles and role bindings
      work in context of a namespace resources
      
   cluster roles and cluster role bindings
      work in context of a cluster scope resources
      
|

service accounts
   request from a pod gets (same as with user) authenticated, authorised and admitted

   service account gets created for each pod and it represents identity of an application running in particular pod
   
   token file holds service accounts authentication token
   
   to check the token from within a pod run ``cat /var/run/secrets/kubernetes.io/serviceaccount/token``
   
   whenever api utilises genuine token to connect to api server
      - plugin authenticates the service account
      
      - passes the servive accounts username back to the api server
      
   to list service account resurces in a cluster, run ``kubectl get serviceaccounts
   
   default service account - applied when no explicit service account is set in pod manifest
   
   if a pod tries to reach other service account in different namespace it will be blocked
   
   rule is that service account can only be accessed from within the same namespace

|

*role based access control [source linuxacademy.com]*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes-role-based-access-control.png
   :align: center
   :alt: role based access control

|

contents_

|

end to end testing
==================

|

manual end-to-end testing - e2e checklist
   1. deployments can run
         - create a nginx deployment ``kubectl create deployment nginx --image=nginx``
      
         - verify deployments ``kubectl get deployments``
   
   2. pods can run
         - ``kubectl get pods``

   3. pods can be directly accessed
         - set port forwarding to access a pod directly ``kubectl port-forward $podName 8081:80``
      
         - open new terminal session on the same machine and run ``curl --head http://127.0.0.1:8081`` to verify http return code and nginx version
      
   4. logs can be collected from a pod
      - ``kubectl logs $podName``

   5. commands run from pod
         - ``kubectl exec -it $podName -- nginx -v``

   6. services can provide accesss
         - create a service by exposing port 80 of the nginx deployment ``kubectl expose deployment nginx --port 80 --type NodePort``
      
         - list the services in the cluster ``kubectl get services`` and copy teh service external / exposed port number 
      
         - swith to one of the worker nodes and run ``curl -I localhost:$nodeExposedPort``
   
   7. nodes are healthy
         - ``kubectl get nodes`` and ``kubectl describe nodes`` 

   8. pods are healthy 
         - ``kubectl get pods`` and ``kubectl describe pods``

|

automated end-to-end testing
   use kubetest e2e testing tool
   
   https://github.com/kubernetes/test-infra/tree/master/kubetest

|

contents_

|

managemment
-----------

|

components maintenance
=======================

|

steps
   - master node
      - verify kubelet, (api) server and kubeadm versions ``kubectl get nodes``, ``kubectl version --short``, ``sudo kubeadm version``

      - unhold kubeadm, kubelet versions ``sudo apt-mark unhold kubeadm kubelet``

      - install version 1.19.1 of kubeadm ``sudo apt install -y kubeadm=1.19.1-00``

      - freeze the version of kubeadm at 1.19.1 ``sudo apt-mark hold kubeadm``

      - verify kubeadm ``kubeadm version``

      - plan the upgrade of all the controller components ``sudo kubeadm upgrade plan``

      - upgrade controller components ``sudo kubeadm upgrade apply v1.19.1`` minimal downtime can be involved

      - release kubectl version lock ``sudo apt-mark unhold kubectl``

      - upgrade kubectl and kubelet ``sudo apt install -y kubectl=1.19.1-00 kubelet=1.19.1-00``

      - lock back version of kubectl and kublet ``sudo apt-mark hold kubectl kubelet``
      
      - verify kubelet, (api) server versions ``kubectl get nodes``, ``kubectl version --short``
   
   - all worker nodes
      upgrade kubelet
      
      - unhold version ``sudo apt-mark unhold kubelet``

      - upgrade it ``sudo apt install -y kubelet=1.19.1-00``

      - lock back ``sudo apt-mark hold kubelet``
   
   - verify all nodes versions
      ``kubectl get nodes`` 

|

contents_

|

nodes maintanance
=================

|

node maintenance
   occasionally required to upgrade, change node OS, NIC, decommisioning - changes that involve node rebooting or removal
   
   zero downtime - even if pods are replicated on other nodes it is a good practice to move the pods from node to be maintained to a different node - to ensure zero downtime
   
   if the reboot is quick causing breif downtime, kublet will try restart the pod on same node
   
   if downtime is longer than 5 minutes the node controller will completly terminate the pods if no replica sets or deployment is being used
   
   it is crucial to utilise deployments or replica sets as when they are used a new pod will get automatically scheduled to a new node

|

node maintainance steps
   1. before taking a node down - chceck if any pods are running on it ``kubectl get pods -o wide``
   
   2. if yes, then evict the pods on a node ``kubectl drain $nodeNameToBeEvicted --ignore-daemonsets``
   
   3. verify pods to observe if they moved to other nodes ``kubectl get pods -o wide``
   
   4. check if the drained node , one to be under maintanance has changed state to *Ready, SchedulingDisabled* by running ``kubectl get nodes -w``
   
   5. at this stages the node / server can be maintenance, reboot, etc. 
   
   6. once maintenance is done run ``kubectl uncordon $nodeName`` to start scheduling pods to the node again
   
   7. execute ``kubectl get nodes -w`` to check the node status

|

node decommissioning steps
   1. repeat all steps 1 - 4
   
   5. delete node from cluster ``kubectl delete node $nodeName``
   
   6. execute ``kubectl get nodes -w`` to verify node removal
   
   7. shut down and decommisined the node
   
|

adding new node to the cluster steps
   1. spin up new server, virtual machine, etc.
   
   2. install docker, kubeadm, kubectl and kubelet
   
   3. on master server generate new token needed by the new node to join the cluster, run ``sudo kubeadm token generate``
   
   4. copy the just genereted token name from previous command output and past it to ``sudo kubeadm token create $tokenName --ttl 2h --print-join-command``
   
   5. copy the join command from master, switch to new server, paste the command and run it with ``sudo`` (ensure join command has no line breaks - one line with no extra whitespaces)
   
   6. on master execute ``kubectl get nodes -w`` to verify new node addition to the cluster  

|

contents_

|

back up and restore
===================

|

cluster back up
   useful especially if there is single etcd instance only, development cluster with no replicas, etc.
   
   due to the importance of etcd (persistent datastore for all cluster updates), it is recommended to run periodic etcd snapshots, even if the etcd persistent datastore is replicated with consensus algorithm or etcd topology is external to the cluster

|

etcdctl
   if cluster is created with kubeadm it comes with etcdctl tool
   
   enables back up of etcd datastore in single command
   
   it is recommended to keep the snapshot in secure failure proofed location
   
   restoring from the snapshot will initialize entirely new cluster

|

etcdctl back up steps
   - get etcd binaries ``wget https://github.com/etcd-io/etcd/releases/download/v3.3.12/etcd-v3.3.12-linux-amd64.tar.gz``
   
   - unzip the file ``tar xvf etcd-v3.3.12-linux-amd64.tar.gz``
   
   - move files to ``/usr/local/bin``  ``sudo mv etcd-v3.3.12-linux-amd64/etcd* /usr/local/bin``
   
   - take snapshot of etcd datstore and additionally save certificate files in a single etcdctl command ``sudo ETCDCTL_API=3 etcdctl snapshot save snapshot.db --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key``
   
   - verify the snapshot ``ETCDCTL_API=3 etcdctl --write-out=table snapshot status snapshot.db``
   
   - verify if certificates have been copied ``ls /etc/kubernetes/pki/etcd/``
   
   - archive contents of the etcd directory ``sudo tar -zcvf etcd.tar.gz /etc/kubernetes/pki/etcd``
   
   - Copy zipped file to other server ``scp etcd.tar.gz userName@x.x.x.x:~/``

|

etcdctl cluster restore from snapshot
   whether one or all nodes are lost, restoring must be done using same snapshot
   
   restoring overwrires member id and cluster id
   
   impossible to identify with original cluster
   
   restore creates completely new cluster and then it replaces etcd key spaces from the back up
   
   if a node is lost or decommissioned, the new node has to have identical ip address as the original one to be successfully restored
   
   restoring process involves 
      - new etcd data directories for each mode in the cluster
      
      - specyfing initial cluster ip addresses, token and peer urls
      
      - starting etcd with new data directories set up correctly 

|

contents_

|

networking
----------

|

single node communication
=========================

|

*pods networking on a single node [source linuxacademy.com]*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes-node-networking.png
   :align: center
   :alt: node and pod networking

|

networking within nodes 
   kubernetes uses linux network namespaces concepts
   
   inside a node each pod has own ip address
  
   pod ip comes from virtual ethernet interface pair and is handed out by linux ethernet bridge
   
   one of the virtual interfaces pair gets associated with a pod and renamed ``eth0``

|

node's ethernet pipe to a pod - node to pod interface mapping 
   to verify the mapping take following steps

   1. check node's virtual interfaces, login to one of nodes and run ``ifconfig`` - in output ``vethXXXXXX`` interface represents one of node`s virtual interfaces that is than paired with specific pod's interface renamed to eth0

   2. inspect docker containers running in a pod ``sudo su -`` ``docker ps``

   apart from an application containers such as nginx thare are containers running command ``/pause`` - their purpose is to hold pod network namespace 

   3. copy one of containers id and use it in the following ``docker inspect --format '{{ .State.Pid }}' $conteinerId`` to get container process id

   4. nsenter is used to run a command (here ip addr) in a processes' network namespace

   copy process id and use it to run ``nsenter -t $containerPid -n ip addr``

   the output shows interface ``eth0@if6`` (or ``eth0@ifDifferentNumber``) representing mapping of pod's eth0 interface to for example node's inteface 6 - if6 - that is the 6th interface counted top to bottom shown in node ``ifconfig``that was run in first step - ``vethXXXXX``

   the output under eth0 also exposes private IP address of the pod 
  
|

communictaion between pods on same node   
   two or more pods on a single node can talk to each other thanks to the linux ethernet bridge
   
   the bridge is responsible for handing out ip addresses to the pods
   
   linux ethernet bridges diiscover destination via arp requests
   
   bridge enables communication between all veth virtual interfaces, making possible for the pods to talk to each other

|

multiple nodes communication
============================

|

*multiple nodes and pods communication [source linuxacademy.com]*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes-beyond-node-networking.png

   :align: center
   :alt: multiple nodes and pods communication

|

communication among pods on different nodes 
   when packet traverse from one node to another following occurs
   
   - pod's private IP address changes to node's eth0 address (10.244.1.2 -> 172.31.43.91)
   
   - packets get decapsulated and routed over the network to reach destination node and its corresponding pod (pod2)
   
   node to node communication can be achieved through
      - container network interface - cni
      
      or
      
      - manually via layer 3 routing - not recommended due to management overhead in larger multinode clusters
   
|

contents_

|

container network interface - cni
=================================

|

*network overlay [source linuxacademy.com]*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/|kubernetes-network-overlay.png

   :align: center
   :alt: network overlay 

|

container network interface - cni
   sits above existing network - network overlay
   
   cni overlay is a plugin, external to kubernetes solution
   
   allows to build a tunnel between nodes
   
   encapsulates a packet - adds a header on top of a packet
   
   changes source and destiation address - from: pod1 to pod2 - to: node1 to node2
   
   common cni plugin include flannel, calico, romana, weavenet

|

cni installation
   to apply flannel run ``kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml``

   once installed, it installs a network agent on each node

   network agents tie to the cni interface

   to use cni, kubelet has to be notified that cni is used

   once notified, kubelet sets network plugin flag to the cni

   kubelet is being notified that cni is to be used at the stage where the cluster is being initied ``sudo kubeadm init --pod-network-cidr=10.244.0.0/16`` - configured to used certain cidr space
     
|

cni operation
   - mapping association in user space - enabling programming / mapping of all pods ip addresses to node ip addresses

   - once packet enters other node, flannel overlay decapsulates it and passes it to the bridge

   - bridge acts as if the packet was locally originated - frome same node
   
   container runtime (docker, lxc, other) calls cni plugin executable to add or remove an instance to or from containers networking namespace
   
   cni plugin is responsible for creation and assigning ip addresses to pods as well as ip sapce management - deciding what ip adresses are currently avilable what are not, etc.
   
   cni overlay also takes care of assigning and managing ip addresses to multiple containers within a single pod

|
   
contents_

|

services - communication outside of clusters
============================================

|

*kubernetes service networking [source linuxacademy.com]*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes-service-networking.png

   :align: center
   :alt: kubernetes service networking


|

service
   allows locating application components even if the components move or scale up to additional replicas
   
   service gets assigne single virtual inteface
   
   service interface gets evenly distributed and automatically assigned to pods behid that interface
   
   behind the service single virtual inteface pods can change all ip addresses, move etc, but externally / from the outside the service will still have single / same doorway - the virtual interface 

|

****************
nodeport service
****************

|

nodeport service
   in example below it exposes internal - container (nginx) port 80 to external - node port 30080

|

.. code-block:: yaml
   
   apiVersion: v1
   kind: Service
   metadata:
     name: nginx-nodeport
   spec:
     type: NodePort
     ports:
     - protocol: TCP
       port: 80
       targetPort: 80
       nodePort: 30080
     selector:
       app: nginx
  
|

*****************
clusterip service
*****************

|

clusterip service
   gets automatically created during cluster iniitialization
   
   deals with internal load balancing and internal routing of the cluster
   
   if a pod gets moved within a cluster, other pods get updated information such as where it is and how to communicate with it
   
   to check clusterip service run ``kubectl get services -o yaml``
   
   clusterip service represents logical grouping of ip addresses and ports pairs - its own address is not pingable
   
   whenever new service gets creeated, api server informs all kube-proxy agents about the new service
   
   kube-proxy in past had a function of actual proxy, now it is a controller that keeps track of endpoints and updates iptables to maintain correct routing
   
   to check iptables for particular service (here nginx and kube) run ``sudo iptables-save | grep KUBE | grep nginx``
   
|

*********
endpoints
*********

|

endpoint
   is an object in api server
   
   whenever new service appears, endpoint gets automatically created  
   
   it keeps a cache of all pods' ip addresses that form the service
   
   to check endpoints run ``kubectl get endpoints``
   
|

contents_

|

load balancing
==============

|

*load balancing [source linuxacademy.com]*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes-load-balancing.png

   :align: center
   :alt: load balancing

|

load balancer
   extension to nodeport type of service
   
   redirects traffic to all nodes and corresponding node ports
   
   front facing, clients accessing an application communicate only via load balancer IP address
   
   when listing services ``kubectl get services`` some services have *none* in external ip address field
   
   such services are only accessible internally via 
   
   - their private ip address and port number
   
   or
   
   - node's ip address and port number
   
   when cluster is deployed in cloud, the load balancer can be created automatically by creating ``loadbalancer`` type of service (instead of nodeport service)
   
   load balancers are not seeing pods or containers, that is why if one node contains 2 pods and other node just one pod, there would be no even distribution
   
   not even distribution is addressed by ip tables, discused further below 
   
|

load balancer spec file
   as shown below it does not contain nodeport field, this is to allow kubernetes to choose it automatically

|

.. code-block:: yaml
   
   apiVersion: v1
   kind: Service
   metadata:
     name: nginx-loadbalancer
   spec:
     type: LoadBalancer
     ports:
     - port: 80
       targetPort: 80
     selector:
       app: nginx: v1

|

load balancer configuration on cloud servers
   - create new deployment ``kubectl run kubeserve2 --image=chadmcrowell/kubeserve2``
   
   - create a nginx deployment ``kubectl create deployment nginx --image=nginx``
      
   - verify deployments ``kubectl get deployments``
   
   - scale the deployments to 2 replicas to load balance between the two ``kubectl scale deployment/nginx --replicas=2``
   
   - verify which pods are on which nodes ``kubectl get pods -o wide``
   
   - create loadbalancer from a deployment ``kubectl expose deployment nginx --port 80 --target-port 8080 --type LoadBalancer``

   - watch as services create ``kubectl get services -w``
   
   - check yaml of the service ``kubectl get services nginx -o yaml``, nginx deployment should show external ip of the load balancer

   - curl load balancer external ip ``curl http://$external-ip``

|

ip tables
   fix the issue not even load balancing by working out where the pod is in the cluster, if it is on pod 1 it will routed to pod one, if on pod 14 it will routed to pod 14
   
   then kubernetes needs to send it to the originating node in order to send it back to ip tables and correctly routed out
   
   whole process introduces latency
   
   if precisely even load balancing is not required, it is recommended to disable it by adding annotation to always pick the pod on that node - decreasing the extra latancy hop
   
   adding annotation can be done by ``kubectl annotate service nginx externalTrafficPolicy=Local``
   
   verify if annnotation was set by ``kubectl describe services nginx``
   
   the annotation makes routing load balancer traffic local to the node - route the traffic locally
   
|

contents_

|

ingress rules
=============

|

*ingress operation [source linuxacademy.com]*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes-ingress.png

   :align: center
   :alt: ingress operation 

|

ingress
   in load balancing it is required to have one external ip address for every service - one to one
   
   ingress makes it possible to access many services with just one external ip address - one to man
   
   ingress exposes http and https routes from outside the cluster to services operating within the cluster
   
   ingress resource operates at application layer, hence the functionality
   
   to provide ingress both an ingress controller and an ingress resource have to be created

|

ingress resource file
   in the sample 3 ingress rules are present
   
   - request header containg hostname kubeserve.domain.com will get routed to my-kubeserve service

   - request header containg hostname app.example.com will get routed to nginx service
   
   - request not stating hostname will be routed to httpd service

|

.. code-block:: yaml
   
   apiVersion: extensions/v1beta1
   kind: Ingress
   metadata:
     name: service-ingress
   spec:
     rules:
     - host: kubeserve.domain.com
       http:
         paths:
         - backend:
             serviceName: my-kubeserve
             servicePort: 80
     - host: app.example.com
       http:
         paths:
         - backend:
             serviceName: nginx
             servicePort: 80
     - http:
         paths:
         - backend:
             serviceName: httpd
             servicePort: 80
   
|

implementing ingress
   to create the rules run ``kubectl create -f ingress.yaml``

   to ammend already existing rules, execute ``kubectl edit ingress``

   to verify changes run ``kubectl describe ingress``

|

contents_

|

dns
===

|

*dns [source linuxacademy.com]*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes-dns-namespace.png

   :align: center
   :alt: ingress operation 

|

coredns
   coredns plugin has replaced its predecessor - kubedns
   
   default dns plugin, dns server written in go
   
   go advantages include memory safe executable
   
   it supports dns over tls - dot
   
   easilly configurable with etcd and cloud providers to pull authorative data
   
   allows to add dns entries without additional exposure to  service discovery
   
   check  coredns two pods in namespace  kube-system ``kubectl get pods -n kube-system``
   
   the two dns pods are running as two deployments ``kubectl get deployments -n kube-system``
   
   to check service that does dns load balancing use ``kubectl get services -n kube-system`` for compatibility the service name relates to its legacy - kube-dns
   
|
   
busybox testing container spec file

|

.. code-block:: yaml
   
   apiVersion: v1
   kind: Pod
   metadata:
     name: busybox
     namespace: default
   spec:
     containers:
     - image: busybox:1.28.4
       command:
         - sleep
         - "3600"
       imagePullPolicy: IfNotPresent
       name: busybox
     restartPolicy: Always
    
|

testing dns
   create ``busybox`` pod ``cubectl create -f busybox.yaml``
   
   verify ``kubectl get pods``
   
   for each pod created, there is also a new dns entry and ``resolv.conf`` file
   
   to see it run ``kubectl exec -it busybox -- cat /etc/resolv.conf``
   
   look up the dns name for the native kubernetes service ``kubernetes`` name resolution ``kubectl exec -it busybox -- nslookup kubernetes``
   
   it is possible to use nslookup with hostname, that is ip addresses seperated by dashes not dots
   
   look up and choose ip address of one the pods ``kubectl get pods -o wide``
   
   verify certain pod dns resolution ``kubectl exec -ti busybox -- nslookup $pod-ip-address.default.pod.cluster.local``
   
   verify service in cluster - here ``kube-dns`` service in ``kube-system`` namespace ``kubectl exec -it busybox -- nslookup kube-dns.kube-system.svc.cluster.local``
   
   to search core-dns or other service logs, get the service pod name first ``kubectl get pods -n kube-system``
   
   run ``kubectl logs $coredns-or-other-service-pod-name``
   
headles services
   service without cluster ip
   
   responds with a set of ip addresses instead of a single one
   
   each pointing to ip address of individual pod that backs a particular service
   
|

spec file  for a headless service
   ``clusterIP`` is set to ``none``, once deployed, dns servere will return and populate that field with pod or pods ip addresses instead of single service ip that would have been there if cluster ip was present

|

.. code-block:: yaml

   apiVersion: v1
   kind: Service
   metadata:
     name: kube-headless
   spec:
     clusterIP: None
     ports:
     - port: 80
       targetPort: 8080
     selector:
       app: kubserve2

|

dns policies
   can be set on a per pod basis 
   
   by default it is cluster first, which will inherit name resolution config from the node that pod is on
   
   to override default dns policy - dns policy has to be set to ``none`` and configure own dns names, servers, searches and other options, example custom-dns.yaml below
   
   once custom dns file is deployed ``kubectl create -f custom-dns.yaml`` pod, the pod get all the information in ``/etc/resolv.conf`` resolv.conf file
   
|

.. code-block:: yaml

   apiVersion: v1
   kind: Pod
   metadata:
     namespace: default
     name: dns-example
   spec:
     containers:
       - name: test
         image: nginx
     dnsPolicy: "None"
     dnsConfig:
       nameservers:
         - 8.8.8.8
       searches:
         - ns1.svc.cluster.local
         - my.dns.search.suffix
       options:
         - name: ndots
           value: "2"
         - name: edns0   

|

contents_

|

pod scheduling
--------------

|

single scheduler configuration
==============================

|

pod scheduler
   responsible for assigning a pod to a node - decides which node is best to host a pod based on default rules
   
   default rules can be customized, for example to save costs direct all pods to one node or some pods have ssd disks some optical once and some workloads would require faster drives, some not
   
   default rules
      8 criteria points
      
      1. is node having adequate garware resources
      
      2. is node running out of the resources (cpu, disk, memmory)
      
      3. check if the request is to be scheluded to a specific node by name
      
      4. verify if a node has a label matching the node selector in the pods back
      
      5. check if the pod is requesting to be bound to a specific port and if yes, is that node port available
      
      6. test if a node has a specific type fo volume, can that volume be mounted and if differnt pods are using th same volume
      
      7. check if the pod can tolerate taints of the node, for example master node is tainted with no schedule - meaning no pause wiil be applied to it as it is a master
      
      there might be custom taints such as environment, for example if it equals production and pods would not be intended to run on production nodes, unless that intent was specifically defined / toleration set, defining that they can run on production nodes
      
      8. verify if a pod is specyfing pod or node affinity rules, and if scheduling to the node would violate these rules
      
   the sheduler may have more than one suitable node to host a pod, in such case it prioritisez and picks the best node
   
   if few nodest are equally at highest priority, the scheduler selects one in round robin manner
   
|

node afinity rules
   allow to have an impact on scheduling prioritization by the use of lables and weight
   
   as example four labels are assigned to two nodes - availibility zone and share-type
   
   ``kubectl label node $hostname.myServer1.com availability-zone=zone1``
   
   ``kubectl label node $hostname.myServer1.com  share-type=dedicated``
   
   ``kubectl label node $hostname.myServer2.com availability-zone=zone2``
   
   ``kubectl label node $hostname.myServer2.com  share-type=shared``
   
   below yaml example of node afinity rules, represents 80% intent to deploy pods to nodes labelled as ``Zone1`` and also to intent (four times smaller) deploy pods to nodes labeled as ``shared`` - zone preference 4 times more important than share-type state
   
   when these rules are implemented in cluster of 6 pods, 5 ended on server1 in az zone1 and 6th pod got assigned to server2 in shared nodes space (share-type=shared)
   
   
   
   ``preferredDuringSchedulingIgnoredDuringExecution`` states that below rules do not affect pods already running on a node
   
|

.. code-block:: yaml

   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: pref
   spec:
     selector:
       matchLabels:
         app: pref
     replicas: 5
     template:
       metadata:
         labels:
           app: pref
       spec:
         affinity:
           nodeAffinity:
             preferredDuringSchedulingIgnoredDuringExecution:
             - weight: 80
               preference:
                 matchExpressions:
                 - key: availability-zone
                   operator: In
                   values:
                   - zone1
             - weight: 20
               preference:
                 matchExpressions:
                 - key: share-type
                   operator: In
                   values:
                   - dedicated
         containers:
         - args:
           - sleep
           - "99999"
           image: busybox
           name: main

|

selector spread priority function
   second type of a way to customize scheduling
   
   it ensures that pods within single replica spread around different nodes to avoid downtime and maintain hig availibility
   
|

contents_

|

multiple schedulers configuration
=================================

|

use of multiple schedulers
   it is possible to use in single cluster multiple schedulers
   
   for example assign one part of pods to default scheduler and  other pods part to a custom scheduler

|

configuration    
   detailed information can be found at 
   
   https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/
   
   configuration involves 
   
   1. package the scheduler 
   
   2. define pod deployment of the scheduler (my-scheduler.yaml)
   
   copy the template from kubernetes website and replace image value to the packaged scheduler name (step 1)
   
   
   3.  commence authentication and authorisation configuration
   
   cluster role and cluster crole binding has to be defined in order to have a secret mounted to a pod in kube-system namespace
   
   the cluster role binding will link service account of my-scheduler with the cluster role 
   
   4. apply both the role and the binding 
   
   ``kubectl create -f ClusterRole.yaml``

   ``kubectl create -f ClusterRoleBinding.yaml``

   5. to enable scheduler to communicate to a pod and an to ba able to schedule the pod to nodes role and role binding needs to be created
  
   the role binding will link user - kubernetes-admin with the role 

   6. apply both the role and the binding 

   ``kubectl create -f Role.yaml``

   ``kubectl create -f RoleBinding.yaml``
   
   7. edit existing kube-scheduler cluster role to finish authentication and authorisation configuration
   
   ``kubectl edit clusterrole system:kube-scheduler``

      - apiGroups:
        - ""
        resourceNames:
        - kube-scheduler
        - my-scheduler # <-- add my scheduler along with kube-scheduler 
        resources:
        - endpoints
        verbs:
        - delete
        - get
        - patch
        - update
      - apiGroups:
        - storage.k8s.io # <-- add storage
        resources:
        - storageclasses # <-- add storage classes
        verbs:
        - watch
        - list
        - get
   
   8. deployment of the new custom scheduler as pod in kube-system namespace 
   
   ``kubectl create -f my-scheduler.yaml``
   
   9. verify the scheduler pod ``kubectl get pods -n kube-system``
   
   both kube-scheduler (default) an my-scheduler shoul be present


|

spec files defining custom scheduler, roles and bindings

|

my-scheduler.yaml template

|

.. code-block:: yaml

   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: my-scheduler
     namespace: kube-system
   ---
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRoleBinding
   metadata:
     name: my-scheduler-as-kube-scheduler
   subjects:
   - kind: ServiceAccount
     name: my-scheduler
     namespace: kube-system
   roleRef:
     kind: ClusterRole
     name: system:kube-scheduler
     apiGroup: rbac.authorization.k8s.io
   ---
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRoleBinding
   metadata:
     name: my-scheduler-as-volume-scheduler
   subjects:
   - kind: ServiceAccount
     name: my-scheduler
     namespace: kube-system
   roleRef:
     kind: ClusterRole
     name: system:volume-scheduler
     apiGroup: rbac.authorization.k8s.io
   ---
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     labels:
       component: scheduler
       tier: control-plane
     name: my-scheduler
     namespace: kube-system
   spec:
     selector:
       matchLabels:
         component: scheduler
         tier: control-plane
     replicas: 1
     template:
       metadata:
         labels:
           component: scheduler
           tier: control-plane
           version: second
       spec:
         serviceAccountName: my-scheduler
         containers:
         - command:
           - /usr/local/bin/kube-scheduler
           - --address=0.0.0.0
           - --leader-elect=false
           - --scheduler-name=my-scheduler
           image: gcr.io/my-gcp-project/my-kube-scheduler:1.0 # <-- replace it with own scheduler package name 
           livenessProbe:
             httpGet:
               path: /healthz
               port: 10251
             initialDelaySeconds: 15
           name: kube-second-scheduler
           readinessProbe:
             httpGet:
               path: /healthz
               port: 10251
           resources:
             requests:
               cpu: '0.1'
           securityContext:
             privileged: false
           volumeMounts: []
         hostNetwork: false
         hostPID: false
         volumes: []
         
|

ClusterRole.yaml

|

.. code-block:: yaml

   apiVersion: rbac.authorization.k8s.io/v1beta1
   kind: ClusterRole
   metadata:
     name: csinodes-admin
   rules:
   - apiGroups: ["storage.k8s.io"]
     resources: ["csinodes"]
     verbs: ["get", "watch", "list"]

|

ClusterRoleBinding.yaml

|

.. code-block:: yaml

   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRoleBinding
   metadata:
     name: read-csinodes-global
   subjects:
   - kind: ServiceAccount
     name: my-scheduler
     namespace: kube-system
   roleRef:
     kind: ClusterRole
     name: csinodes-admin
     apiGroup: rbac.authorization.k8s.io

|

Role.yaml

|

.. code-block:: yaml

   apiVersion: rbac.authorization.k8s.io/v1
   kind: Role
   metadata:
     name: system:serviceaccount:kube-system:my-scheduler
     namespace: kube-system
   rules:
   - apiGroups:
     - storage.k8s.io
     resources:
     - csinodes
     verbs:
     - get
     - list
     - watch
     
|

RoleBinding.yaml

|

.. code-block:: yaml

   apiVersion: rbac.authorization.k8s.io/v1
   kind: RoleBinding
   metadata:
     name: read-csinodes
     namespace: kube-system
   subjects:
   - kind: User
     name: kubernetes-admin
     apiGroup: rbac.authorization.k8s.io
   roleRef:
     kind: Role 
     name: system:serviceaccount:kube-system:my-scheduler
     apiGroup: rbac.authorization.k8s.io

|

scheduling pods to multiple schedulers
   for sample purposes 3 pods are defined and deployed below, where 

   - pod1 - no specific annotation - hence it will use default scheduler

   - pod2 - explicitly specified default scheduler  
   
   - pod3 - explicitly specified custom scheduler
   
   ``kubectl create -f pod1.yaml`` ``kubectl create -f pod2.yaml`` ``kubectl create -f pod3.yaml``
   
   verify pods ``kubectl get pods -o wide``
   
|

all 3 pods spec files below

|

.. code-block:: yaml   

   # pod1.yaml
   
   apiVersion: v1
   kind: Pod
   metadata:
     name: no-annotation
     labels:
       name: multischeduler-example
   spec:
     containers:
     - name: pod-with-no-annotation-container
       image: k8s.gcr.io/pause:2.0
   
   # pod2.yaml
   
   apiVersion: v1
   kind: Pod
   metadata:
     name: annotation-default-scheduler
     labels:
       name: multischeduler-example
   spec:
     schedulerName: default-scheduler
     containers:
     - name: pod-with-default-annotation-container
       image: k8s.gcr.io/pause:2.0
   
   # pod3.yaml
   
   apiVersion: v1
   kind: Pod
   metadata:
     name: annotation-second-scheduler
     labels:
       name: multischeduler-example
   spec:
     schedulerName: my-scheduler
     containers:
     - name: pod-with-second-annotation-container
       image: k8s.gcr.io/pause:2.0
       
|

contents_

|

resource limits and label selectors
===================================

|

taints
   nodes get tainted in order to repel work - stop being scheduled to perform certain workloads
   
   master node is one of examples ``kubectl describe node $master-node-name``
   
   at the top of description `taints`` value contains ``node-role.kubernetes.io/master.NoSchedule``


|

tolerations
   allow to tollarate a taint 
   
   toleration can be added to pod's yaml 
   
   if the toleration of new schedule is included, potantially a pod  can be sceduled to run on the node - even if it is a master
   
   example - kube-proxy 
   
   copy full kube-proxy name from ``kubectl get pods -n kube-system``
   
   ``kubectl get pods $kube-proxy-name -n kube-system -o yaml``
   
   on top of the output check ``tolerations`` section and the coresponding values 
      
        effect: NoSchedule
      
        key: node.kubernetes.io/unschedulable
        
        operator: Exists
   
   this means that this pod (kube-proxy) is to tolerate a node that is unschedulable - necessary tolaration for kube-proxy as it ia a deamon set pod that needs to run on every single node 
   
   with no further consideration, a pod will not be scheduled to a node that is tainted, unless it has a tolaration for that node

|

cpu and memory requests
   scheduler does not check each individual resource to establish the best node
   
   scheduler uses a sum of resources requested by existing pods deployed on that node, this is because the pod may not be utilizing all requested resource at any particular time and the pods on that node should be allowed to utilise all requested resources  
   
   once default scheduler checks the 8 criteria points to check best node suitability to host a particular pod, it then moves to prioritisation
   
   prioritisation may involve 
   
   - least requested priority function
      choses nodes that have least amount of resources requested to more evenly distribute pods to the nodes
   
   or
   
   - most requested priority function
      choses nodes that have the largest sum of requested resources

      this option allows to sqeeze as many pods to possibly smallest number of nodes - cost savings - smallest number of machines to run the cluster
      
   most or least requested priority preference is to be set within the scheduler

   to verify nodes capacity run ``kubectl describe nodes``
   
   output is to contain sections
   
   ``capacity`` - describing entire node's capacity
   
   ``allocatable`` - stating what is available to allocate 
   
   if a pod is scheduled but it remains in pending state run ``kubectl describe pods $name-of-pod``
   
   if it reqested excessive resources from node, in events section of the output warning may be found ``FailedScheduling`` and reason such as insufficient cpu or memory, etc. 
   
   to verify current utilization of a node, run ``kubectl describe nodes $node-name` and check output's bottom section ``non terminated pods`` that list currently running pods on this node and their use of resources
   
   the output also shows ``allocated resources`` that  will guide what resources may still be available on this particular node
   
|

cpu sharing
   if there are two pods on a node and one is idle, the other will consume all cpu if it needs it
   
   if both pods are using actively the cpu and some spare cpu power remains on the node (cpu above the sum of two requested amounts), the extra cpu will be divided proprtionally to the pods original reqests
   
   for example if pod1 requested 200 mCores and pod2 requested 1000 mCores, then the ratio would be 1 to 5
   
   pod1 will get allocated 1/6 of spare cpu, pod2 will get remaining 5/6 of the cpu excess

|

memory sharing
   once memory is requested, the requesting pod may consume entire memory and not release it until the process is finished
   
   this can take down the whole node
   
   to avoid this risk ``resource limits`` can be configured to put a cap / limit on the size of memory a pod can use
   
   
   
   
   
   
   
|

resource requests
   defines what size of resources a pod needs to run on a specific node

|

spec file containing resource ``requests``

|

.. code-block:: yaml

   apiVersion: v1
   kind: Pod
   metadata:
     name: resource-pod1
   spec:
     nodeSelector:
       kubernetes.io/hostname: "my-server1"
     containers:
     - image: busybox
       command: ["dd", "if=/dev/zero", "of=/dev/null"]
       name: pod1
       resources:
         requests:
           cpu: 800m
           memory: 20Mi

|

resource limits
   when defining a limit, the limit in background sets a request that is equivalent to the limit
   
   as in the exmple, limits are set to one cpu and memory to 20 MB, the request is not explicitely defined but it is automatically set to the same values as limits
   
   pods limits can go beyond total utilization of cpu and memory on a node and still be allowed to be deployed, 
   
   once kubernetes sens that more resources are being used compared to what is available, the pod that requested excessive resources will get killed
   
|

spec file containing resource ``limits``

|

.. code-block:: yaml

   apiVersion: v1
   kind: Pod
   metadata:
     name: limited-pod
   spec:
     containers:
     - image: busybox
       command: ["dd", "if=/dev/zero", "of=/dev/null"]
       name: main
       resources:
         limits:
           cpu: 1
           memory: 20Mi

|

contents_

|

daemonsets and manual scheduling
================================

|

daemonsets
   daemonsets are capable to deploy a pod on each node
   
   good solution for pods requiring to run exactly one replica and the need is to have one on each node

   in this approach sheduler is not being used as deamonsets have special instruction to
   
   - run a pod on a specific node
   
   - automatically and instatntly initialize the pod on any new node in the cluster (this can not be done with scheduler)
   
   - instantly re-initialize deamonset pod if it gets deleted on any of the existing pods 
   
   when deamonset pod gets created it applies pod template created within itself as in replica sets
   
   check sytem existing deamonsets ``kubectl get pods -n kube-system -o wide`` including pods on each node of kube-proxy pod, network overlay pod (flannel or other)
   
   when drianing a node for maintenance purposes ``kubectl drain $nodeNameToBeEvicted --ignore-daemonsets`` ignore-daemonsets flag was set to avoid draining them
   
   deamonsets are configured to ignore / tolerate any teit set on nodes, this is why they can even run on master node
   
   it is possible to create custom deamonset that would utilise node selector field to specify on which nodes to run
   
   if a deamonset has configured node selector, whenever a new or existing node gets labeled with matching label, the deamonset will automatically initialise on that node

|

custom deamonset sample
   solid state drive monitoring deamonset
   
   create node label stating that it has a ssd disk ``kubectl label node $node-name disk=ssd``
   
   create spec file and run it ``kubectl create -f ssd-monitor.yaml``

   check if it runs in the cluster ``kubectl get deamonsets``
   
   verify it it runs on any nodes that got previously labelled *disk=ssd* ``kubectl get pods -o wide``
   
   if a new node or existing one gets labeled *disk=ssd*, the demonset will instantly run on it as well - with no requirelment to changy anything within a deamonset
   
   if existing label is changed to one that is not matching the deamonset node selector, the deamonste pod will automatically get removed / terminated from the node 
   
   sample lable override ``kubectl label node $node-name disk=hdd --overwrite ``
   
   above override will lead to deamonser termination on the node the label was updated 
   
|

ssd-monitor.yaml deamonset spec

|

.. code-block:: yaml

   apiVersion: apps/v1
   kind: DaemonSet
   metadata:
     name: ssd-monitor
   spec:
     selector:
       matchLabels:
         app: ssd-monitor
     template:
       metadata:
         labels:
           app: ssd-monitor
       spec:
         nodeSelector:
           disk: ssd
         containers:
         - name: main
           image: my-utilities/ssd-monitor
   
|

contents_

|

monitoring scheduling events
============================

|

veryfing scheduler operation
   can be performed at level of
   
   - pod
   
   get the scheduler full pod name ``kubectl get pods -n kube-system``
   
   check scheduler pod events:``kubectl describe pods $scheduler-pod-name -n kube-system``
   
   - event
   
   see all events in the following namesaces
   
   default ``kubectl get events``

   kube-system ``kubectl get events -n kube-system``
      
   to real time events watch run ``kubectl get events -w``
   
   - log
   
   check scheduler pod logs ``kubectl logs $kube-scheduler-pod-name -n kube-system``
   
   if the scheduler is manually set up as systemd service the location of systemd service scheduler pod is ``/var/log/kube-scheduler.log``

|

contents_

|

deploying applications
----------------------

|

lifecycle - deployment, rolling updates, rollbacks
==================================================

|

application deployment
   declarative management of application lifecycle
   
   in deployments use --record flag to store the command in revision history that might be useful in potential rollbacks ``kubectl create -f kubeserve-deployment.yaml --record`

   verify status of the deployment ``kubectl rollout status deployments kubeserve``

   deployment add a string of numbers to the end of each pod's name - hash value of 
   
   - pod template
   
   - deployment 
   
   and 
   
   - replica set that manages the pot
   
   deployment automatically generates replica set, cluster set can be checked by ``kubectl get replicasets``
   
   replica set name contains hash value of its pod template as well 
   
   to sclae deployment run ``kubectl scale deployment kubeserve --replicas=5``
   
   to simulate app, sertvice may be created ``kubectl expose deployment kubeserve --port 80 --target-port 80 --type NodePort``
   
   verify it ``kubectl get services`` 

|

sample kubeserve-deployment.yaml spec

|

.. code-block:: yaml

   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: kubeserve
   spec:
     replicas: 3
     selector:
       matchLabels:
         app: kubeserve
     template:
       metadata:
         name: kubeserve
         labels:
           app: kubeserve
       spec:
         containers:
         - image: my-images/kubeserve:v1
           name: app

|

application deployment updates
   kubernetes allows to update an application with no service disruption / downtime

   to be able to capture updates changes it is possible to slow down the deployment by configuring deployment minReadySeconds attribute

   ``kubectl patch deployment kubeserve -p '{"spec": {"minReadySeconds": 10}}'``

   to simulate update to application deployment, spec image version can be edited to simulate the transition from v1 to v2

   ``spec : containers: image: my-images/kubeserve:v1 --> kubeserve:v2``

   change impementation can be done in thre ways

   - apply
      ``kubectl apply -f kubeserve-deployment.yaml``

      with this approach if old depoyment did not exist a new deployment will get created

      may involve downtime

   - replace
      ``kubectl replace -f kubeserve-deployment.yaml``

      in this approach previous (v1) deployment has to exist to be replaced, otherwise replace will fail

      may involve downtime

   - rolling update
      this method involves no downtime / interraption to service 

      behind scenes the rolling update
      - creates new replica set and spins within it new pods based on new container image

      - as the new pods in new replica set got created, the roling update starts to terminate pods in old replica set

      - all this happen in gradual manner, transitioning from 

         - old replica - v1

         - old and new replica running at the same time v1 and v2

         - new replica v2

      it is the quickets of the three update methods

      it involves changing an image in pod's container instead of updating pod spec yaml files

      to observe real time changes during the update of the service curl loop command ,ight be used ``while true; do sleep 1; curl $service-ip-or-url; done``

      rolling update command 

      ``kubectl set image deployments/kubeserve app=mu-app-images/kubeserve:v2 --v 6``

      check changes after the apply or replace ``kubectl describe deployments``

      check replica sets ``kubectl get replicasets``

      check replica sets details ``kubectl describe replicasets kubeserve-[hash]``

|

application rollbacks from bugged updates
   a bugged version v3 has been introduced
   
   ``kubectl set image deployments/kubeserve app=mu-app-images/kubeserve:v3 --v 6``
   
   quck rollout can be performed to recover to the very previous version (v2)
   
   ``kubectl rollout undo`` is possible because the deployments keep revisions history and the history is stored in previous copies of replicasets 
   
   ``kubectl rollout undo deployments kubeserve``
   
   see rollout history ``kubectl rollout history deployment kubeserve``
   
   rollout history contains column ``change-casue`` that displays information about the command used to perform a change - important detail in troubleshooting 
   
   change-casue stores information thanks to --record flag set in ``kubectl create -f kubeserve-deployment.yaml --record``
   
   from the output note revision number and copy to next command if rollout to specific version is required
   
   roll back to a specific revision

   ``kubectl rollout undo deployment kubeserve --to-revision=2``
   
   pause rollout in the middle of a rolling update - canary release - so part of application will run on old replicaset and parto on new replicaset 

   ``kubectl rollout pause deployment kubeserve``

   once the rolling update is fully tested - resume  rollout to fully transition to new replica set - new version of the application

   ``kubectl rollout resume deployment kubeserve``
           
|

contents_

|


high availibility 
=================

|

minReadySeconds
   this attribite specifies how long a newly created pod should remain in ready state before the pod is being considered available
   
   rolout will not continue untill the pod is in available state
   
   if minReadySeconds is set to 10, pod would have to report healthy state for 10 consecutive seconds before the pod could get relased
   
   too long minReadySeconds in relation to readines probe intervals could casue an issue

|

readiness probe
   it verifies if a specific pod is ready to receive client requests or not
   
   once it returns success, it communicates to a pod that it is ready to take requests
   
   below readiness probe is set to perform check each second to ensure responsivness of the application

|

readiness probe - kubeserve-deployment-readiness.yaml

|

.. code-block:: yaml

   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: kubeserve
   spec:
     replicas: 3
     selector:
       matchLabels:
         app: kubeserve
     minReadySeconds: 10
     strategy:
       rollingUpdate:
         maxSurge: 1
         maxUnavailable: 0
       type: RollingUpdate
     template:
       metadata:
         name: kubeserve
         labels:
           app: kubeserve
       spec:
         containers:
         - image: my-app-containers/kubeserve:v3
           name: app
           readinessProbe:
             periodSeconds: 1
             httpGet:
               path: /
               port: 80

|

high availibility
   to prevent deployments from updating into broken, buggy versions, ``minReadySeconds`` attribute can be set to slow down the deployment of new updates

   ``kubectl patch deployment kubeserve -p '{"spec": {"minReadySeconds": 10}}'``
   
   in tandem with minReadySeconds, deployments also use readines probes to minimize posibility of bad updates
   
   update current deployment wit readiness probes set up
   
   ``kubectl apply -f kubeserve-deployment-readiness.yaml``
   
   verify rollout status
   
   ``kubectl rollout status deployment kubeserve``

|

contents_

|

passing env variables, configmap and secrets
============================================

|

*passing configuration options to an application*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes-app-ha.png
   
   :alt: passing configuration options to an application
|

passing configuration options to an application
   environment variables are commonly used instead of having application reading configuration files or cli arguments
   
   application can be configured to look up values of particular environment variables
   
   frequently, these env variables contain passwords, keys, secrets - information that can not be available to all people that have access to images
   
   in kubernetes the configuration data may be stored in ``configmap`` and pass it to a container through environment variable
   
   if sensitive data needs to be passed, a secret can be created and passed as environmental variable
  
   once configmap and secrets are created, they can be modified with no need to rebuild an image
  
   single configmap and secret can be referenced by multiple containers

|

configmap set up
   it can be configured in two ways
   
   as pod
      configmap with single key

      ``kubectl create configmap appconfig --from-literal=key1=value1``

      configmap with two keys

      ``kubectl create configmap appconfig --from-literal=key1=value1 --from-literal=key2=value2``

      define configmap-pod.yaml spec file to reference configmap named appconfig and its keys

      create pod that will be passing the configmap data

      ``kubectl apply -f configmap-pod.yaml``

      show YAML  spec file from the configmap

      ``kubectl get configmap appconfig -o yaml``

      show logs from the pod presenting the value

      ``kubectl logs configmap-pod``
   
   as mounted volume
      the volume is to be attached / monted and accessible by a container
      
      container will allow an application to retrive data from the volume
      
      **plain text set up**
      
      create the configmap volume pod

      ``kubectl apply -f configmap-volume-pod.yaml``
      
      access keys from the volume on the container
      
      ``kubectl exec configmap-volume-pod -- ls /etc/config``
      
      and values 
      
      ``kubectl exec configmap-volume-pod -- cat /etc/config/key1``
      
      
      **use of secrets**
      
      to avoid saving data as plain text, secrets need to be implemented
      
      create secrets spec file and run it ``kubectl apply -f appsecret.yaml``
      
      create spec file for a pod using the secret and create a pod that has secret data attched
      
      ``kubectl apply -f secret-pod.yaml``
      
      open shell to echo environment variable

      ``kubectl exec -it secret-pod -- sh``
      
      ``echo $MY_CERT``
      
      create pod spec file that will access the secret from a volume - secret-volume-pod.yaml
      
      run the pod with volume attached with secrets
      
      ``kubectl apply -f secret-volume-pod.yaml``
      
      check keys from the volume mounted to the container with the secrets:

      ``kubectl exec secret-volume-pod -- ls /etc/certs``
       
|

configmap-pod.yaml spec file

|

.. code-block:: yaml

   apiVersion: v1
   kind: Pod
   metadata:
     name: configmap-pod
   spec:
     containers:
     - name: app-container
       image: busybox:1.28
       command: ['sh', '-c', "echo $(MY_VAR) && sleep 3600"]
       env:
       - name: MY_VAR
         valueFrom:
           configMapKeyRef:
             name: appconfig
             key: key1
   
|

configmap-volume-pod.yaml spec file

|

.. code-block:: yaml

   apiVersion: v1
   kind: Pod
   metadata:
     name: configmap-volume-pod
   spec:
     containers:
     - name: app-container
       image: busybox
       command: ['sh', '-c', "echo $(MY_VAR) && sleep 3600"]
       volumeMounts:
         - name: configmapvolume
           mountPath: /etc/config
     volumes:
       - name: configmapvolume
         configMap:
           name: appconfig

|

appsecret.yaml spec file

|

.. code-block:: yaml

   apiVersion: v1
   kind: Secret
   metadata:
     name: appsecret
   stringData:
     cert: value
     key: value

|

secret-pod.yaml spec file

|

.. clode-block:: yaml

   apiVersion: v1
   kind: Pod
   metadata:
     name: secret-pod
   spec:
     containers:
     - name: app-container
       image: busybox
       command: ['sh', '-c', "echo Hello, Kubernetes! && sleep 3600"]
       env:
       - name: MY_CERT
         valueFrom:
           secretKeyRef:
             name: appsecret
             key: cert

|

secret-volume-pod.yaml spec file

|

.. code-block:: yaml

   apiVersion: v1
   kind: Pod
   metadata:
     name: secret-volume-pod
   spec:
     containers:
     - name: app-container
       image: busybox
       command: ['sh', '-c', "echo $(MY_VAR) && sleep 3600"]
       volumeMounts:
         - name: secretvolume
           mountPath: /etc/certs
     volumes:
       - name: secretvolume
         secret:
           secretName: appsecret

|

contents_

|

self healing applications
=========================

|

*replicaSets*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes-self-healing-app.png
   
   :alt: replicasets

|

replica sets
   eliminates a need to continously watch servers for errors to keep applications running
   
   if errors happen, kubernetes replace the server and removes the faulty server or application image
   
   these capabilities are possible thanks to deployments and replica sets
   
   replica sets ensure that many replica sets of a particular pod are running throughout the cluster
   
   even if whole node goes down, ther would be zero downtime
   
   this is atomatically done by creating replicas and hosting them on nodes in good health state
   
   this liberates operation teams from performing manual migrations of application components
   
   replica sets labels - if it contains labels, any pods that have matching label with replica set will be automatically picked up by the replica
   
   create replica set ``kubectl apply -f replicaset.yaml``
   
   if replica set is configured to have 3 replicas that are already running
   
   and another pod gets created with same label as replicaset
   
   it will get terminated as replicaset is running desired 3 pods already
   
   if a lebel of pod within replicaset is changed it will get removed from replicaset
   
   removing a pod from replicaset in such way is not recommended as management of replicaset should be done via deployments 
   
|

*replicaste.yaml spec file*

|
   
.. code-block:: yaml
   
   apiVersion: apps/v1
   kind: ReplicaSet
   metadata:
     name: myreplicaset
     labels:
       app: app
       tier: frontend
   spec:
     replicas: 3
     selector:
       matchLabels:
         tier: frontend
     template:
       metadata:
         labels:
           tier: frontend
       spec:
         containers:
         - name: main
           image: linuxacademycontent/kubeserve
|

*pod-replica.yaml spec file with same label as replicaset*

|

.. code-block:: yaml

   apiVersion: v1
   kind: Pod
   metadata:
     name: pod1
     labels:
       tier: frontend
   spec:
     containers:
     - name: main
       image: linuxacademycontent/kubeserve

|

statefulsets
   same as replicasets they allow to keep constant number of relicas alive
   
   but the pods within statful sets are all unique (not originating from single replicaset pod template)
   
   if a pod goes down it is replaced by a pod with the same hostname and configuration
   
   a service in statefulsets must be headless, as every single pod will be unique
   
   specific traffic has to go to specific pods 
   
   sets' spec files contains volume claim template
   
   as each pod in the set is unique it needs own storage
   
   run the set ``kubectl apply -f statefulset.yaml``
   
   verify it ``kubectl get statefulsets`` ``kubectl describe statefulsets``

|

statefulset.yaml spec file

|

.. code-block:: yaml

   apiVersion: apps/v1
   kind: StatefulSet
   metadata:
     name: web
   spec:
     serviceName: "nginx"
     replicas: 2
     selector:
       matchLabels:
         app: nginx
     template:
       metadata:
         labels:
           app: nginx
       spec:
         containers:
         - name: nginx
           image: nginx
           ports:
           - containerPort: 80
             name: web
           volumeMounts:
           - name: www
             mountPath: /usr/share/nginx/html
     volumeClaimTemplates:
     - metadata:
         name: www
       spec:
         accessModes: [ "ReadWriteOnce" ]
         resources:
           requests:
             storage: 1Gi
   
|

contents_

|

data
----

|

persistent volumes
==================

|

storage
   pods are ephermal - each time pod gets terminated, its file system is also gone
   
   storage has to be independent - decoupled to live beyond conteiner's life
   
   if a container changes pod the storage has to move as well
   
   kubernetes offers persistent volumes functionality

|

persistent volume configuration - manual steps
   google cloud - gcp persitent storage
   
   confirm cluster region ``gcloud container clusters list``

   create a persistent disk in cluster region

   ``gcloud compute disks create --size=1GiB --zone=us-central1-a mongodb``

   create a spec file to run a pod with disk attached and mounted

   ``kubectl apply -f mongodb-pod.yaml``

   check the node on which the pod executed ``kubectl get pods -o wide``

   check if connection can be made from other pod and initialise mongodb shell

   ``kubectl exec -it mongodb mongo``

   switch to mystore

   mongodb-shell> ``use mystore``

   create a samlpe json document

   mongodb-shell> ``db.foo.insert({name:'foo'})``

   check the inserted document

   mongodb-shell> ``db.foo.find()``

   mongodb-shell> ``exit`` 

   to test if volume is persistent, delete the pod to verify later if data would be accessible from persistent disk

   ``kubectl delete pod mongodb``

   create a new pod with same attached disk - same spec file ``kubectl apply -f mongodb-pod.yaml``

   verify node the pod executed on ``kubectl get pods -o wide``

   if the pod is on same node as previously - drain it

   apart from draining the command also changes the node status to ``schedulingDisabled``

   ``kubectl drain $node-name --ignore-daemonsets``

   access mongodb shell (once pod is on a different node) ``kubectl exec -it mongodb mongo``

   switch to mystore db 

   mongodb-shell> ``use mystore``

   check document previously created

   mongodb-shell> ``db.foo.find()``

|

*mongodb-pod.yaml spec file*

|

.. code-block:: yaml

   apiVersion: v1
   kind: Pod
   metadata:
     name: mongodb 
   spec:
     volumes:
     - name: mongodb-data
       gcePersistentDisk:
         pdName: mongodb
         fsType: ext4
     containers:
     - image: mongo
       name: mongodb
       volumeMounts:
       - name: mongodb-data
         mountPath: /data/db
       ports:
       - containerPort: 27017
         protocol: TCP
         
|

persinstent volumes object - pv resource
   more infrustructure abstracted and automated approach
   
   create persistent volume spec file and launch pv resource / object

   ``kubectl apply -f mongodb-persistentvolume.yaml``

   veriify it ``kubectl get pv``

|

*mongodb-persistentvolume.yaml spec file*

|
 
.. code-block:: yaml

   apiVersion: v1
   kind: PersistentVolume
   metadata:
     name: mongodb-pv
   spec:
     capacity: 
       storage: 1Gi
     accessModes:
       - ReadWriteOnce
       - ReadOnlyMany
     persistentVolumeReclaimPolicy: Retain
     gcePersistentDisk:
       pdName: mongodb
       fsType: ext4
   
|

contents_

|

volumes access modes
====================

|

access modes
   when creating the vloume access modes has to be specified
   
   this information enables the volume to be mounted on one or many nodes and to be read from and written to by one or multiple nodes
   
   three access modes
      - rwo (read write once)

      only a single node can mount this volume for reading and writing

      - rox (read only many)

      multiple nodes can mount this volume for reading only

      - rwx (read write many)

      multiple nodes can mount this volume for reading and writing
   
   capability to mount a volume relates to node' capability not pod's capability
   
   volume can only be mounted using one access mode at a time - even if it supports many
   
   to illustrate, google cloud disk can be mounted as rwo (read write once) by a single node
   
   or at a different time as rox (read only many) by multiple nodes - but not simultenesly
   
   it is not possible to have this node writing this volume and then read by a totally different node at the same moment
   
   while utilising persistent volumes inside a pod, persistent volume claim has to be referenced
   
|

contents_

|

persistent volume claims - pvc
==============================

|

*pv claims*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes-pv-claims.png
   
   :alt: pv claims

|

persistent volume claims - pvc
   it is a pod's request to utilise  / preserve already provisioned storage volume
   
   these claims are usually done by development teams requesting application access to a storage
   
   the storage can not be directly utilzed within a pod
   
   to pod to have a right to use the storage must make a claim
   
   the claim remains with the persinent volume and is independent from pod that might get terminated
   
   pv claim is a separate resource in kubernetes
   
   set up pvc
      create pvc spec file and run it ``kubectl apply -f mongodb-pvc.yaml``
   
      before the pvc is created, system checks if requested size and access mode matches to what is available 

      if both conditions are matched - requested size and access mode are available, then the volume is to be bound to the claim 

      to list cluster's pvc run ``kubectl get pvc``

      to list pv run ``kubectl get pv``
      
      create pod spec file that would be utilising the pvc, apply it
      
      ``kubectl apply -f mongo-pvc-pod.yaml``
      
      both ``kubectl get pvc`` and ``kubectl get pv`` should now show status ``bound``
      
   test pvc   
      open mogodb shell ``kubectl exec -it mongodb mongo``
      
      switch to mystore

      mongodb-shell> ``use mystore``

      search for the previously created json document

      mongodb-shell> ``db.foo.find()``

      delete mongodb pod ``kubectl delete pod mongodb``

      remove mongodb-pvc PVC ``kubectl delete pvc mongodb-pvc``

      verify it ``kubectl get pv`` status should now show ``released``
      
      ``released`` status is caused by the reclaim policy set to ``retain`` 
      
      reclaim policy can was specified in the original pv spec file (mongodb-persistentvolume.yaml)
      
      reclaim policies can be set to
      
      - retain - volume data will be retained / kept available within the volume
      
      - rycycle - volume data will be deleted in order to reuse the volume for a new persistent volume claim
      
      - delete - the uderlying storage volume is to be deleted

|

*mongodb-pvc.yaml spec file*

|

.. code-block:: yaml

   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: mongodb-pvc 
   spec:
     resources:
       requests:
         storage: 1Gi
     accessModes:
     - ReadWriteOnce
     storageClassName: ""
     
|

*mongodb-pvc-pod.yaml spec file*

|

.. code-block:: yaml

   apiVersion: v1
   kind: Pod
   metadata:
     name: mongodb 
   spec:
     containers:
     - image: mongo
       name: mongodb
       volumeMounts:
       - name: mongodb-data
         mountPath: /data/db
       ports:
       - containerPort: 27017
         protocol: TCP
     volumes:
     - name: mongodb-data
       persistentVolumeClaim:
         claimName: mongodb-pvc

|

*mongodb-persistentvolume.yaml - pv spec file showing its reclaim policy*

|

.. code-block:: yaml

   apiVersion: v1
   kind: PersistentVolume
   metadata:
     name: mongodb-pv
   spec:
     capacity: 
       storage: 1Gi
     accessModes:
       - ReadWriteOnce
       - ReadOnlyMany
     persistentVolumeReclaimPolicy: Retain
     gcePersistentDisk:
       pdName: mongodb
       fsType: ext4   

|

contents_

|

storage objects and storage classes
===================================

|

storage object in use protection
   once persistent volume claim - pvc is attached to a volume, storage objects in use protection offers a protaction against loss of data
   
   it ensures that pvc can not be prematurely removed
   
   storage oject mechanism - sample
      check pv protection on a volume ``kubectl describe pv mongodb-pv``      

      check pvc protection for a claim ``kubectl describe pvc mongodb-pvc``
      
      under finalizers in both describe pv and pvc outputs ``pv-protection`` and ```pvc-protection`` shows
      
      delete the pv claim - pvc ``kubectl delete pvc mongodb-pvc``
      
      verify ``kubectl get pvc`` - pvc got terminated, but the volume is still attached to pod 

      with just deleted pvc, attempt to access to data ``kubectl exec -it mongodb mongo``
      
      mongodb-shell> use mystore
      
      mongodb-shell>db.foo.find()
      
      all access still fine, pod is still attached to the the persistent volume

      delete the pod, which finally deletes the PVC:

      ``kubectl delete pods mongodb``

      the pvs is now completely deleted:

      ``kubectl get pvc``

|

storage class
  automatically provision storage with no need to create storage, configuring it, etc. 
   
  storage class is an object

  in storage class object, declare what the provisioner is, everything else will get done by kubernetes

  sample configuration
    google cloud storage

    create storage class object and apply it ``kubectl apply -f sc-fast.yaml``

    verify it ``kubectl get sc``

    update previously created pv claim with storage class name : fast

    this update makes storageclass object included in the pvc 

    apply the change to automatically provision the storage

    ``kubectl apply -f mongodb-pvc.yaml``

    verify pvc ``kubectl get pvc``

    verify provisioned volume - pv ``kubectl get pv``

    pv storage is bound
   
  storage class - volume types
    apart from gcp storage other soulutions can also be used
   
    - aws - ebs volumes

    - local storage - nfs, isci, cinder, gluster fs, vsphere volume, other

    -  worker nodes - mount their file system directories via

    1. host path volume type

    2. empty directory volume type

    solution good for transient data, when it also needs to be share between multiple containers in the same pod

    volume gets deleted along with the pod

    - git repositories

    mount emptydir into initcontainer that clones the repo using git

    then mount the emptydir into pod's container
      
|

*sc-fast.yaml storage class object spec file*

|

.. code-block:: yaml

   apiVersion: storage.k8s.io/v1
   kind: StorageClass
   metadata:
     name: fast
   provisioner: kubernetes.io/gce-pd
   parameters:
     type: pd-ssd      
     
|

*mongodb-pvc.yaml updating storageClassName: fast*

|

.. code-block:: yaml

   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: mongodb-pvc 
   spec:
     storageClassName: fast
     resources:
       requests:
         storage: 100Mi
     accessModes:
       - ReadWriteOnce
 
|

*hostPath PV spec file*

|

.. code-block:: yaml

   apiVersion: v1
   kind: PersistentVolume
   metadata:
     name: pv-hostpath
   spec:
     storageClassName: local-storage
     capacity:
       storage: 1Gi
     accessModes:
       - ReadWriteOnce
     hostPath:
       path: "/mnt/data"

|

*spec file pod with an empty directory volume*

.. code-block:: yaml

   apiVersion: v1
   kind: Pod
   metadata:
     name: emptydir-pod
   spec:
     containers:
     - image: busybox
       name: busybox
       command: ["/bin/sh", "-c", "while true; do sleep 3600; done"]
       volumeMounts:
       - mountPath: /tmp/storage
         name: vol
     volumes:
     - name: vol
       emptyDir: {}

|

contents_

|

applications deployment with persistent storage
===============================================

|

*deployment of application with persistent volume*

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes-app-with-pv.png

*source linuxacademy.com*

|

**steps to perform appllication deployment with persistent volume**

|

1. create storage class object spec file

.. code-block:: yaml

  apiVersion: storage.k8s.io/v1
  kind: StorageClass
  metadata:
    name: fast
  provisioner: kubernetes.io/gce-pd
  parameters:
    type: pd-ssd

2. create pvc spec

.. code-block:: yaml

  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: kubeserve-pvc 
  spec:
    storageClassName: fast
    resources:
      requests:
        storage: 100Mi
    accessModes:
      - ReadWriteOnce

3. apply and verify storage class object

``kubectl apply -f storageclass-fast.yaml`` ``kubectl get sc``

4. apply and verify pvc

``kubectl apply -f kubeserve-pvc.yaml`` ``kubectl get pvc``

5. verify automatically provisioned pv

``kubectl get pv``

6. create deployment spec file

.. code-block:: yaml

  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: kubeserve
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: kubeserve
    template:
      metadata:
        name: kubeserve
        labels:
          app: kubeserve
      spec:
        containers:
        - env:
          - name: app
            value: "1"
          image: linuxacademycontent/kubeserve:v1
          name: app
          volumeMounts:
          - mountPath: /data
            name: volume-data
        volumes:
        - name: volume-data
          persistentVolumeClaim:
            claimName: kubeserve-pvc

7. apply the deployment with attached storage to the pods

``kubectl apply -f kubeserve-deployment.yaml``

8. verify deployment

- rollout status ``kubectl rollout status deployments kubeserve``

- pods ``kubectl get pods``

- persistant storage

  - connect to the pod to create a file on the PV

  ``kubectl exec -it [pod-name] -- touch /data/file1.txt``

  - connect to the pod to list contents of /data directory

  ``kubectl exec -it [pod-name] -- ls /data``

|

contents_

|

security
--------

|

primitives
==========

|

intro
   each request to communicate with api server, wether from a user or a pod (via service account) needs to go through steps including
   
   - authentication (who)
   
   - authorisation (what)
   
   - admit

|

contents_

|

cli
---

|

- `cli <https://github.com/risebeyondio/io/blob/master/containers-microservices/kubernetes/cli.rst>`_

|

next 
----

|

- https://app.linuxacademy.com/search?query=kubernetes%20the%20hard%20way
- https://app.linuxacademy.com/search?query=%20Google%20Kubernetes%20Engine%20Deep%20Dive

|

contents_

|

references
----------

|

`references <https://github.com/risebeyondio/rise/tree/master/references>`_

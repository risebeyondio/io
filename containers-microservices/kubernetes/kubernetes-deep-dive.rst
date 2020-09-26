|

**kubernetes deep dive**

------------------------

|

`home <https://github.com/risebeyondio/io>`_

|

.. comment --> depth describes headings level inclusion
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


|

contents_

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

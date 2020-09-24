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

cluster architecture
--------------------

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

cluster build
-------------

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

*******************************
etcd replication
*******************************

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

end to end tests
================

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

cli
---

|

.. code-block:: shell
   
   # cluster info
   cubectl cluster-info
   
   # cluster config
   cubectl config view
   
    # nodes and pods info
   cubectl describe nodes
   cubectl describe pods
   
   # list all available resources in a cluster
   cubectl api-resources -o wide   

   # list services
   kubectl get services --all-namespaces
   
   # list nodes
   kubectl get nodes
   
   # list pods
   kubectl get pods --all-namespaces

   # detailed - wide output
   kubectl get pods --all-namespaces -o wide 
   
   # list pods with label information
   kubectl get pods --show-labels
   
   # apply new label (here env) to specific pod
   kubectl label pods $podName env=prod
   
   # list pods while showing certain lable
   kubectl get pods -L env
   
   # field selectors filtering 
   kubectl get pods --field-selector status.phase=Running
   kubectl get services --field-selector metadata.namespace=default
   kubectl get pods --field-selector status.phase=Running,metadata.namespace=default
   kubectl get pods --field-selector status.phase!=Running,metadata.namespace!=default

   # create new namespace
   kubectl create ns $namespaceName
   
   # list namespaces
   kubectl get namespaces
   
   # pod details
   kubectl describe pod $podName
   
   # get pods in a namespace context
   kubectl get pods -n $namespaceName

   # pod deletion
   kubectl delete pod $podName
   
   # check cluster  system components status
   kubectl get componentstatus
   
   # create object based on existing spec yaml file
   kubectl create -f nginx-spec-file.yaml
   
   # show specific deployment in yaml output 
   kubectl get deployment myDeployment -o yaml
   
   # execute a command from specific pod
   kubectl exec $podName -- curl $nodeIpaddress:80
   
   # list pods in default namespace with a custom view
   kubectl get pods -o custom-columns=POD:metadata.name,NODE:spec.nodeName --sort-by spec.nodeName -n kube-system
   
   # check endpoint resource - leader
   kubectl get endpoints kube-scheduler -n kube-system -o yaml
   
   # check (self signed) certificate
   cat .kube/config | more
   
   # check service account token
   kubectl get secrets  
   
   # verify api token file from within a pod
   cat /var/run/secrets/kubernetes.io/serviceaccount/token
   
   # run shemm in a pod
   kubectl exec -it <name-of-pod> -n $namespaceName sh
   
   # list services in a namespace via API call
   curl localhost:8001/api/v1/namespaces/myNamespace/services
   
   # list service account resurces in a cluster
   kubectl get serviceaccounts
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

|

**kubernetes and cka**

----

|

`home <https://github.com/risebeyondio/io>`_

|

.. comment --> depth describes headings level inclusion
.. contents:: contents
   :depth: 10

|

basics
------

basics
   - container orchestration / automation tool supporting
      - high availibility
      - rolling updates and changes
      - scaling up and down

|

pods
====

pod
   the smallest building blocs of the k8 cluster, model
   
   contains one or more containers, storage resources and unique IP address in the K8 cluster network
   
   kubernetes schedules pods to run on servers in the cluster
   
   when a pod is scheduled, the server will run containers that are part of that pod
   
   all objects in k8 are being linked to certain namespaces
   
basic kubernetes commands
   list pods ``kubectl get pods``   

   list pods in specific namespace ``kubectl get pods -n kube-system``   

   more information on specific pod ``kubectl describe pod nginx``
   
   delete pod ``kubectl delete pod nginx``
   
   create new namespace ``kubectl create namespace myNameSpace``
   
|

clustering and nodes
====================

|

clustered architecture and nodes
   architecture of multiple servers able to run the workload - containers

|

nodes
   servers that run the mentioned workload - containers
   
   to list nodes use ``kubectl get nodes``
   
   to get more information about a specific node ``kubectl describe node $node_name`` 

|

master nodes - control servers
   manage and control the cluster
   
   host to kubernetes API
   
   usually seperate from worker nodes that run application in the cluster
   

|

networking in kubernetes
========================

|

virtual cluster network
   a single virtual network that spans across entire cluster
   
   binds into a single virtual network nodes and their pods
   
   every pod in the cluster has an unique IP address within the vitual network
   
   each pod can communicate with any other pod in the cluster, even if it the ether pod is running on a different node 
   
   to get IP addresses of pod use -output wide flag ``kubectl get pods -o wide``
   
   test the virtual network connectivity in the cluster by issuing command from one pod to run on a pod running on different node ``kubectl exec busybox -- curl $nginx_pod_ip``

|

architecture components
=======================

|

control plane components
   control and manage cluster
   
   backend system pods can be seen within kube-system namespace ``kubectl get pods -n kube-system``
      
   - etcd - master node - sychronised and distributed data store for the cluster state
   
   - cube REST API server - master node
   
   - cube controlller manager - master node- bundles several back end components into one package
   
   - cube scheduler - master node - schedules pods to run on specific nodes
   
   - kubelet - each node - agant that executes containers on each node, it is a service than can be verified by running ``sudo systemctl status kubelet`` 
   
   - kube-proxy - each node- deals with between nodes network communication by adding firewall routing rules
   
|

deployments
===========

|

deployments
   way to automate management of pods
   
   - desired state - can be specified for a set of pods, cluster will work to maintain the state
   
   - scaling - number of replicas needed can be specified, deployments will add or remove replicas to meet the requirement 
   
   - rolling updates - ability to change deployment container image to newer version, the deployments will gradually replace old containers with the new one, incremental changes and zero downtime updates 
   
   - self healing - if for any reason a pod fails or gets accidentally destroyed, new pod will be spin up to replace it

|

services
========

|

services
   solve the problem of replica pods being frequently destroyed and (re)created, scaled up and down

   abstraction / load balancer layer on top of set of replica pods
   
   allow dynamic access to the replica pods
   
   instead of accessing pods directly the service sitting on top of the replica pods is to be utilised
   
   uninterrupted access to replica pods that are currrently in operation

|

microservices
=============

|

monolithic architecture
   all parts of application are combined into one large executable - oposite to microserviced architecture
   
|

microservices
   small and independent services designed to work together to form entire application
   
   services such as customer data, product data, authantication, search are all independent from each other but aligned to work together as one application - decoupled and loosely coupled 
   
   benefits
   
   - independent scalability - individual microservices are independently scalable, if specific service is under increased load only that single service can be scaled up or down instad of scaling the entire application
   
   - cleaner code - changes to a particular part of application will not affect functioning  of other application components
   
   - reliability - issues in one part of application are less likely to cause problems in other parts of the application
   
   - variety of tools - differnt services can be constructed using wide range of tools, languages or frameworks - best tool for each job

|

cluster config
==============

|

*architecture - master and 2 worker nodes - host OS - ubuntu*

|

1. install container runtime

|

*here docker on all 3 nodes*

|

.. code-block:: bash
   
   # add docker repository GPG key
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   
   # add docker repo
   sudo add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
      
   # reload aptsources list
   sudo apt-get update
   
   # docker install - here specific version not latest
   sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu
   
   # lock docker package version - prevent auto-updates 
   sudo apt-mark hold docker-ce

|

2. install kubeadm, kubelet, kubectl 

|

*three kubernetes necessary components to be insalled on all nodes - master and 2 workers*

|

.. code-block:: bash
   
   # add kubernetes repositories GPG key
   curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -   
   
   # add kubernetes repository source
   cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
   deb https://apt.kubernetes.io/ kubernetes-xenial main
   EOF
      
   # reload aptsources list - step that has to be done each time
   # after adding new repos
   sudo apt-get update
   
   # three components install - here specific version not latest
   sudo apt-get install -y kubelet=1.15.7-00 kubeadm=1.15.7-00 kubectl=1.15.7-00   
   
   # lock the 3 packages version - prevent auto-updates 
   sudo apt-mark hold kubelet kubeadm kubectl  
   
   # verify the install 
   kubeadm version

|

3. cluster init and bootstrapping

|

.. code-block:: bash
   
   # master - init the cluster (might take few minutes to complete)
   sudo kubeadm init --pod-network-cidr=10.244.0.0/16
   
   # master - copy three command from init command output
   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
   
   # master - verify cluster operation
   # master - check if k8 API Server and Client Version info are in the output 
   kubectl version
   
   # copy from kubectl version command output (master) the kubeadm join command and run in sudo on the two worker nodes
   # worker nodes 1 and 2
   # make sure command have no line breaks and
   # the output confirms that the node has joined the cluster
   sudo kubeadm join $some_ip:6443 --token $some_token --discovery-token-ca-cert-hash $some_hash
   
   # master - verify that nodes have koined the cluster  
   kubectl get nodes
   
| 

4. network config with Flannel network plugin

|

https://coreos.com/flannel/docs/latest

|

.. code-block:: bash
   
   # all three nodes
   # ammend sysctl.conf permanently so it remains persistent after reboot
   echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
   
   # all three nodes - apply the change to sysctl.conf instantly
   sudo sysctl -p
   
   # master only - flannel install
   kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml

   # master - verify that all the nodes now have a status of ready 
   (it might take few moments before nodes enter ready state)
   kubectl get nodes
   
   # verify flannel pods operation
   # three pods should have flannel in the name and status of running
   kubectl get pods -n kube-system
   
|

deployment config
==================

|

*to create deployment of 2 replica pods running nginx containers, execute the below*

.. code-block:: yaml
   
   cat <<EOF | kubectl create -f -
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: nginx-deployment
     labels:
       app: nginx
   spec:
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
           image: nginx:1.15.4
           ports:
           - containerPort: 80
   EOF

|

- list deployment ``kubectl get deployments``
- get more information about a deployment ``kubectl describe deployment nginx-deployment``
- list pods ``kubectl get pods``

|

service config
==============

|

*to create simple NodePort service abstracting 2 replica pods running nginx containers, execute the below*

.. code-block:: yaml
   
   cat << EOF | kubectl create -f -
   kind: Service
   apiVersion: v1
   metadata:
     name: nginx-service
   spec:
     selector:
       app: nginx
     ports:
     - protocol: TCP
       port: 80
       targetPort: 80
       nodePort: 30080
     type: NodePort
   EOF

|

list cluster services ``kubectl get service`` or ``kubectl get svc``

|

with NodePort service (externally exposed port), access it via port 30080 on any of the cluster's servers  ``curl localhost:30080``

|

sample microserviced application deployment
===========================================

|

*this sample application is based on instana application*

- https://github.com/instana/robot-shop

|

steps 
.. code-block:: bash
   
   # delete prevous services assigned to port 30080
   kubectl delete svc nginx-service
   
   # 
   cd ~/
   git clone https://github.com/instana/robot-shop.git
   
   # Create a namespace, deploy the application objects into the namespace using the  cloned descriptors
   kubectl create namespace robot-shop
   kubectl -n robot-shop create -f ~/robot-shop/K8s/descriptors/
   
   # list pods within the namespace, flag -w(atch) enable live updates in the state of pods; activity
   kubectl get pods -n robot-shop -w
   
   # use server public IP to verify the operation of the application
   http://$kube_server_public_ip:30080
     
|

certified kubernetes administrator - cka
----------------------------------------

|

content

|

contents_

|

references
----------

|

`references <https://github.com/risebeyondio/rise/tree/master/references>`_

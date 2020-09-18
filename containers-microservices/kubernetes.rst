|

kubernetes and CKA study

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

kubernetes clusters
===================
   
|

*********************
sample cluster config
*********************

|

*architecture - master and 2 nodes - host OS - ubuntu*

|

1. install container runtime

|

*in this sample docker on all 3 nodes*

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

Certified Kubernetes Administrator - CKA
----------------------------------------

|

content

|

references
----------

|

- `references <https://github.com/risebeyondio/rise/tree/master/references>`_

|

contents_

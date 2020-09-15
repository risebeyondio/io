kubernetes
----------

|

`home <https://github.com/risebeyondio/io>`_

|

.. comment --> depth describes headings level inclusion
.. contents:: contents
   :depth: 10

|

basics
======

basics
   - container orchestration / automation tool supporting
      - high availibility
      - rolling updates and changes
      - scaling up and down

|

kubernetes clusters
===================
   
|

---------------------
sample cluster config
---------------------

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

*three kubernetes necessary components*

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
   
   # init the cluster
   sudo kubeadm init --pod-network-cidr=10.244.0.0/16

| 

references
==========

|

- `references <https://github.com/risebeyondio/rise/tree/master/references>`_

|

contents_

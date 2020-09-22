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

*application runing on kubernetes, [ref. linuxacademy.com]*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes_application_run.png
   :align: center
   :alt: application runing on kubernetes
   
|

cli
---

|

.. code-block:: shell
   
   kubectl get nodes

   kubectl get pods --all-namespaces

   # detailed - wide output
   kubectl get pods --all-namespaces -o wide 
   
   # list namespaces
   kubectl get namespaces
   
   # pod details
   kubectl describe pod $podName

   # pod deletion
   kubectl delete pod $podName


next 
----

|

- https://app.linuxacademy.com/search?query=kubernetes%20the%20hard%20way
- https://app.linuxacademy.com/search?query=%20Google%20Kubernetes%20Engine%20Deep%20Dive

|

content

|

contents_

|

references
----------

|

`references <https://github.com/risebeyondio/rise/tree/master/references>`_

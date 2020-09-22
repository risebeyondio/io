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

api
---

|

api server
   the only component that talks with etcd datastore
   
   all other components communicate with etcd and each other through api server only
   
   ``kebectl`` command can be used to create, updtate, delete and get api objects 

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

service and network
-------------------

|

service
   dynamically access a group of replicated pods
   
   service has one consisten IP address and port, whereas pods can be created, destroyed frequently and changing IP addresses
   
   if old pod failes, gets destroyed, the service decides how to route traffic to an new pod

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

*services and replica pods, [ref. linuxacademy.com]*

|

.. figure:: https://github.com/risebeyondio/rise/blob/master/media/kubernetes-services.png
   :align: center
   :alt: services and replica pods

cli
---

|

.. code-block:: shell
   
   kubectl get nodes

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

   # list namespaces
   kubectl get namespaces
   
   # pod details
   kubectl describe pod $podName

   # pod deletion
   kubectl delete pod $podName
   
   # check cluster  system components status
   kubectl get componentstatus
   
   # create object based on existing spec yaml file
   kubectl create -f nginx-spec-file.yaml
   
   # show specific deployment in yaml output 
   kubectl get deployment myDeployment -o yaml
   


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

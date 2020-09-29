**cli references**

|

`home <https://github.com/risebeyondio/io>`_

|

.. comment --> depth describes headings level inclusion
.. contents:: contents
   :depth: 10

|

cli
---

|

.. code-block:: shell
   
   ########   
   # labels
   ########
   
   
   # add label to a node 
   kubectl label node $node-name disk=ssd
   
   # add label to a pod
   kubectl label pods $pod-name env=prod
   
   # existing label override
   ``kubectl label node $node-name disk=hdd --overwrite

    # list pods with label information
   kubectl get pods --show-labels
   kubectl get $pod-name --show-labels
   
   # list pods while showing certain label
   kubectl get pods -L env
   
   
   
   
  
   
  
   ########   
   # other
   ########
   
   
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

   # get container process id
   docker inspect --format '{{ .State.Pid }}' $conteinerId  
   
   # list iptables entries for particular service - here nginx and kube
   sudo iptables-save | grep KUBE | grep nginx``

   # list endpoints
   kubectl get endpoints
   
   # list deamonsets in a cluster
   kubectl get deamonsets


|

contents_

|

references
----------

|

`references <https://github.com/risebeyondio/rise/tree/master/references>`_

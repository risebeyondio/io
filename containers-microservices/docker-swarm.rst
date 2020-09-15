docker swarm
------------

|

`home <https://github.com/risebeyondio>`_

|

.. comment --> depth describes headings level inclusion
.. contents:: contents
   :depth: 10

|

basics
======

|

basics
   - cluster management / orchestration integrated with docker engine - docker cli allows to create a swarm of docker engines
   
   - decentralised design - handling specialization at runtime allowing to deploy entire swarm from a single disk image 
   
   - declarative service model - declarative language to describe the desired state of the stack
   
   - scaling - swarm manager automatically adapts by adding or removing tasks to maintain the desired state
   
   - multi-host networking - swarm manager automatically assigns network addresses whenever a container is initialized or updated
   
   - service discovery - each service / groups of containers in the swarm is assigned a unique DNS name
   
   - load-balancing - service ports can be exposed to an external LB, internally it can be configured how to distribute service containers between worker nodes
   
   -  security by default - each worker node in the swarm enforces TLS mutual authentication and encryption between itself and the nodes, option to use self-signed root certificate or purchase custom root certificate 

   - rolling updates, history, rollbacks to previous versions

|

brief config
============

|

brief config steps
   init ``docker swarm init --advertise-addr privateOrPublicIPAddHere``
   
   from each worker terminal add worker / itself to swarm ``docker swarm join --token tokenValueHere privateOrPublicIPAddHere:portNumber``
   
   set manager ``docker swarm join-toker manager``
   
   verify on swarm manager the nodes ``docker node ls``
   
   on swarm manager initiate 1 or more containers / services / tasks / worker nodes to initialize for example nginx images / containers / services ``docker service create --replicas 2 -p 80:80 myWebServers nginx`` 
   
   verify ``docker service ps myWebServers``
   
   verify web server via elinks by installing it on swarm manager ``sudo yum elinks``
   
   test from swarm manager operation of nodes nginx ``elinks workerNodeIPadd:80``
   
   if at any time one of the worker nodes fails, shutdown; etc, the swarm manager will spin new worker node to match running state to the desired state number of nodes that supposed to be running
    
|

contents_

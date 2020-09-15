**namespaces and control groups**
---------------------------------

|
|

`home <https://github.com/risebeyondio/io/README.rst>`_

|
|

.. comment --> depth describes headings level inclusion
.. contents:: contents
   :depth: 10

|
|

some history 
============

|

Bill Cheswick - chroot - firts conainerized and isolated environment within linux, jail command 
  http://www.cheswick.com/ches/papers/berferd.pdf

|

linux namespaces and control groups / Cgroups
=============================================

|

namespaces
   limit process what resource it can **see**

   - User - PIDs and GUIDs vs PIDs - nested virtualisation
   
   - IPC - Inter-Process Communication - allow communication / data exchange among processes within same IPC namespace 
   
   - UTS - Unix Time Sharing - allows single system to have different host and domain names to different processes - containers can be by default identified by host name  
   
   - Mount - this namespace is similar to chroot(ed) environment, isolated list of mountpoints to each container - completely differnt views of systems' visible mount points structure 
   
   - PID - allows to spin new process tree for each separate container; when booting system all starts with PID:1 which is a root process for the entire process tree; isolation of containers PIDs prevents PIDs conflicts between the containers
   
   - Network - containers can have own copy of network stack - own routing table, firewall rules, own network devices.
   
   Sample network namespace congiguration
   
.. code-block:: bash

   sudo ip netns add sampeNetNamespace
   sudo ip netns list
   sudo iptables -L
   sudo ip netns exec sampeNetNamespace bash
   iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
   sudo iptables -L
   exit
   sudo iptables -L
   
|

Cgroups - Control Groups 
   considered by some as 7th linux namespace

   limit process what resource it can **access**
   
   Linux kernel feature that limits and isolates the resource usage of a collection of processes. 
   
   control groups give us a way to be able to limit the access that a process has to / from system resources
   
   control groups' subsystems (such as blkio, cpu, cpuacct, cpuset, devices, freezer,memory, net_cls, net_prio) specify way user space and containers interact with kernel space.

|
|
   
contents_

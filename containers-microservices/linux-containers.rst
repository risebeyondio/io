linux containers - lxc
----------------------

|

`home <https://github.com/risebeyondio/io>`_

|

.. comment --> depth describes headings level inclusion
.. contents:: contents
   :depth: 10

|

hypervisors
===========

|

type 1
   runs directly on the system hardware / on the server not on the host operating system - bare metal hypervisor

type 2
   runs on host operating system that provides virtualization services - software based hypervisor

|

linux containers lxc / lxd (lexi)
=================================

|

containers basics
   containers run on same shared linux kernel, which helps to to launch them quickly
   
   examples

      - Host Ubuntu server that can run RHEL based containers 
      - Host RHEL server that can run Alpine based containers

   linux containers are based around concepts of:
   
   - chroot(ed) environments
   
   - namespaces
   
   - control groups
   
   - SElinux - Security Enhanced Linux - kernel modification enabling acces control policies and userspace tool that limits process previlages to the minimum required

   - AppArmour - linux kernel security module in SUSE linux enterprise and Debia distributions - allows restricting programs capabilities using profiles
   
   - seccomp policies

|

linux containers - lxc
======================

|

.. code-block:: bash

   sudo apt install lxd lxd-client
   sudo lxd init
   lxc list
   lxc launch ubuntu:16.04 myUbuntuContainer
   lxc launch images:alpine/3.5 myAlpineContainer
   lxc list
   lxc exec myUbuntuContainer -- /bin/bash
   lxc exec myAlpineContainer -- /bin/ash
   lxc remote list
   lxc image list

|
   
contents_

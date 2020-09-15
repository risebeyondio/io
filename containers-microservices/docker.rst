docker
------

|

`home <https://github.com/risebeyondio/io>`_

|

.. comment --> depth describes headings level inclusion
.. contents:: contents
   :depth: 10

|

docker
======

|

basics
   it is essentially an application wrapper around linux containers - LXCs
   
   builds the application and all its dependencies into a single object - container
   
   consists of:
   
   - client - docker CLI (abstract from docker APIs)
   
   - REST API
   
   - Docker deamon
   
|

functionalities
   - portable deployment accross machines
   
   - application centric - deployment of apps not machines
   
   - automatic build - chef, pupet, salt, ansible, etc
   
   - versioning - git like along with history and rollbacks
   
   - component reuse - containers can be used to create new images
   
   - sharing images - docker hub - private and public
   
   - tooling ecosystem - defined API to be used to automate and integrate with other tools

|

docker installation steps
   - install linux packages - prereqs
   
   -  configure repository from docker to pull latest docker community or enterprise edition, sample centos command (docker-ce or docker-ee)
   
   ``sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo``
   
   ``ls /etc/yum.repos.d:``
   
   - install ``sudo yum install docker-ce``
   
   - enable ``sudo systemctl enable docker``
   
   - start ``sudo systemctl start docker``
   
   - add specific user to be able to have permissions to create containers and user docker with needing sudo previliges ``sudo usermod -a -G docker dockerUserPiotr``
   ``grep docker /etc/group``
   
   - test ``docker run hello-world``
   
   - verify ``docker ps -a``
   
|

docker images
=============

|

images
   based around COW concept - Copy On Write - whenever changing a file the file is first being copied before any modifications, and changes are performed on the new file

|
   
contents_

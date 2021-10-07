|

**bits**

----

|

`home <https://github.com/risebeyondio/io>`_

|
|

.. comment --> depth describes headings level inclusion
.. contents:: contents
   :depth: 10

|
|

AWS
----

System Manager 
===============

unified user interface so you can track and resolve operational issues across your AWS applications and resources from a central place. 

With Systems Manager, you can automate operational tasks for Amazon EC2 instances or Amazon RDS instances

You can also group resources by application, view operational data for monitoring and troubleshooting, implement pre-approved change work flows, and audit operational changes for your groups of resources
Systems Manager simplifies resource and application management, shortens the time to detect and resolve operational problems, and makes it easier to operate and manage your infrastructure at scale.

EFS 
====

LAMBDA
======

- API Gateway service overview
  - Consume lambda using / triggering by:
    - SDK/CLI
    - API Gateway
    - Application Load Balancer
    - Target Group

Back UP
=======
   - EC2
   - RDS
   - EFS
   
endpoints
=========

- AWS endpoints 
- AWS custom endpoints

Architecture de VPC communicating with AWS transit gateway
===========================================================

Route53
=========
  - private zone
  - public zones délégation
  - Architecture split view DNS


EKS 
====  
  - Managed EC2 nodes vs nodes group
  - Assume role on pod using OpenID connect (oidc) 
  - Cluster rbac based on aws iam roles 
  - Protocole SAML et protocole OIDC with EKS

EKS Control Plane IAM role

   to include AmazonEKSClusterPolicy

EKS Node Group IAM role

this role requires 3 policies:

   AmazonEKSWorkerNodePolicy
   AmazonEKS_CNI_Policy
   AmazonEC2ContainerRegistryReadOnlyPolicy

Network fondamentals
======================
 
 - VPC basics (NACL, route tables ...)
  - VPC peering
  - VPC transit gateway
  - VPC endpoints (private links) build on NLB and expose to other accounts

EC2 
====
  - ALB vs NLB 
  - ALB + regional WAF 
  - Cloufront + WAF 
  - Launch configuration vs launch template for ASG 
  - Mixed launch configuration for ASG ( on demand + spot ) 
  - SSM / SecretManager
  - Agent SSM for EC2 linux type
  - Parameter Store
  - Session Manager
  - Use Ansible on EC2 through SSM agent without SSH
  - Secret Manager overview

S3
===
  - Static website on s3 exposed trough cloudfront
  - Realtime replication on buckets between regions (can be tricky with terraform) 

IAM 
====
- Cross accounts IAM roles 
  


OKTA Authentication
--------------------

Python
------
- boto3

DB
----

- DynamoDB
- PostgreSQL

HashiCorp Vault
----------------
- 2 instance in 2 AZs, front ELB, backend RDS (POstgreSQL),   
- RBAC solution to be developed


Jenkins / CloudBees
-------------------
- run inn EKS CloudBees
- Groovy

GitHub Actions
---------------


Questions
----------

- terraform backend (not to be variabilized) Vs terragrunt, workspaces 
- best practices for working with multi environment AWS - workspaces, directory trees 
- recommended AWS course / course provider for AWS enterprise scope with focus on terraform and labs / workshops,  but not basics as many other,  (not dry theory like Solution Pro cert prep courses) 


- https://www.udemy.com/course/learn-aws-eks-kubernetes-cluster-and-devops-in-aws-part-1/learn/lecture/20550408?start=138#content
- https://www.udemy.com/course/aws-certified-solutions-architect-professional-training/learn/lecture/25343904?start=13#overview




notes
------


7 October
=========




|
|
|
|
|
|
|
|
|
|


H1
--

H2
==

****
H3
****

H4
####

H5
****

H5A
****

H4A
####


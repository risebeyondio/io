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

System Manager / SSM 
=====================
Big One 

- Seession manager (use it to connect to EC2)  feature first, remote executions ex yum update, ability to execute commands, and push command to EC2
- Patch manager

unified user interface so you can track and resolve operational issues across your AWS applications and resources from a central place. 

With Systems Manager, you can automate operational tasks for Amazon EC2 instances or Amazon RDS instances

You can also group resources by application, view operational data for monitoring and troubleshooting, implement pre-approved change work flows, and audit operational changes for your groups of resources
Systems Manager simplifies resource and application management, shortens the time to detect and resolve operational problems, and makes it easier to operate and manage your infrastructure at scale.

EFS 
====
fairly simple bot3 SDK to mount EC2

LAMBDA
======
TEST it

ex. lambda to snapshot volumes of ec2 instance every x hrs, 

- API Gateway service overview
  - Consume lambda using / triggering by:
    - SDK/CLI
    
    - API Gateway - S3 bucket website working with api path / endpoint to trigger the lambda action / event and return the request code - more endpoints and more lambdas 
    
    - Application Load Balancer (can be used in similar way as API gateway) good for a single API path ad big lambda
         - Target Group

Back UP
=======
get the basics
   - EC2
   - RDS
   - EFS
   
endpoints
=========
VPC feature 

- AWS endpoints 
- AWS custom endpoints

focus on gateway (S3 and DynamoDB) and interface endpoints


Architecture de VPC communicating with AWS transit gateway
===========================================================

https://blog.revolve.team/2020/10/06/deep-dive-aws-transit-gateway/


Route53
=========
  - private zone (attached to VPC and local to VPCs only, entries will resolve only within VPCs)
  - public zones délégation
  - Architecture split view DNS


EKS 
====  
  - Managed EC2 nodes vs nodes group
  - Assume role on pod using OpenID connect (oidc) 
  - Cluster rbac based on aws iam roles 
  - Protocole SAML (older) et protocole OIDC (oauth) with EKS - DIG IT - the difference and functionality 

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
  - ALB + regional WAF  (ALB with attached WAF) -> dig it 
  - Cloufront + WAF 
  - Launch configuration (older, less flexible approach)  vs launch template (more features, most recent) for ASG  
  - Mixed launch configuration for ASG ( on demand + spot) 
  - SSM
   - Agent SSM for EC2 linux type + SSM IAM role 
   - Parameter Store can be used with other services such as Lambda, EC2, cross service
   - Session Manager -> learn how to use it with EC2 
   - patch manager (optional to learn for now)
   - state manager (optional to learn for now)
   - inventory manger (optional to learn for now)
   - SecretManager (kind of enhanced parameters store, SecretManager - granual security on access to secrets)

 
  - Use Ansible on EC2 through SSM agent without SSH
  - Secret Manager overview


S3
===
  - Static website on s3 exposed trough cloudfront as it serves https  (no HTTPS on static S3) bucket with policy CloudFrontOrginAccessPolicy 
  - Realtime replication on buckets between regions (can be tricky with terraform) -> try to do it terraform - two buckets in two regions and replication on, two providers needed for two different regions (source region and destination)

IAM 
====
- Cross accounts IAM roles 

   - create revolve role to assume form my personal account 

  


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


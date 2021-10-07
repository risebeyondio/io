|

**tech bits**

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

OKTA Authentication

Python
------
- boto3

DB
- DynamoDB
- PostgreSQL

HashiCorp Vault
- 2 instance in 2 AZs, front ELB, backend RDS (POstgreSQL),   
- RBAC solution to be developed

Jenkins CloudBees 
- run inn EKS CloudBees
- Groovy

GitHub Actions

AWS
----

- System Manager Service

- Parameter Store

- EFS 

- LAMBDA
  - API Gateway service overview
  - Consume lambda using
    - SDK/CLI
    - API Gateway
    - Target Group

- Back UP
   - EC2
   - RDS
   - EFS
   
- AWS endpoints et AWS custom endpoints services
- Architecture de VPC discutent via AWS transit gateway
- Route53 :
  - private zone
  - public zones délégation
  - Architecture split view DNS

- AWS Lambdas triggering by
  - SDK/CLI
  - API Gateway
  - Application Load Balancer

-EKS

- Protocole SAML et protocole OIDC with EKS

- Network fondamentals :
  - VPC basics (NACL, route tables ...)
  - VPC peering
  - VPC transit gateway
  - VPC endpoints (private links) build on NLB and expose to other accounts

- EC2 fondamentals :
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

- S3
  - Static website on s3 exposed trough cloudfront
  - Realtime replication on buckets between regions (can be tricky with terraform) 

- EKS 
  - Managed EC2 nodes vs nodes group
  - Assume role on pod using OpenID connect (oidc) 
  - Cluster rbac based on aws iam roles

- IAM 
  - Cross accounts IAM roles 
  
- API/Lambda
  - API Gateway service overview
  - Consume lambda using
    - SDK/CLI
    - API Gateway
    - Target Group

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


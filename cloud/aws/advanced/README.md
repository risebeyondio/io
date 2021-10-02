- AWS endpoints et AWS custom endpoints services
- Architecture de VPC discutent via AWS transit gateway
- Route53 :
  - private zone
  - public zones délégation
  - Architecture split view DNS

- AWS Lambdas trigger par
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



Practice and refreshment on Elastic Kubernetes Service 
======================================================

EKS
*****

AWS EKS on high level consists of:

- EKS Control Plane 
- EKS NOde Group

both elements require separate IAM roles 

pre-reqs
*********


- credentials file

vi ~/.aws/credentials
aws_access_key_id = ...
aws_secret_access_key = ... 


- configuration file

vi ~/.aws/config

...
[profile terraform_user]
region=eu-central-1

**verify cli**

aws s3 ls --profile terraform_user


**create EKS Control Plane IAM role**

- to include AmazonEKSClusterPolicy

**create EKS Node Group IAM role**

this role requires 3 policies:

- AmazonEKSWorkerNodePolicy
- AmazonEKS_CNI_Policy
- AmazonEC2ContainerRegistryReadOnlyPolicy

**create SSH key pair / pem key (if not existing)**

- to ssh to EC2 instances / worker nodes if needed

**define VPC and subnets**

**define security group(s)**



cluster creation
*****************

- define cluster endpoint from availabel:
  - public
  - public and private
  - privite














# with overline, for parts

* with overline, for chapters

= , for sections

- , for subsections

^ , for subsubsections

" , for paragraphs

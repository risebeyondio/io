Practice and refreshment on Elastic Kubernetes Service 
======================================================

intro
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

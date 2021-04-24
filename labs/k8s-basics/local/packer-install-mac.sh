brew tap hashicorp/tap
brew install hashicorp/tap/packer
brew upgrade hashicorp/tap/packer

# environment variables
export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY
packer validate deployment-ec2.pkr.hcl
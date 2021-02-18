# Introduction
This tutorial automates the provisioning of resources through Terraform. This Terraform script serves as starting guide to anyone wishing to learn Infrastructure as Code in general and Terraform in particular. This script deploys the NK Microservices project on AWS, by performing the following steps:

1. Create a Security Group that allows global access on ports 22 (SSH) and 1337 (HTTP).
2. Create an EC2 instance along with an EBS volume. 
3. Runs a UserData script that installs Docker, and deploys the whole stack on the EC2 machine.

# Prerequisites
Before running the script, several steps must be completed first in order for the deployment to succeed:

1. Install the AWS CLI on the machine.
2. Create an AWS IAM user, along with enough permissions. For simplicity purposes, assign the user an AdministratorAccess policy or a EC2FullAccess Policy.
3. Configure the AWS CLI to ingest access keys.
4. Choose the region to be London or Ireland. If you would like to deploy the stack in a different region, you must add the corresponding machine AMI into the ```variables.tf``` file.
5. Create a keypair in the same region in which the stack will be deployed.
6. Install Terraform on your local machine.

# Stack explanation
The terraform stack is comprised of three files:

1. ```main.tf```: The main file which provisions the resources required. The file creates a security group, then an EC2 machine to which the SG is attached.
2. ```variables.tf```: Contains a list of variables used by the main file.
3. ```values.tfvars```: Contains values for these variables. This file is not present in this repository and must be created by the user as such:
    1. ```profile```: the name of the AWS profile in which the credentials are saved (defaults to default). NOT REQUIRED.
    2. ```region```: The codename of the AWS region in which the stack will be deployed (No default value). REQUIRED. So far, the stack accepts the values: ```eu-west-1``` and ```eu-west-2```. In order to choose a different region, modify the ```amis``` variable in the ```variables.tf``` file to include the machine's AMI (Ubuntu 18.04) in the desired region
    3. ```key_name```: The name of the keypair file created on AWS (Without the file extension). REQUIRED

Below is an example of a valid ```values.tfvars``` file, located next to the other two ```.tf`` files:

```
profile = "nk-profile"
region = "eu-west-2"
instance_type = "t2.micro"
key_name = "test"
```

# Stack Execution

Navigate to the root directory containing the ```main.tf``` file, and perform the following commands:

* ```terraform init```:  Initialize terraform.
* ```terraform plan -var-file values.tfvards```: Plan the changes.
* ```terraform apply -var-file values.tfvards```: Apply the changes. Once the changes are done, Terraform will display the instance ID and public IP. You may use the public IP to SSH to the machine. Note that even if the terraform script signaled completion of the stack, the EC2 machine will still require a few seconds to install Docker and deploy the Microservices project. You can monitor the status of the script by navigating to the AWS console, clicking on the Machine, and extracting the UserData logs. The stack is considered deployed when the UserData logs display that all the Docker services have been deployed.
* ```terraform show```: Show the current plan.
* ```terraform state list```: List the available resources.
* ```terraform destroy -var-file values.tfvards``` destroy the resources.
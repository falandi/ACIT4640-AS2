This guide wil teach you the steps on how to create the infrastucture to provision an application using terraform an ansible
PART 1: Terraform Setup
1) cd into the terraform directory using the command 'cd terraform'
2) Once the in the directory, run the command 'terraform init' to initialize the terraform backend
3) Run the command 'terraform apply' to provision the infrastucture on AWS

After this the terraform setup should be complete in about 5 - 10mins. You can check the provisioned infrascture using the 'terraform plan' command. You can now move onto the ansible setup


PART 2: Ansible Setup
1) cd into the ansible directory using the command 'cd ansible' 
2) run the command 'ansible-playbook main.yml'

Acessing the instances:
1. to ssh into a specific instance first cd into your host machines cd into the directory where you public key is stored
2. run the following command:  ssh -i "as2_key" ubuntu@[your ec2 instance dns here]

You should now be able to check for files and configuration directly on the instances.

Video Link: https://www.youtube.com/watch?v=L1ObzVkNGZk


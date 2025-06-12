# Minecraft Server Automated Deployment
--- 
##### Preface:
This guide uses AWS leaner lab. Step and operations may differ if using other type of AWS accounts. 
### Before you start
#### You will need
- Valid AWS Credentials (Retrieve from AWS Academy Learner Lab module launch page)
- Terraform installed v1.12.1
	- Follow Instructions at this link to install based on you OS [Terraform install guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- Must be able to change permissions and run .sh files from CLI
- nmap ( v7.95) installed on your local machine

--- 
### Diagram of Major Steps 
![Diagram](\.images/MC_diag.drawio.png)


### Steps to build your IAC 
1. Clone this repo to a local directory
   `git clone git@github.com:TJForrest/Minecraft-p2.git`
2. cd into the cloned directory **Minecraft-p2**
   `cd Minecraft-p2`
3. Make a file named **creds** to store your AWS credentials 
   `vim creds`
4. Generate a key pair. These will be stored in the **keys** directory 
   `ssh-keygen -t rsa -b 4096 -f ./keys/minecraft-key`
5. Navigate to the **scripts** directory 
   `cd scripts`
6. Make sure the script **terracraft.sh** has executable permissions
   `chmod +x terracraft.sh`
7. Now run the script 
   `./terracraft.sh`
8. You will a lot of output to the console as the script provisions  using terraform, checks if the instance has java and Minecraft installed (installs if not), then finally runs an nmap to verify that the server is up and reachable. 

---
### Connecting to your server
- Once **terracraft.sh** has finished running copy the public IP address show in the output 
  *Line to find :
  The Minecraft server is not up and running at
  XXX.XXX.XXX.XXX:25565*
  
---
### Things to Note:
- If using AWS learner lab you will need to update your creds file to fresh session credentials each time you have a new session.
- If there is any issues while **terracraft.sh** runs the script will stop and give you the error it came across. 

---
### Resources :
[Terraform Install](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
[Terraform ASW build guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build)
[Bash scripting cheat sheet](https://devhints.io/bash)

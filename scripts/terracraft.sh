# This script will handle provissioning an EC2 instacne using terraform.
# Waits for the instance to be establised and gets the Pub IP addr.
# Then SSH in to the instance install the server JAR file if needed.
# And finally starts the server.

#!/bin/bash
set -e

# File paths
PROJECT_ROOT="$(dirname "$0")/.."
KEY_PATH="$PROJECT_ROOT/keys/minecraft-key"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

# Run terraform
echo "Running Terraform init and apply"
cd "$TERRAFORM_DIR"
terraform init -input=false
terraform apply -auto-approve

# Get the Pub IP Addr once terraform has finished apply
echo "Retrieving  public IP of Instance"
PUBLIC_IP=$(terraform output -raw minecraft_server_ip)
 
if [ -z "$PUBLIC_IP" ]; then
	echo "Public IP not retrieved"
	exit 1
else
	echo "The public IP is: $PUBLIC_IP"
	echo -e "Giving the instance time to finish setting up \n
This will take 30 seconds"
	sleep 30
fi

# SSH into the instance and installs and sets up server
ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" ec2-user@"$PUBLIC_IP" << EOF

set -e

# Check if Java is installed on instance
echo "Checking if Java is installed on instance"
if java -version &>/dev/null; then
	echo "Java is installed"
else
	echo "Installing Java"
	sudo dnf install java-21-amazon-corretto -y
fi

# Checking for MC server installation
echo "Checking for Minecraft server"
if [ -f /home/ec2-user/minecraft/server.jar ]; then
	echo "Minecraft server is intalled"
else
	echo "Installing Minecraft server"
	mkdir minecraft
	cd minecraft 
	wget  https://piston-data.mojang.com/v1/objects/e6ec2f64e6080b9b5d9b471b291c33cc7f509733/server.jar
	# confirm license agreement 
	echo "eula=true" > eula.txt 
fi

# Give the instance a script to start server up
echo "Firing up the server"
cat << 'EOS' > ~/minecraft/start_mc_server.sh
#!/bin/bash
cd ~/minecraft 
java -Xmx2g -Xms1g -jar server.jar nogui
EOS

chmod +x ~/minecraft/start_mc_server.sh


# Set up auto start for the server
echo "Setting up auto start via systemd"
sudo tee /etc/systemd/system/minecraft.service > /dev/null << EOU
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/minecraft
ExecStart=/home/ec2-user/minecraft/start_mc_server.sh
# Proper shutdown 
ExecStop=/bin/kill -s SIGINT \$MAINPID
Restart=on-failure
SuccessExitStatus=0 1
TimeoutStopSec=20

[Install]
WantedBy=multi-user.target
EOU

# Reload the service unit file 
sudo systemctl daemon-reload 
sudo systemctl enable minecraft.service
sudo systemctl start minecraft.service

echo -e "\nThe Minecraft server is up and running at \n$PUBLIC_IP:25565"
EOF

echo -e "\nNmap verification that Minecraft server is up and reachable\n"
# Give a little time for the server to fully init 
sleep 15 
nmap -sV -Pn -p T:25565 "$PUBLIC_IP"

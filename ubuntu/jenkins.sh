#!/bin/bash

# Update system and install dependencies
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y git openjdk-17-jdk wget

# Add Jenkins repository and key
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt update -y
sudo apt install -y jenkins

# Enable and start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Show initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

#!/bin/bash

# Update system packages
sudo yum update -y

# Install Git, OpenJDK 8, and Maven (for Jenkins builds)
sudo yum install -y git java-1.8.0-openjdk maven

# Add Jenkins repository
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install -y jenkins

# (Optional) Add Amazon Corretto 17 (if your builds need Java 17)
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
sudo yum install -y java-17-amazon-corretto

# Set default Java (manual step — choose 17 if needed)
sudo alternatives --config java

# Enable and start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Show Jenkins status
sudo systemctl status jenkins

#!/bin/bash

# Update and install required packages
yum update -y
amazon-linux-extras install java-openjdk11 -y
yum install unzip wget -y

# Create sonar user
useradd -m -d /opt/sonar sonar

# Download and extract SonarQube
cd /opt/
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.6.50800.zip
unzip sonarqube-8.9.6.50800.zip
mv sonarqube-8.9.6.50800 sonarqube

# Set permissions
chown -R sonar:sonar /opt/sonarqube

# Create start script for sonar user
echo '#!/bin/bash
cd /opt/sonarqube/bin/linux-x86-64
./sonar.sh start
' > /opt/sonar/start-sonarqube.sh

chmod +x /opt/sonar/start-sonarqube.sh
chown sonar:sonar /opt/sonar/start-sonarqube.sh

echo "Setup complete. Now run as 'sonar' user:"
echo "  sudo su - sonar"
echo "  ./start-sonarqube.sh"
echo ""
echo "Access SonarQube at http://<EC2-PUBLIC-IP>:9000"
echo "Default login: admin / admin"

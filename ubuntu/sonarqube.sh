#!/bin/bash

# Update system
sudo apt update -y && sudo apt upgrade -y

# Install Java 11 (required for SonarQube 8.9 LTS)
sudo apt install openjdk-11-jdk unzip wget -y

# Create sonar user
sudo useradd -m -d /opt/sonar sonar

# Download SonarQube
cd /opt/
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.6.50800.zip
sudo unzip sonarqube-8.9.6.50800.zip
sudo mv sonarqube-8.9.6.50800 sonarqube

# Set permissions
sudo chown -R sonar:sonar /opt/sonarqube

# Create a start script for sonar user
sudo bash -c 'cat > /opt/sonar/start-sonarqube.sh <<EOF
#!/bin/bash
cd /opt/sonarqube/bin/linux-x86-64
./sonar.sh start
EOF'

sudo chmod +x /opt/sonar/start-sonarqube.sh
sudo chown sonar:sonar /opt/sonar/start-sonarqube.sh

echo "✅ SonarQube installed successfully."
echo "To start it:"
echo "  sudo su - sonar"
echo "  ./start-sonarqube.sh"
echo "🔐 Default login: admin / admin"

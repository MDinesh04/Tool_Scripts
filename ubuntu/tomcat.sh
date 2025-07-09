#!/bin/bash

set -e

# === Configuration ===
TOMCAT_VERSION="9.0.107"
INSTALL_DIR="/opt/tomcat9"
TOMCAT_URL="https://downloads.apache.org/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz"
TOMCAT_USER="tomcat"

# Install Java and tools
sudo apt update
sudo apt install -y openjdk-11-jdk wget tar

# Download and extract Tomcat
cd /opt
wget -q $TOMCAT_URL -O tomcat.tar.gz
sudo tar -xzf tomcat.tar.gz
sudo mv apache-tomcat-$TOMCAT_VERSION tomcat9
sudo rm tomcat.tar.gz

# Create Tomcat user
sudo useradd -r -m -U -d $INSTALL_DIR -s /bin/false $TOMCAT_USER
sudo chown -R $TOMCAT_USER:$TOMCAT_USER $INSTALL_DIR

# Configure Tomcat manager user
cat <<EOF | sudo tee $INSTALL_DIR/conf/tomcat-users.xml
<tomcat-users>
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <user username="tomcat" password="dinesh" roles="manager-gui,manager-script"/>
</tomcat-users>
EOF

# Remove IP restriction from Manager app
sudo sed -i '/<Valve className="org.apache.catalina.valves.RemoteAddrValve"/d' \
  $INSTALL_DIR/webapps/manager/META-INF/context.xml

# Start Tomcat
sudo -u $TOMCAT_USER $INSTALL_DIR/bin/startup.sh

echo "✅ Tomcat $TOMCAT_VERSION is running at http://<your-ec2-ip>:8080"
echo "🔐 Login: tomcat / dinesh"

#!/bin/bash

# 1. Install Java 11
sudo amazon-linux-extras enable java-openjdk11
sudo amazon-linux-extras install java-openjdk11 -y
sudo yum install wget tar -y

# 2. Download Tomcat 9.0.107
cd /opt/
TOMCAT_VERSION=9.0.107
TOMCAT_URL="https://downloads.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"

wget $TOMCAT_URL -O apache-tomcat-${TOMCAT_VERSION}.tar.gz
if [ $? -ne 0 ]; then
  echo "❌ Failed to download Tomcat version $TOMCAT_VERSION."
  exit 1
fi

tar zxvf apache-tomcat-${TOMCAT_VERSION}.tar.gz
mv apache-tomcat-${TOMCAT_VERSION} tomcat9

# 3. Create a dedicated non-root user (if desired)
sudo useradd -m -d /opt/tomcat-user tomcatusr

# 4. Secure Manager credentials and permissions
cat <<EOF | sudo tee tomcat9/conf/tomcat-users.xml
<tomcat-users>
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <user username="tomcat" password="dinesh" roles="manager-gui,manager-script"/>
</tomcat-users>
EOF

# 5. Remove remote IP restrictions for Manager (dev only)
sudo sed -i '/<Valve className="org.apache.catalina.valves.RemoteAddrValve"/d' tomcat9/webapps/manager/META-INF/context.xml

# 6. Set ownership
sudo chown -R tomcatusr:tomcatusr tomcat9

# 7. Launch Tomcat
cd tomcat9/bin
sudo -u tomcatusr ./startup.sh

echo "✅ Tomcat 9.0.107 is up on port 8080"
echo "➡️  Access: http://<EC2-IP>:8080"
echo "🔐 Manager login: tomcat / dinesh"

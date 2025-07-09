#!/bin/sh

# Exit on any error and show message
trap 'echo "An error occurred. Exiting..." >&2; exit 1' ERR
set -e

# Nexus version
NEXUS_VERSION="3.79.0-09"
NEXUS_URL="https://download.sonatype.com/nexus/3/nexus-unix-x86-64-${NEXUS_VERSION}.tar.gz"

echo "[INFO] Updating system and installing Java..."
sudo apt update
sudo apt install -y openjdk-11-jdk wget

# Check if Java installed
if ! java -version >/dev/null 2>&1; then
  echo "[ERROR] Java installation failed. Aborting."
  exit 1
fi

# Create nexus user if not exists
if ! id nexus >/dev/null 2>&1; then
  echo "[INFO] Creating nexus user..."
  sudo useradd -r -M -d /opt/nexus -s /usr/sbin/nologin nexus
fi

# Check if already installed
if [ -d "/opt/nexus/nexus" ]; then
  echo "[WARN] Nexus appears to be already installed at /opt/nexus/nexus. Aborting."
  exit 1
fi

echo "[INFO] Creating directories..."
sudo mkdir -p /opt/nexus /opt/sonatype-work
cd /opt/nexus

echo "[INFO] Downloading Nexus..."
wget "$NEXUS_URL" -O nexus.tar.gz

echo "[INFO] Extracting Nexus..."
tar -xvzf nexus.tar.gz
sudo mv nexus-${NEXUS_VERSION} nexus
rm -f nexus.tar.gz

echo "[INFO] Setting permissions..."
sudo chown -R nexus:nexus /opt/nexus /opt/sonatype-work
sudo chmod -R 755 /opt/nexus /opt/sonatype-work

echo "[INFO] Configuring Nexus to run as 'nexus' user..."
echo 'run_as_user="nexus"' | sudo tee /opt/nexus/nexus/bin/nexus.rc > /dev/null

echo "[INFO] Creating systemd service..."
sudo sh -c 'cat > /etc/systemd/system/nexus.service' <<EOF
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/nexus/bin/nexus start
ExecStop=/opt/nexus/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

echo "[INFO] Enabling and starting Nexus service..."
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

# Optional: Allow port 8081 if UFW is used
if command -v ufw >/dev/null 2>&1; then
  echo "[INFO] Allowing Nexus port through UFW..."
  sudo ufw allow 8081/tcp
fi

# Optional: Create CLI symlink
sudo ln -sf /opt/nexus/nexus/bin/nexus /usr/bin/nexus

# Show service status and initial admin password
echo "[INFO] Nexus service status:"
sudo systemctl status nexus --no-pager

echo "[INFO] Initial Admin Password:"
sudo cat /opt/sonatype-work/nexus3/admin.password || echo "[WARN] Password file not found yet. Nexus may still be starting."

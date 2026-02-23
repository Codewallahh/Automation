#!/bin/bash
set -e

echo "🔄 Updating system..."
sudo apt update -y && sudo apt upgrade -y

echo "📦 Installing basic prerequisites..."
sudo apt install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  software-properties-common

# -------------------------
# Docker Installation
# -------------------------
echo "🐳 Installing Docker..."

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker $USER

# -------------------------
# Nginx Installation
# -------------------------
echo "🌐 Installing Nginx..."

sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# -------------------------
# Java Installation (Required for Jenkins)
# -------------------------
echo "☕ Installing Java 17..."

sudo apt install -y openjdk-17-jdk
java -version

# -------------------------
# Jenkins Installation (FIXED)
# -------------------------
echo "🤖 Installing Jenkins..."

wget https://pkg.jenkins.io/debian-stable/binary/jenkins_2.541.1_all.deb

sudo dpkg -i jenkins_2.541.1_all.deb

sudo apt -f install -y

sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Allow Jenkins to use Docker
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
docker newgrp
# -------------------------
# Final Status Check
# -------------------------
echo "✅ Installation Complete!"
echo "----------------------------------"
echo "Docker version:"
docker --version

echo "Nginx status:"
sudo systemctl status nginx --no-pager

echo "Jenkins status:"
sudo systemctl status jenkins --no-pager

echo "⚠️ IMPORTANT:"
echo "Logout & login again OR run: newgrp docker"
echo "Jenkins URL: http://<SERVER-IP>:8080"

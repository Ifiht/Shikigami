#!/bin/zsh

# Install Node.js and PM2
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash - 
sudo apt-get install -y nodejs
npm install -g pm2

# Install Clang and necessary tools
sudo apt install -y clang lld
sudo apt install -y build-essential

#!/bin/bash

# Kill any existing application running on port 3000 and delete all pm2 processes

kill -9 $(lsof -t -i:3000)
pm2 delete all

# Update the system and install necessary packages
sudo yum update
sudo yum install git -y 

# Install nvm and Node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc

cd /usr/local/src

if [ -e "/usr/local/src/node-v14.16.1-linux-x64.tar.xz" ]; then
    rm /usr/local/src/node-v14.16.1-linux-x64.tar.xz
    echo "File deleted"
else
    echo "File not found"
fi

sudo wget https://nodejs.org/dist/v14.16.1/node-v14.16.1-linux-x64.tar.xz
sudo tar -xJf node-v14.16.1-linux-x64.tar.xz

if [ -d "/opt/nodejs/node-v14.16.1-linux-x64" ]; then
    sudo rm -rf /opt/nodejs/node-v14.16.1-linux-x64
    echo "Directory removed"
fi

sudo rm /usr/local/bin/node
sudo rm /usr/local/bin/npm


sudo mv node-v14.16.1-linux-x64 /opt/nodejs
sudo ln -s /opt/nodejs/bin/node /usr/local/bin/node
sudo ln -s /opt/nodejs/bin/npm /usr/local/bin/npm

source ~/.nvm/nvm.sh
nvm install 14

# Create a new directory and switch to it

if [ -d "maoApp" ]; then
    rm -rf maoApp
    echo "maoApp folder deleted"
else
    echo "maoApp folder not found"
fi

mkdir maoApp
cd maoApp

# Clone the repositories
git clone https://github.com/mohit355/maoFrontend.git  /root/maoApp/maoFrontend
git clone https://github.com/mohit355/maoBackend.git /root/maoApp/maoBackend

# Install dependencies and build the frontend
cd /root/maoApp/maoFrontend
npm install
npm run build

# Install dependencies for the backend
cd /root/maoApp/maoBackend
npm install

# Start the applications with pm2
sudo npm install -g pm2 -y
export PATH=$PATH:/opt/nodejs/lib/node_modules/pm2/bin/

# Navigate to the project directory and start the frontend with pm2
cd /root/maoApp/maoFrontend
kill -9 $(lsof -t -i:3000)
pm2 delete all

pm2 start npm --name "maoFrontend" -- run dev

# Save the current pm2 configuration to be automatically started on system boot
pm2 save

echo "Applications are running with pm2"



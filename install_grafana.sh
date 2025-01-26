#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

echo "Checking if Grafana repository already exists..."
if ! grep -q "^deb .*packages.grafana.com" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    echo "Adding Grafana repository..."
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
else
    echo "Grafana repository already exists. Skipping..."
fi

echo "Installing Grafana..."
sudo apt-get update
sudo apt-get install -y grafana

echo "Starting and Enabling Grafana service..."
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
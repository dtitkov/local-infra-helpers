#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/prometheus"
DATA_DIR="/var/lib/prometheus"
SERVICE_FILE="/etc/systemd/system/prometheus.service"

# Confirm uninstallation
read -p "Are you sure you want to uninstall Prometheus? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Uninstallation canceled."
  exit 1
fi

# Stop and disable the Prometheus service
echo "Stopping Prometheus service..."
if systemctl is-active --quiet prometheus; then
  sudo systemctl stop prometheus
fi

echo "Disabling Prometheus service..."
if systemctl is-enabled --quiet prometheus; then
  sudo systemctl disable prometheus
fi

# Remove systemd service file
if [[ -f "$SERVICE_FILE" ]]; then
  echo "Removing Prometheus systemd service file..."
  sudo rm -f "$SERVICE_FILE"
fi

# Reload systemd daemon
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Remove Prometheus binaries
echo "Removing Prometheus binaries..."
sudo rm -f "$INSTALL_DIR/prometheus" "$INSTALL_DIR/promtool"

# Remove configuration and data directories
echo "Removing Prometheus configuration and data..."
sudo rm -rf "$CONFIG_DIR" "$DATA_DIR"

# Remove Prometheus system user
if id "prometheus" &>/dev/null; then
  echo "Removing Prometheus user..."
  sudo userdel -r prometheus
fi

# Final cleanup
echo "Prometheus has been successfully uninstalled."
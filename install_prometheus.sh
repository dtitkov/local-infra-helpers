#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# Function to display usage
usage() {
  echo "Usage: $0 <Prometheus Download URL>"
  echo "Example: $0 https://github.com/prometheus/prometheus/releases/download/v2.46.0/prometheus-2.46.0.linux-amd64.tar.gz"
  exit 1
}

# Check if URL is passed as argument
if [ -z "$1" ]; then
  echo "Error: No URL provided."
  usage
fi

PROMETHEUS_URL="$1"

# Variables
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/prometheus"
DATA_DIR="/var/lib/prometheus"
SERVICE_FILE="/etc/systemd/system/prometheus.service"

# Download and Extract Prometheus
echo "Downloading Prometheus from $PROMETHEUS_URL..."
wget --progress=bar:force "$PROMETHEUS_URL" -O /tmp/prometheus.tar.gz
echo "Extracting Prometheus..."
tar -xzf /tmp/prometheus.tar.gz -C /tmp
PROMETHEUS_DIR=$(find /tmp -type d -name "prometheus-*")

# Move binaries
echo "Installing Prometheus binaries to $INSTALL_DIR..."
sudo mv "$PROMETHEUS_DIR/prometheus" "$INSTALL_DIR/"
sudo mv "$PROMETHEUS_DIR/promtool" "$INSTALL_DIR/"
sudo chmod +x "$INSTALL_DIR/prometheus" "$INSTALL_DIR/promtool"

# Create configuration directory
echo "Setting up Prometheus configuration directory..."
sudo mkdir -p "$CONFIG_DIR"
sudo mv "$PROMETHEUS_DIR/prometheus.yml" "$CONFIG_DIR/"
sudo mkdir -p "$DATA_DIR"

# Create Prometheus system user
if ! id "prometheus" &>/dev/null; then
  echo "Creating Prometheus user..."
  sudo useradd -rs /bin/false prometheus
fi

# Create systemd service file
echo "Creating Prometheus service file..."
sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
ExecStart=$INSTALL_DIR/prometheus \
  --config.file=$CONFIG_DIR/prometheus.yml \
  --storage.tsdb.path=$DATA_DIR

[Install]
WantedBy=multi-user.target
EOL

# Set ownership and permissions
echo "Setting permissions..."
sudo chown -R prometheus:prometheus "$CONFIG_DIR" "$DATA_DIR"

# Reload systemd and start Prometheus
echo "Starting Prometheus service..."
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Cleanup
echo "Cleaning up temporary files..."
rm -rf /tmp/prometheus.tar.gz "$PROMETHEUS_DIR"

# Final message
echo "Prometheus installation completed successfully!"
echo "You can access Prometheus at http://<your_server_ip>:9090"
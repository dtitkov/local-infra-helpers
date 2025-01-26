#!/bin/bash

# Function to check if the script is run as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root or with sudo." 
        exit 1
    fi
}

# Function to download and install Node Exporter
install_node_exporter() {
    # URL parameter for downloading Node Exporter
    NODE_EXPORTER_URL=$1

    if [ -z "$NODE_EXPORTER_URL" ]; then
        echo "URL parameter is missing. Please provide a valid download URL for Node Exporter."
        exit 1
    fi

    echo "Downloading Node Exporter from $NODE_EXPORTER_URL..."
    
    # Download Node Exporter
    wget --progress=bar:force "$NODE_EXPORTER_URL" -O /tmp/node_exporter.tar.gz
    
    # Extract the tarball
    echo "Extracting Node Exporter..."
    tar -xvzf /tmp/node_exporter.tar.gz -C /tmp/

    # Move the Node Exporter binary to /usr/local/bin
    echo "Moving Node Exporter to /usr/local/bin..."
    mv /tmp/node_exporter*/node_exporter /usr/local/bin/

    # Clean up temporary files
    rm -rf /tmp/node_exporter*

    # Create a systemd service file for Node Exporter
    echo "Creating systemd service for Node Exporter..."
    cat <<EOL > /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=nobody
Group=nogroup
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOL

    # Reload systemd to apply the new service
    systemctl daemon-reload

    # Enable and start the Node Exporter service
    echo "Enabling and starting Node Exporter service..."
    systemctl enable node_exporter
    systemctl start node_exporter

    # Verify Node Exporter is running
    echo "Node Exporter service status:"
    systemctl status node_exporter
}

# Main function to run the script
main() {
    check_root
    install_node_exporter $1
}

# Run the script
main $1
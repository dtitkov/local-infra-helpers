#!/bin/bash

# Check if a URL with port is provided as a parameter
if [ -z "$1" ]; then
  echo "Usage: $0 <url>:<port>"
  exit 1
fi

# Set the target URL (with port)
NEW_TARGET="$1"

# Path to your Prometheus configuration file
PROMETHEUS_CONFIG="/etc/prometheus/prometheus.yml"

# Check if job_name: "node_exporter" exists in the configuration file
if grep -q 'job_name: "node_exporter"' "$PROMETHEUS_CONFIG"; then
  echo "job_name: \"node_exporter\" section found. Adding new target..."

  # Add the new target to the existing targets under node_exporter job
  # Using sed to find the targets section and append the new target
  sed -i "/job_name: \"node_exporter\"/ { 
          /targets:/ a \ 
          - \"$NEW_TARGET\" 
      }" "$PROMETHEUS_CONFIG"
else
  echo "job_name: \"node_exporter\" section not found. Adding new job with target..."

  # If the section doesn't exist, append a new section with the new target
  cat <<EOL >> "$PROMETHEUS_CONFIG"

# New scrape config for Node Exporter
- job_name: "node_exporter"
  static_configs:
    - targets:
      - "$NEW_TARGET"
EOL
fi

# Restart Prometheus service to apply changes
echo "Prometheus configuration updated. Restarting Prometheus..."
sudo systemctl restart prometheus

echo "Done."
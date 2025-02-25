#!/bin/bash

# Path to your Prometheus configuration file
PROMETHEUS_CONFIG="/etc/prometheus/prometheus.yml"

# Check if the script is run with sudo privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo"
  exit 1
fi

# Check if a URL with port is provided as a parameter
if [ -z "$1" ]; then
  echo "Usage: $0 <url>:<port>"
  exit 1
fi

# Set the target URL (with port)
NEW_TARGET="$1"

# Check if job_name: "node_exporter" exists in the configuration file
if grep -q 'job_name: "node_exporter"' "$PROMETHEUS_CONFIG"; then
  echo "job_name: \"node_exporter\" section found. Adding new target..."

  # Add the new target to the existing targets under node_exporter job
  # Using awk to find the targets section and append the new target
  awk -v new_target="$NEW_TARGET" '
  $0 ~ /job_name: "node_exporter"/ { in_job=1 }
  in_job && $0 ~ /targets:/ { print; print "      - \"" new_target "\""; in_job=0; next }
  { print }
  ' "$PROMETHEUS_CONFIG" > /tmp/prometheus.yml && mv /tmp/prometheus.yml "$PROMETHEUS_CONFIG"
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

# Check if Prometheus service is running and restart if necessary
if systemctl is-active --quiet prometheus; then
  echo "Prometheus configuration updated. Restarting Prometheus..."
  sudo systemctl restart prometheus
else
  echo "Prometheus service is not running. Starting Prometheus..."
  sudo systemctl start prometheus
fi

echo "Done."
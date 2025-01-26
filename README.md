# Local Infra Helpers

This repository provides a collection of scripts designed to automate the **installation** and **uninstallation** of infrastructure tools on local devices running Ubuntu Server in a headless configuration. These scripts automates setup processes, ensuring efficiency and repeatability for home-based research and development laboratories.


## Prometheus

### Install script 

**What It Does**

- Validates input URL.
- Downloads and installs Prometheus binaries.
- Configures Prometheus with systemd for service management.
- Ensures cleanup of temporary files.

**Usage**  

1. Make it executable on your target device by running:

    ```bash
    chmod +x install_prometheus.sh
    ```
2. Run the script with the Prometheus download URL:

    ```bash
    ./install_prometheus.sh <Prometheus Download URL>
    ```

    example:  

    ```bash
    ./install_prometheus.sh https://github.com/prometheus/prometheus/releases/download/v2.46.0/prometheus-2.46.0.linux-amd64.tar.gz  
    ```

### Uninstall script 

**What It Does**
- Stops and disables the Prometheus service.
- Removes Prometheus binaries (prometheus, promtool).
- Deletes Prometheus configuration (/etc/prometheus) and data (/var/lib/prometheus).
- Deletes the Prometheus system user if it exists.
- Cleans up the systemd service file and reloads the daemon.

**Usage**  

1. Make it executable on your target device by running:

    ```bash
    chmod +x uninstall_prometheus.sh
    ```
2. Run the script

    ```bash
    ./uninstall_prometheus.sh
    ```
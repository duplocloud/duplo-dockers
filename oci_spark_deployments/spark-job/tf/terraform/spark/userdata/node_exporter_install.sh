#!/bin/bash -x

# /home/opc
#version_ne=0.16.0
version_ne=1.3.1
# Install node_exporter
useradd -m -s /bin/bash prometheus
cd /home/prometheus
wget https://github.com/prometheus/node_exporter/releases/download/v${version_ne}/node_exporter-${version_ne}.linux-amd64.tar.gz
tar -xzvf node_exporter-${version_ne}.linux-amd64.tar.gz
mv node_exporter-${version_ne}.linux-amd64 node_exporter
chown -R prometheus:prometheus node_exporter

# Start node_exporter as a service
cat <<EOF >/etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=prometheus
ExecStart=/home/prometheus/node_exporter/node_exporter
[Install]
WantedBy=default.target
EOF
systemctl start node_exporter

# Open firewall for node_exporter
firewall-offline-cmd --add-port=9100/tcp
systemctl reload firewalld
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
chown -R opc:opc node_exporter
# Start node_exporter as a service
sudo  cat <<EOF >/etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target
After=network.target
User=opc
Group=opc

[Service]
Type=simple
Restart=always
ExecStart=/bin/sh -c '/home/opc/node_exporter/node_exporter'

[Install]
WantedBy=multi-user.target
EOF
systemctl start node_exporter

# Open firewall for node_exporter
firewall-offline-cmd --add-port=9100/tcp
systemctl reload firewalld
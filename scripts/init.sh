#!/bin/bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh

yum install -y epel-release 
yum install -y wget

wget 'https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz'
tar -xvzf 'node_exporter-1.5.0.linux-amd64.tar.gz'
mv 'node_exporter-1.5.0.linux-amd64/node_exporter' '/usr/local/bin/'

useradd -rs /bin/false nodeuser

cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target
[Service]
User=nodeuser
Group=nodeuser
Type=simple
ExecStart=/usr/local/bin/node_exporter
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

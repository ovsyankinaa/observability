#!/bin/bash -xe
useradd --no-create-home prometheus
mkdir /etc/prometheus
mkdir /var/lib/prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.34.0/prometheus-2.34.0.linux-amd64.tar.gz
tar xvfz prometheus-2.34.0.linux-amd64.tar.gz
cp prometheus-2.34.0.linux-amd64/prometheus /usr/local/bin
cp prometheus-2.34.0.linux-amd64/promtool /usr/local/bin/
cp -r prometheus-2.34.0.linux-amd64/consoles /etc/prometheus
cp -r prometheus-2.34.0.linux-amd64/console_libraries /etc/prometheus
cp prometheus-2.34.0.linux-amd64/promtool /usr/local/bin/
rm -rf prometheus-2.34.0.linux-amd64.tar.gz prometheus-2.34.0.linux-amd64
export PROMETHEUS_CLIENT_IP=${prometheus_client_ip}

cat<<EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  external_labels:
    monitor: 'prometheus'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'prometheus-client'
    static_configs:
      - targets: ['$PROMETHEUS_CLIENT_IP:9100']      
  - job_name: 'blackbox_web'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
          - https://onliner.by
    relabel_configs:
      - source_labels: [__address__]
        regex: (.*)(:80)?
        target_label: __param_target
        replacement: ${1}
      - source_labels: [__param_target]
        regex: (.*)
        target_label: instance
        replacement: ${1}
      - source_labels: []
        regex: .*
        target_label: __address__
        replacement: localhost:9115      
EOF

cat<< EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries
chown -R prometheus:prometheus /var/lib/prometheus
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.20.0/blackbox_exporter-0.20.0.linux-amd64.tar.gz
tar xvfz blackbox_exporter-0.20.0.linux-amd64.tar.gz
cd blackbox_exporter-0.20.0.linux-amd64/

cat<<EOF > black.yml
modules:
  http_2xx:
    prober: http
    timeout: 5s
    http:
      method: GET
  http_post_2xx:
    prober: http
    http:
      method: POST
EOF

./blackbox_exporter --config.file=black.yml &>output.log &
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
apt-get install -y adduser libfontconfig1
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_8.4.5_amd64.deb
dpkg -i grafana-enterprise_8.4.5_amd64.deb
systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server
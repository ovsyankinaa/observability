#!/bin/bash -xe
wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+focal_all.deb
dpkg -i zabbix-release_5.0-1+focal_all.deb
apt-get update
apt-get -y install zabbix-agent
export ZABBIX_SERVER_IP=${zabbix_server_ip}
cat<<EOF >/etc/zabbix/zabbix_agentd.conf
PidFile=/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=$ZABBIX_SERVER_IP
ListenPort=10050
ListenIP=0.0.0.0
StartAgents=3
ServerActive=$ZABBIX_SERVER_IP
Hostname=zabbix-client
Include=/etc/zabbix/zabbix_agentd.d/*.conf
EOF

systemctl restart zabbix-agent
systemctl enable zabbix-agent
apt-get install nginx
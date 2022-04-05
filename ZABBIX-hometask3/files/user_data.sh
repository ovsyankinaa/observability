#!/bin/bash -xe
wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+focal_all.deb
dpkg -i zabbix-release_5.0-1+focal_all.deb
apt-get update
apt-get -y install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-agent
apt-get -y install mysql-server mysql-client
export ZABBIX_DB_PASSWD=${zabbix_db_passwd}
cat <<EOF > zabbix-db.sql
create database zabbix character set utf8 collate utf8_bin;
create user zabbix@localhost identified by '$ZABBIX_DB_PASSWD';
grant all privileges on zabbix.* to zabbix@localhost;
EOF

mysql -uroot < zabbix-db.sql
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p$ZABBIX_DB_PASSWD zabbix
sed -i 's/# DBPassword=/'DBPassword=$ZABBIX_DB_PASSWD'/g' /etc/zabbix/zabbix_server.conf
sed -i 's/#        listen          80;/        listen          80;/g' /etc/zabbix/nginx.conf
sed -i 's/#        server_name     example.com;/        server_name      *.eu-west-1.compute.amazonaws.com;/g' /etc/zabbix/nginx.conf
sed -i 's/; php_value\[date\.timezone\] = Europe\/Riga/php_value\[date\.timezone\] = Europe\/Minsk/g' /etc/zabbix/php-fpm.conf

cat<<EOF > /usr/share/zabbix/conf/zabbix.conf.php
<?php
\$DB['TYPE']                             = 'MYSQL';
\$DB['SERVER']                   = 'localhost';
\$DB['PORT']                             = '0';
\$DB['DATABASE']                 = 'zabbix';
\$DB['USER']                             = 'zabbix';
\$DB['PASSWORD']                 = '$ZABBIX_DB_PASSWD';
\$DB['SCHEMA']                   = '';
\$DB['ENCRYPTION']               = false;
\$DB['KEY_FILE']                 = '';
\$DB['CERT_FILE']                = '';
\$DB['CA_FILE']                  = '';
\$DB['VERIFY_HOST']              = false;
\$DB['CIPHER_LIST']              = '';
\$DB['DOUBLE_IEEE754']   = true;
\$ZBX_SERVER                             = 'localhost';
\$ZBX_SERVER_PORT                = '10051';
\$ZBX_SERVER_NAME                = 'ZABBIX-SERVER';
\$IMAGE_FORMAT_DEFAULT   = IMAGE_FORMAT_PNG;
?>
EOF

systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm
systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm
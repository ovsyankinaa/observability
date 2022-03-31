#!/bin/bash -xe
yum -y install openldap-clients nss-pam-ldapd
authconfig --enableldap --enableldapauth --ldapserver=${ldap_server_ip} \
  --ldapbasedn="dc=devopslab,dc=com" --enablemkhomedir --update
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd
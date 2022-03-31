#!/bin/bash -xe
yum -y install openldap openldap-servers openldap-clients
systemctl enable slapd
systemctl start slapd
export PASSWORD=$(slappasswd -n -s ${ldap_root_passwd})
export USER_PASSWORD=$(slappasswd -n -s ${ldap_user_passwd})
export MANAGER_PASSWORD=${ldap_root_passwd}
export PERSONAL_IP=${personal_ip}
cat <<EOF > /home/ec2-user/ldaprootpasswd.ldif
dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $PASSWORD
EOF

ldapadd -Y EXTERNAL -H ldapi:/// -f /home/ec2-user/ldaprootpasswd.ldif
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown -R ldap:ldap /var/lib/ldap/DB_CONFIG
systemctl restart slapd
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif 
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

cat <<EOF > /home/ec2-user/ldapdomain.ldif
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read by dn.base="cn=Manager,dc=devopslab,dc=com" read by * none

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=devopslab,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,dc=devopslab,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $PASSWORD

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by
  dn="cn=Manager,dc=devopslab,dc=com" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="cn=Manager,dc=devopslab,dc=com" write by * read
EOF

ldapmodify -Y EXTERNAL -H ldapi:/// -f /home/ec2-user/ldapdomain.ldif

cat <<EOF > /home/ec2-user/baseldapdomain.ldif
dn: dc=devopslab,dc=com
objectClass: top
objectClass: dcObject
objectclass: organization
o: devopslab com
dc: devopslab

dn: cn=Manager,dc=devopslab,dc=com
objectClass: organizationalRole
cn: Manager
description: Directory Manager

dn: ou=People,dc=devopslab,dc=com
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=devopslab,dc=com
objectClass: organizationalUnit
ou: Group
EOF

ldapadd -x -D cn=Manager,dc=devopslab,dc=com -w $MANAGER_PASSWORD -f /home/ec2-user/baseldapdomain.ldif

cat <<EOF > /home/ec2-user/ldapgroup.ldif
dn: cn=Manager,ou=Group,dc=devopslab,dc=com
objectClass: top
objectClass: posixGroup
gidNumber: 1005
EOF

ldapadd -x -w $MANAGER_PASSWORD -D "cn=Manager,dc=devopslab,dc=com" -f /home/ec2-user/ldapgroup.ldif

cat <<EOF > /home/ec2-user/ldapuser.ldif
dn: uid=my_user,ou=People,dc=devopslab,dc=com
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: my_user
uid: my_user
uidNumber: 1005
gidNumber: 1005
homeDirectory: /home/my_user
userPassword: $USER_PASSWORD
loginShell: /bin/bash
gecos: my_user
shadowLastChange: 0
shadowMax: -1
shadowWarning: 0
EOF

ldapadd -x -D cn=Manager,dc=devopslab,dc=com -w $MANAGER_PASSWORD -f  /home/ec2-user/ldapuser.ldif
amazon-linux-extras install epel -y
yum -y install phpldapadmin

cat<<EOF > /etc/phpldapadmin/config.php
<?php
\$config->custom->session['blowfish'] = '57290568957fd19dc5de2eb5a2590add';
\$config->custom->appearance['friendly_attrs'] = array(
        'facsimileTelephoneNumber' => 'Fax',
        'gid'                      => 'Group',
        'mail'                     => 'Email',
        'telephoneNumber'          => 'Telephone',
        'uid'                      => 'User Name',
        'userPassword'             => 'Password'
);
\$servers = new Datastore();
\$servers->newServer('ldap_pla');
\$servers->setValue('server','name','Local LDAP Server');
\$servers->setValue('appearance','pla_password_hash','');
\$servers->setValue('login','attr','dn');
?>
EOF

cat<<EOF > /etc/httpd/conf.d/phpldapadmin.conf
Alias /phpldapadmin /usr/share/phpldapadmin/htdocs
Alias /ldapadmin /usr/share/phpldapadmin/htdocs

<Directory /usr/share/phpldapadmin/htdocs>
  <IfModule mod_authz_core.c>
    # Apache 2.4
    Require local
    Require ip $PERSONAL_IP
  </IfModule>
  <IfModule !mod_authz_core.c>
    # Apache 2.2
    Order Deny,Allow
    Deny from all
    Allow from 127.0.0.1
    Allow from ::1
  </IfModule>
</Directory>
EOF

systemctl restart httpd
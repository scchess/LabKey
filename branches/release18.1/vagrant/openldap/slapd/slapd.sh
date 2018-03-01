#!/bin/bash

set -eu

status () {
  echo "---> ${@}" >&2
}

set -x
: LDAP_ROOTPASS=${LDAP_ROOTPASS}
: LDAP_DOMAIN=${LDAP_DOMAIN}
: LDAP_ORGANISATION=${LDAP_ORGANISATION}

if [ ! -e /var/lib/ldap/docker_bootstrapped ]; then
  status "configuring slapd for first run"

  cat <<EOF | debconf-set-selections
slapd slapd/internal/generated_adminpw password ${LDAP_ROOTPASS}
slapd slapd/internal/adminpw password ${LDAP_ROOTPASS}
slapd slapd/password2 password ${LDAP_ROOTPASS}
slapd slapd/password1 password ${LDAP_ROOTPASS}
slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION
slapd slapd/domain string ${LDAP_DOMAIN}
slapd shared/organization string ${LDAP_ORGANISATION}
slapd slapd/backend string HDB
slapd slapd/purge_database boolean true
slapd slapd/move_old_database boolean true
slapd slapd/allow_ldap_v2 boolean false
slapd slapd/no_configuration boolean false
slapd slapd/dump_database select when needed
EOF

  dpkg-reconfigure -f noninteractive slapd

  # Add user accounts to the LDAP directory 
  # The first step is to start slapd
  /usr/sbin/slapd -h "ldap:///" -u openldap -g openldap

  # Create LDAP BaseDN from $LDAP_ORGANISATION variable 
  IFS='.' read -a array <<< "${LDAP_DOMAIN}"
  LDAP_BASEDN=""
  for element in "${array[@]}"
	do
    	LDAP_BASEDN="${LDAP_BASEDN}dc=${element},"
	done
  LDAP_BASEDN=${LDAP_BASEDN::-1}

  # Now add the user accounts defined in the file ldapusers.ldif
  ldapadd -x -D cn=admin,$LDAP_BASEDN -w $LDAP_ROOTPASS -c -f /ldapusers.ldif
  echo "ahhhhhh"
  
  # Kill the slapd daemon as configuration is complete
  pgrep -f /usr/sbin/slapd
  pkill -f /usr/sbin/slapd
  ps -ef | grep slapd


  touch /var/lib/ldap/docker_bootstrapped
else
  status "found already-configured slapd"
fi


status "starting slapd"
set -x
exec /usr/sbin/slapd -h "ldap:///" -u openldap -g openldap -d 0


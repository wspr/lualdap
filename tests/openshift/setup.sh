#!/bin/sh

set -e

dir=`dirname $0`
. $dir/test.env

ldapsearch -x -LLL -H $LDAP_URI -b $LDAP_BASE_DN objectClass=organization | grep "dc=example,dc=com"
ldapadd -x -H $LDAP_URI -D $LDAP_BIND_DN -w $LDAP_BIND_PASSWORD -f $dir/test.ldif
ldappasswd -x -H $LDAP_URI -D $LDAP_BIND_DN -w $LDAP_BIND_PASSWORD -s $LDAP_TEST_PASSWORD $LDAP_TEST_DN
ldapsearch -x -LLL -H $LDAP_URI -D $LDAP_TEST_DN -w $LDAP_TEST_PASSWORD -b $LDAP_BASE_DN $LDAP_TEST_SUBJECT memberof | grep "memberOf: cn=group"

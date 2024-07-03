#!/bin/bash

set -x
set -e

ldapsearch -x -LLL -b dc=usaf,dc=mil "(objectClass=*)"

ldapwhoami -x -D "cn=Manager,dc=usaf,dc=mil" -w test123

ldapadd -x -D "cn=Manager,dc=usaf,dc=mil" -w test123 -f /openldap_test/ou_people.ldif

ldapsearch -x -LLL -b "ou=people,dc=usaf,dc=mil" "(objectClass=*)"

ldapadd -x -D "cn=Manager,dc=usaf,dc=mil" -w test123 -f /openldap_test/user.ldif

ldapsearch -x -LLL -b "uid=jdoe,ou=people,dc=usaf,dc=mil" "(objectClass=*)"

ldapcompare -x -D "cn=Manager,dc=usaf,dc=mil" -w test123 "uid=jdoe,ou=people,dc=usaf,dc=mil" "cn:John Doe" || echo 0

ldapmodify -x -D "cn=Manager,dc=usaf,dc=mil" -w test123 -f /openldap_test/modify_user.ldif

ldapmodrdn -x -D "cn=Manager,dc=usaf,dc=mil" -w test123 "uid=jdoe,ou=people,dc=usaf,dc=mil" "uid=johndoe"

ldapdelete -x -D "cn=Manager,dc=usaf,dc=mil" -w test123 "uid=johndoe,ou=people,dc=usaf,dc=mil"

slapcat -f /etc/openldap/slapd-config/slapd.conf -v -l backup.ldif

slaptest -f /etc/openldap/slapd-config/slapd.conf -u

slapadd -f /etc/openldap/slapd-config/slapd.conf -v -l backup.ldif



#!/bin/bash

# Enable debugging and exit on error
set -x
set -e

# Search for all objects in the base DN dc=usaf,dc=mil
ldapsearch -x -LLL -b dc=usaf,dc=mil "(objectClass=*)"

# Identify the user who is performing the LDAP operation
ldapwhoami -x -D "cn=Manager,dc=usaf,dc=mil" -w test123

# Add entries from the ou_people.ldif file to the directory
ldapadd -x -D "cn=Manager,dc=usaf,dc=mil" -w test123 -f /openldap_test/ou_people.ldif

# Search for all objects in the ou=people,dc=usaf,dc=mil subtree
ldapsearch -x -LLL -b "ou=people,dc=usaf,dc=mil" "(objectClass=*)"

# Add entries from the user.ldif file to the directory
ldapadd -x -D "cn=Manager,dc=usaf,dc=mil" -w test123 -f /openldap_test/user.ldif

# Search for all objects with uid=jdoe in the ou=people,dc=usaf,dc=mil subtree
ldapsearch -x -LLL -b "uid=jdoe,ou=people,dc=usaf,dc=mil" "(objectClass=*)"

# Compare the attribute cn with the value "John Doe" for the entry with uid=jdoe
ldapcompare -x -D "cn=Manager,dc=usaf,dc=mil" -w test123 "uid=jdoe,ou=people,dc=usaf,dc=mil" "cn:John Doe" || echo 0

# Modify the LDAP entries based on the modify_user.ldif file
ldapmodify -x -D "cn=Manager,dc=usaf,dc=mil" -w test123 -f /openldap_test/modify_user.ldif

# Rename the RDN of the entry from uid=jdoe to uid=johndoe
ldapmodrdn -x -D "cn=Manager,dc=usaf,dc=mil" -w test123 "uid=jdoe,ou=people,dc=usaf,dc=mil" "uid=johndoe"

# Delete the entry with uid=johndoe from the directory
ldapdelete -x -D "cn=Manager,dc=usaf,dc=mil" -w test123 "uid=johndoe,ou=people,dc=usaf,dc=mil"

# Create a backup of the directory using slapcat
slapcat -f /etc/openldap/slapd-config/slapd.conf -v -l backup.ldif

# Check the configuration file for validity
slaptest -f /etc/openldap/slapd-config/slapd.conf -u

# Restore the directory from the backup file using slapadd
slapadd -f /etc/openldap/slapd-config/slapd.conf -v -l backup.ldif

#!/bin/sh

# Disable FIPS mode
sed -i 's/activate = 1/activate = 0/' /etc/ssl/fipsmodule.cnf

# Comment out the FIPS configuration in openssl.cnf
sed -i 's/^\.include \/etc\/ssl\/fipsmodule.cnf/#\.include \/etc\/ssl\/fipsmodule.cnf/' /etc/ssl/openssl.cnf
sed -i 's/^fips = fips_sect/#fips = fips_sect/' /etc/ssl/openssl.cnf
sed -i 's/^base = base_sect/#base = base_sect/' /etc/ssl/openssl.cnf
sed -i '/\[base_sect\]/!b;n;c#activate=1' /etc/ssl/openssl.cnf

tail -f /dev/null
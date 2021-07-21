#!/bin/bash
##
##  new-root-ca.sh - create the root CA
##  Copyright (c) 2000 Yeak Nai Siew, All Rights Reserved. 
##

# Create the master CA key. This should be done once.
if [ ! -f ca.key ]; then
	echo "No Root CA key round. Generating one"
	openssl genrsa -des3 -out ca.key 2048 -rand /dev/random
	echo ""
fi

# Self-sign it.
CONFIG="root-ca.conf"
cat >$CONFIG <<EOT
[ req ]
default_bits			= 2048
default_keyfile			= ca.key
distinguished_name		= req_distinguished_name
x509_extensions			= v3_ca
string_mask			= nombstr
req_extensions			= v3_req
[ req_distinguished_name ]
countryName			= Country Name (2 letter code)
countryName_default		= CN
countryName_min			= 2
countryName_max			= 2
stateOrProvinceName		= State or Province Name (full name)
stateOrProvinceName_default	= Beijing
localityName			= Locality Name (eg, city)
localityName_default		= Beijing
0.organizationName		= Organization Name (eg, company)
0.organizationName_default	= TESTORG
organizationalUnitName		= Organizational Unit Name (eg, section)
organizationalUnitName_default	= TESTORG
commonName			= Common Name (eg, MD Root CA)
commonName_default		= TESTORG
commonName_max			= 64
emailAddress			= Email Address
emailAddress_default		= admin@test.org
emailAddress_max		= 40
[ v3_ca ]
basicConstraints		= critical,CA:true
subjectKeyIdentifier		= hash
[ v3_req ]
nsCertType			= objsign,email,server
EOT

echo "Self-sign the root CA..."
openssl req -new -x509 -days 10000 -config $CONFIG -key ca.key -out ca.crt

rm -f $CONFIG

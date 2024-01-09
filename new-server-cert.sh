#!/bin/bash
##
##  new-server-cert.sh - create the server cert
##  Copyright (c) 2000 Yeak Nai Siew, All Rights Reserved. 
##

# Create the key. This should be done once per cert.
CERT=$1
if [ $# -lt 1 ]; then
	echo "Usage: $0 <www.domain1.com> [www.domain2.com]"
	exit 1
fi
if [ ! -f $CERT.key ]; then
	echo "No $CERT.key round. Generating one"
	openssl genrsa -out $CERT.key 2048
	echo ""
fi

IPINDEX=1
DNSINDEX=1
if [[ $CERT =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	FIELD1=IP.$((IPINDEX++))
else
	FIELD1=DNS.$((DNSINDEX++))
fi

# Fill the necessary certificate data
CONFIG="server-cert.conf"
cat >$CONFIG <<EOT
[ req ]
default_bits			= 2048
default_keyfile			= server.key
distinguished_name		= req_distinguished_name
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
commonName			= Common Name (eg, www.domain.com)
commonName_default		= $CERT
commonName_max			= 64
emailAddress			= Email Address
emailAddress_default		= admin@test.org
emailAddress_max		= 40
[ v3_req ]
nsCertType			= server
basicConstraints		= critical,CA:false
subjectAltName		= @alt_names
[ alt_names ]
$FIELD1 = $CERT
EOT

shift 1
while [ $# -gt 0 ]
do
	if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		FIELD2=IP.$((IPINDEX++))
	else
		FIELD2=DNS.$((DNSINDEX++))
	fi
	echo "$FIELD2 = $1" >> $CONFIG
	shift
done

echo "Fill in certificate data"
openssl req -new -config $CONFIG -key $CERT.key -out $CERT.csr

rm -f $CONFIG

echo ""
echo "You may now run ./sign-server-cert.sh to get it signed"

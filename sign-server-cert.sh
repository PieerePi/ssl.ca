#!/bin/bash
##
##  sign-server-cert.sh - sign using our root CA the server cert
##  Copyright (c) 2000 Yeak Nai Siew, All Rights Reserved. 
##

CERT=$1
if [ $# -lt 1 ]; then
	echo "Usage: $0 <www.domain1.com> [www.domain2.com]"
	exit 1
fi
if [ ! -f $CERT.csr ]; then
	echo "No $CERT.csr round. You must create that first."
	exit 1
fi
# Check for root CA key
if [ ! -f ca.key -o ! -f ca.crt ]; then
	echo "You must have root CA key generated first."
	exit 1
fi

IPINDEX=1
DNSINDEX=1
if [[ $CERT =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	FIELD1=IP.$((IPINDEX++))
else
	FIELD1=DNS.$((DNSINDEX++))
fi

# Sign it with our CA key #

#   make sure environment exists
if [ ! -d ca.db.certs ]; then
	mkdir ca.db.certs
fi
if [ ! -f ca.db.serial ]; then
	echo '01' >ca.db.serial
fi
if [ ! -f ca.db.index ]; then
	cp /dev/null ca.db.index
fi

#  create the CA requirement to sign the cert
cat >ca.config <<EOT
[ ca ]
default_ca              = default_CA
[ default_CA ]
dir                     = .
certs                   = \$dir
new_certs_dir           = \$dir/ca.db.certs
database                = \$dir/ca.db.index
serial                  = \$dir/ca.db.serial
RANDFILE                = /dev/random
certificate             = \$dir/ca.crt
private_key             = \$dir/ca.key
default_days            = 398
default_crl_days        = 30
default_md              = sha256
preserve                = no
x509_extensions		= server_cert
policy                  = policy_anything
[ policy_anything ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
[ server_cert ]
#subjectKeyIdentifier	= hash
authorityKeyIdentifier	= keyid:always
extendedKeyUsage	= serverAuth,clientAuth,msSGC,nsSGC
basicConstraints	= critical,CA:false
subjectAltName		= @alt_names
[ alt_names ]
$FIELD1 = $CERT
EOT

if [ $# -gt 1 -a $1 != $2 ]; then
	if [[ $2 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		FIELD2=IP.$((IPINDEX++))
	else
		FIELD2=DNS.$((DNSINDEX++))
	fi
	echo "$FIELD2 = $2" >> ca.config
fi

#  sign the certificate
echo "CA signing: $CERT.csr -> $CERT.crt:"
openssl ca -config ca.config -out $CERT.crt -infiles $CERT.csr
echo "CA verifying: $CERT.crt <-> CA cert"
openssl verify -CAfile ca.crt $CERT.crt

#  cleanup after SSLeay 
rm -f ca.config
rm -f ca.db.serial.old
rm -f ca.db.index.old
rm -f ca.db.index.attr.old


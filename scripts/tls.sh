#!/bin/bash

# Prepare the `.tls` directory
#
if [ ! -d .tls ]; then
  mkdir -p .tls/certs
  mkdir -p .tls/crl
  mkdir -p .tls/newcerts
  mkdir -p .tls/private

  # Intermediate CA
  #
  mkdir -p .tls/intermediate
  mkdir -p .tls/intermediate/certs
  mkdir -p .tls/intermediate/crl
  mkdir -p .tls/intermediate/csr
  mkdir -p .tls/intermediate/newcerts
  mkdir -p .tls/intermediate/private

  # Permissions setup
  #
  chmod 700 .tls/private
  chmod 700 .tls/intermediate/private

  # Create the index files
  #
  touch .tls/index.txt
  touch .tls/intermediate/index.txt

  # Create the serial files
  #
  echo 1000 > .tls/serial
  echo 1000 > .tls/intermediate/serial

  # Copy configs
  #
  cp config/tls/ca.cnf .tls/openssl.cnf
  cp config/tls/intermediate.cnf .tls/intermediate/openssl.cnf
fi

# Generate root CA key and certificate.
#
openssl genrsa -out .tls/private/ca.key.pem 4096

openssl req \
  -config /app/.tls/openssl.cnf \
  -key .tls/private/ca.key.pem -new -x509 \
  -days 7300 \
  -sha256 \
  -extensions v3_ca \
  -out .tls/certs/ca.cert.pem \
  -subj "/C=NL/ST=Utrecht/L=Utrecht/O=Rschoonheim/CN=Example Root CA"

# Permissions setup for the root CA key and certificate.
#
chmod 400 .tls/private/ca.key.pem
chmod 444 .tls/certs/ca.cert.pem

# Verify the root CA certificate.
#
openssl verify -CAfile .tls/certs/ca.cert.pem .tls/certs/ca.cert.pem

# Generate intermediate CA key, signing request and certificate.
#
openssl genrsa -out .tls/intermediate/private/intermediate.key.pem 4096

openssl req \
  -config /app/.tls/intermediate/openssl.cnf -new -sha256 \
  -key .tls/intermediate/private/intermediate.key.pem \
  -out .tls/intermediate/csr/intermediate.csr.pem

openssl ca \
  -config /app/.tls/openssl.cnf \
  -extensions v3_intermediate_ca \
  -days 3650 -notext -md sha256 \
  -in .tls/intermediate/csr/intermediate.csr.pem \
  -out .tls/intermediate/certs/intermediate.cert.pem

# Remove signing request.
#
rm .tls/intermediate/csr/intermediate.csr.pem

# Permissions setup for the intermediate CA key and certificate.
#
chmod 400 .tls/intermediate/private/intermediate.key.pem
chmod 444 .tls/intermediate/certs/intermediate.cert.pem

# Verify the intermediate CA certificate.
#
openssl verify -CAfile .tls/certs/ca.cert.pem .tls/intermediate/certs/intermediate.cert.pem

# Generate the certificate chain file.
#
cat .tls/intermediate/certs/intermediate.cert.pem .tls/certs/ca.cert.pem > /app/.tls/intermediate/certs/ca-chain.cert.pem


# Generate website key
openssl genrsa -out /app/.tls/intermediate/private/website.key.pem 2048

# Generate website signing request
openssl req -config /app/.tls/intermediate/openssl.cnf \
    -key /app/.tls/intermediate/private/website.key.pem \
    -new -sha256 -out /app/.tls/intermediate/csr/website.csr.pem \
    -subj "/C=NL/ST=Utrecht/L=Utrecht/O=Rschoonheim/CN=localhost"

# Generate website certificate
openssl ca -config /app/.tls/intermediate/openssl.cnf -extensions server_cert \
    -days 375 -notext -md sha256 -in /app/.tls/intermediate/csr/website.csr.pem \
    -out /app/.tls/intermediate/certs/website.cert.pem
chmod 444 /app/.tls/intermediate/certs/website.cert.pem

# Verify website certificate
openssl verify -CAfile /app/.tls/intermediate/certs/ca-chain.cert.pem \
    /app/.tls/intermediate/certs/website.cert.pem
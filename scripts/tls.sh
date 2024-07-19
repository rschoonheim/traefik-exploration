#!/bin/bash

rm -rf .tls

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

  # Copy the openssl configuration files
  #
  cp config/tls/ca.cnf .tls/openssl.cnf
  cp config/tls/intermediate.cnf .tls/intermediate/openssl.cnf
fi
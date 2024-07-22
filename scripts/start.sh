#!/bin/bash

# When `.tls` was not found we assume the certificates
# were not generated.
#
if [ ! -d .tls ]; then
  echo "Certificates not found. Please run `make certs` first."
  exit 1
fi

# Start the traefik service.
#
docker compose up -d
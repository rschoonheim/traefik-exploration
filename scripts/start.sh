#!/bin/bash

# When `.tls` was not found we assume the certificates
# were not generated.
#
if [ ! -d .tls ]; then
  docker compose run --rm generate-tls ./scripts/tls.sh > /dev/null
fi

# Start the traefik service.
#
docker compose up -d traefik
FROM alpine:latest

WORKDIR /app

# Install OpenSSL
#
RUN apk add --no-cache openssl bash

ENTRYPOINT ["/bin/bash"]
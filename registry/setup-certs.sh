#!/bin/bash
set -e

# Generate CA
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -days 365 -out ca.crt \
  -subj "/CN=Registry CA" \
  -addext "basicConstraints=critical,CA:TRUE"

# Generate server key and CSR
openssl genrsa -out tls.key 4096
openssl req -new -key tls.key -out tls.csr \
  -subj "/CN=registry.test" \
  -addext "subjectAltName=DNS:registry.test,DNS:localhost"

# Sign certificate
openssl x509 -req -in tls.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out tls.crt -days 365 \
  -extfile <(printf "subjectAltName=DNS:registry.test,DNS:localhost\nbasicConstraints=critical,CA:FALSE")

# Trust CA system-wide
sudo cp ca.crt /usr/local/share/ca-certificates/registry-ca.crt
sudo update-ca-certificates
sudo systemctl restart docker
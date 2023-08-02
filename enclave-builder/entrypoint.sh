#!/bin/sh

dockerd &

sleep 10

/app/builder/enclave-builder --config /app/mount/config.json

docker image build -t enclave:latest .
mkdir -p /app/mount/enclave
mkdir -p /var/log/nitro_enclaves
touch /var/log/nitro_enclaves/nitro_enclaves.log
nitro-cli build-enclave --docker-uri enclave:latest --output-file /app/mount/enclave/enclave.eif
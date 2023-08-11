#!/bin/sh

dockerd &

sleep 10

docker buildx create --name multiplatformEnclave --driver docker-container --bootstrap
docker buildx use multiplatformEnclave

rm -rf /app/mount/enclave

if [ -z "$TARGETARCH" ]
then
    RAW_ARCH=$(uname -m)
    if [ "$RAW_ARCH" = "x86_64" ]
    then
        TARGETARCH="amd64"
    elif [ "$RAW_ARCH" = "aarch64" ]
    then
        TARGETARCH="arm64"
    else
        echo "Unsupported architecture: $RAW_ARCH"
        exit 1
    fi
fi

/app/builder/enclave-builder --config /app/mount/config.json --arch $TARGETARCH
docker buildx build --platform linux/$TARGETARCH -t enclave:latest --load .

mkdir -p /app/mount/enclave
mkdir -p /var/log/nitro_enclaves
touch /var/log/nitro_enclaves/nitro_enclaves.log
nitro-cli build-enclave --docker-uri enclave:latest --output-file /app/mount/enclave/enclave.eif
# Build using sudo docker buildx build --platform linux/amd64,linux/arm64 -t marlinorg/enclave-builder:latest --push .

# base image
FROM marlinorg/nitro-cli

ARG TARGETARCH

# working directory
WORKDIR /app

# add files
RUN mkdir -p /app/builder && \
    wget -O /app/builder/enclave-builder http://public.artifacts.marlin.pro/projects/enclaves/enclave-builder_v0.1.0_linux_$TARGETARCH
RUN chmod +x /app/builder/enclave-builder
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x entrypoint.sh

# entry point
ENTRYPOINT [ "/app/entrypoint.sh" ]
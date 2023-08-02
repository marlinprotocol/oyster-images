# base image
FROM marlinorg/nitro-cli

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
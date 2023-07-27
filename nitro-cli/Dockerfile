# Build using sudo docker buildx build --platform linux/amd64,linux/arm64 -t marlinorg/nitro-cli:latest --push .

# base image
FROM --platform=$BUILDPLATFORM ubuntu AS builder-linux-amd64-linux-amd64
ONBUILD ENV ARCH_LOWER=x86_64
ONBUILD ENV ARCH_UPPER=X86_64
ONBUILD ENV MUSL_TOOLCHAIN_TYPE=native

FROM --platform=$BUILDPLATFORM ubuntu AS builder-linux-amd64-linux-arm64
ONBUILD ENV ARCH_LOWER=aarch64
ONBUILD ENV ARCH_UPPER=AARCH64
ONBUILD ENV MUSL_TOOLCHAIN_TYPE=cross
ONBUILD ENV CFLAGS=-mno-outline-atomics

FROM --platform=$BUILDPLATFORM ubuntu AS builder-linux-arm64-linux-amd64
ONBUILD ENV ARCH_LOWER=x86_64
ONBUILD ENV ARCH_UPPER=X86_64
ONBUILD ENV MUSL_TOOLCHAIN_TYPE=cross

FROM --platform=$BUILDPLATFORM ubuntu AS builder-linux-arm64-linux-arm64
ONBUILD ENV ARCH_LOWER=aarch64
ONBUILD ENV ARCH_UPPER=AARCH64
ONBUILD ENV MUSL_TOOLCHAIN_TYPE=native
ONBUILD ENV CFLAGS=-mno-outline-atomics

FROM builder-$BUILDOS-$BUILDARCH-$TARGETOS-$TARGETARCH AS builder

SHELL ["/bin/bash", "-c"]

WORKDIR /nitro

RUN apt-get update && apt-get install -y curl git make perl binutils gcc

# install rust
ENV CARGO_BUILD_TARGET=${ARCH_LOWER}-unknown-linux-musl
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && source "$HOME/.cargo/env" && rustup target add $CARGO_BUILD_TARGET

# install musl
ENV MUSL_TOOLCHAIN_NAME=${ARCH_LOWER}-linux-musl
RUN curl --proto '=https' --tlsv1.2 -sSf https://musl.cc/$MUSL_TOOLCHAIN_NAME-$MUSL_TOOLCHAIN_TYPE.tgz | tar -xz

# build nitro-cli
RUN git clone https://github.com/aws/aws-nitro-enclaves-cli.git

WORKDIR /nitro/aws-nitro-enclaves-cli

ENV CARGO_PROFILE_RELEASE_LTO=true
ENV HOST_CC=gcc
ENV TARGET_CC=/nitro/${MUSL_TOOLCHAIN_NAME}-${MUSL_TOOLCHAIN_TYPE}/bin/${MUSL_TOOLCHAIN_NAME}-gcc
ENV CC_${ARCH_LOWER}_unknown_linux_musl=${TARGET_CC}
ENV CARGO_TARGET_${ARCH_UPPER}_UNKNOWN_LINUX_MUSL_LINKER=${TARGET_CC}

RUN source "$HOME/.cargo/env" && cargo add openssl-sys --features vendored
RUN source "$HOME/.cargo/env" && cargo build --release

RUN mv /nitro/aws-nitro-enclaves-cli/target/$CARGO_BUILD_TARGET/release/nitro-cli /nitro/nitro-cli
RUN mv /nitro/aws-nitro-enclaves-cli/blobs/$ARCH_LOWER /nitro/nitro-cli-blobs

FROM docker

COPY --from=builder /nitro/nitro-cli /usr/local/bin/nitro-cli
RUN mkdir -p /nitro_cli_blobs
COPY --from=builder /nitro/nitro-cli-blobs /nitro_cli_blobs
ENV NITRO_CLI_BLOBS=/nitro_cli_blobs


FROM ubuntu:20.10

# Define variables.
ARG GOVERSION=1.15.15
ARG ARCH=amd64

# Download development environment.
RUN apt-get update && \
    apt-get install -y \
        libbpf-dev \
        make \
        clang \
        llvm \
        libelf-dev

# Install Go specific version.
RUN apt-get install -y wget && \
    wget https://golang.org/dl/go${GOVERSION}.linux-${ARCH}.tar.gz && \
    tar -xf go${GOVERSION}.linux-${ARCH}.tar.gz && \
    mv go/ /usr/local/ && \
    ln -s /usr/local/go/bin/go /usr/local/bin/ && \
    rm -rf go${GOVERSION}.linux-${ARCH}.tar.gz

# Setup working directory.
RUN mkdir -p /app
WORKDIR /app

# Execute build command.
ENTRYPOINT ["/usr/bin/make", "all"]

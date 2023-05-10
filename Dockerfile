FROM golang:1.20-bullseye

# Download development environment.
RUN apt-get update && \
    apt-get install -y \
        clang \
        llvm \
        libbpf-dev \
        libelf-dev

# Setup working directory.
RUN mkdir -p /app
WORKDIR /app

# Execute build command.
ENTRYPOINT ["/usr/bin/make"]
CMD ["all"]

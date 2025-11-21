# syntax=docker/dockerfile:1

FROM --platform=linux/arm/v7 node:20-bullseye AS builder

# Install dependencies needed for building code-server
RUN apt-get update && \
    apt-get install -y git python3 make g++ pkg-config libx11-dev libxkbfile-dev libsecret-1-dev

# Clone code-server (specify version or use latest stable)
ARG CODE_SERVER_VERSION=4.23.1
RUN git clone --depth 1 --branch v${CODE_SERVER_VERSION} https://github.com/coder/code-server.git

WORKDIR /code-server

# Install npm dependencies and build
RUN npm install --legacy-peer-deps && npm run build && npm run release && npm run release:standalone

# Package the build for deployment
RUN tar -czf /code-server-armv7.tar.gz -C ./release-standalone .

# Make a minimal runtime image (optional, you can deploy the tarball from the builder step)
FROM --platform=linux/arm/v7 node:20-bullseye
COPY --from=builder /code-server-armv7.tar.gz /code-server-armv7.tar.gz
WORKDIR /
RUN tar -xzf code-server-armv7.tar.gz && rm code-server-armv7.tar.gz

# Expose default code-server port
EXPOSE 8080

# Set up data/config folders
VOLUME ["/config", "/home/coder/project"]

# Start code-server
CMD ["./code-server", "--host", "0.0.0.0", "--port", "8080", "--user-data-dir", "/config", "/home/coder/project"]

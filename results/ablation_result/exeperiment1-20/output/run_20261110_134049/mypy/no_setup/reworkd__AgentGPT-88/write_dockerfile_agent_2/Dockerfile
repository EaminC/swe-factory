# Use Ubuntu 22.04 as base image with Bash shell available
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies including git, curl, and Node.js (>=18)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    build-essential \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set locale to en_US.UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Node.js 18.x and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
ARG REPO=https://github.com/reworkd/AgentGPT.git
ARG COMMIT_SHA=9bae29c0727b7af51e0715ba6c20b00f7adefe33

RUN git clone "$REPO" /testbed && \
    cd /testbed && \
    git reset --hard "$COMMIT_SHA" && \
    # Install npm dependencies without running tests
    npm install

# Environment variables need to be mounted or set at runtime as per project instructions.
# Do NOT run tests within this Dockerfile.

# Use bash as default shell environment
ENV SHELL=/bin/bash
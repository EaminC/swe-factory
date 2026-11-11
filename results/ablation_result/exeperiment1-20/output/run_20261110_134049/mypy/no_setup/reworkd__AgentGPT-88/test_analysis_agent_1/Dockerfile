# Use Ubuntu 22.04 as base image with Bash shell available
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies: git, curl, nodejs, npm and other utilities
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    build-essential \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set up locales and timezone
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Node.js v18.x and npm (recommended version >=18)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v

# Create /testbed directory and set working directory
WORKDIR /testbed/

# Clone the repository, checkout the specific commit SHA, and install dependencies
ARG REPO=https://github.com/reworkd/AgentGPT.git
ARG COMMIT_SHA=9bae29c0727b7af51e0715ba6c20b00f7adefe33

RUN git clone $REPO /testbed && \
    cd /testbed && \
    git reset --hard $COMMIT_SHA && \
    # Install npm dependencies
    npm install

# Note: .env file needs to be created externally as per README instructions.  
# This Dockerfile does not create or set secrets or environment variables such as NODE_ENV, NEXTAUTH_SECRET, etc.

# Set default shell environment to bash for runtime
ENV SHELL=/bin/bash

# Leaving container ready for test execution externally
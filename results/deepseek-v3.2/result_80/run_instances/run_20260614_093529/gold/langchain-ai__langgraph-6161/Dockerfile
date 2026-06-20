# Base image specification. Defines the foundation OS and architecture for the container
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation. Installs essential tools and libraries required for development and runtime
RUN apt update && apt install -y \
    wget \
    git \
    build-essential \
    curl \
    gnupg \
    lsb-release \
    locales \
    tzdata \
    ca-certificates \
    # Required for Python development
    python3 \
    python3-pip \
    python-is-python3 \
    python3-dev \
    python3-venv \
    # Required for PostgreSQL and Redis client libraries
    libpq-dev \
    # Required for some Python packages
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Docker using official Docker repository for latest version with compose plugin
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt update && \
    apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# Install uv using pip (more reliable than curl install in Docker context)
RUN pip3 install --no-cache-dir uv

# Verify installations
RUN uv --version && \
    docker --version && \
    docker compose version

# Set default workdir to testbed
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard 328129e5bd01805ed9a2c925df4d02d065e9ac15 && \
    git remote remove origin

# Change to the langgraph subdirectory for environment setup
WORKDIR /testbed/libs/langgraph

# Install project dependencies using uv in a single RUN command
# Use Python 3.11 as specified in CI configuration
RUN uv venv --python 3.11 && \
    . .venv/bin/activate && \
    uv sync --frozen --all-extras --all-packages --group dev

# Set up environment variables for easier activation
RUN echo 'source /testbed/libs/langgraph/.venv/bin/activate' >> /root/.bashrc

# Set the working directory back to the langgraph directory for test execution
WORKDIR /testbed/libs/langgraph

# Create a script to activate the environment for non-interactive shells
RUN echo '#!/bin/bash' > /usr/local/bin/activate-testbed && \
    echo 'source /testbed/libs/langgraph/.venv/bin/activate' >> /usr/local/bin/activate-testbed && \
    echo 'exec "$@"' >> /usr/local/bin/activate-testbed && \
    chmod +x /usr/local/bin/activate-testbed

# Since the target test file (test_pregel.py) doesn't require Docker services,
# we set NO_DOCKER=true to avoid Docker service startup issues during test execution
ENV NO_DOCKER=true
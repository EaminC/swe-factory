# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation. Installs essential tools and libraries required for development and runtime (Required)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    make \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager) as specified in the environment setup
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Set default workdir
WORKDIR /testbed/

# Clone repository and checkout to specific commit
ARG COMMIT_SHA=6fc5b3aeda2aaa89277c79dc3682e7c723e2abb6
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed/ \
    && cd /testbed/ \
    && git reset --hard ${COMMIT_SHA} \
    && git remote remove origin \
    && chmod -R 777 /testbed/

# Set environment variable to skip Docker-dependent tests (PostgreSQL, Redis, etc.)
ENV NO_DOCKER=true

# Install dependencies using uv from the langgraph package directory
# This installs all extras, all packages, and dev group as specified in the context
WORKDIR /testbed/libs/langgraph
RUN uv sync --frozen --all-extras --all-packages --group dev

# Reset workdir to /testbed as required
WORKDIR /testbed/

# Ensure bash is the default shell
SHELL ["/bin/bash", "-c"]
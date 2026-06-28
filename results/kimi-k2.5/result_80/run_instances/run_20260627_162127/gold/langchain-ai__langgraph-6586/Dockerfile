FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies and essential tools
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

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Set default workdir
WORKDIR /testbed/

# Clone repository and checkout to specific commit
ARG COMMIT_SHA=84023451a2bd5987b1d4df530f4145d503d75ccb
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed/ \
    && cd /testbed/ \
    && git reset --hard ${COMMIT_SHA} \
    && git remote remove origin \
    && chmod -R 777 /testbed/

# Set environment variables to skip Docker-dependent tests (PostgreSQL, Redis, etc.)
ENV NO_DOCKER=true
ENV LANGGRAPH_TEST_FAST=1

# Install dependencies using uv from the langgraph package directory
# This installs all extras, all packages, and dev group with editable sources
WORKDIR /testbed/libs/langgraph
RUN uv sync --frozen --all-extras --all-packages --group dev

# Reset workdir to /testbed as required
WORKDIR /testbed/

# Ensure bash is the default shell
SHELL ["/bin/bash", "-c"]
# Base image specification. Use Ubuntu 22.04 for a stable, bash-enabled environment
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies including git, python3.10 and pip, build essentials, curl, locales
RUN apt-get update && apt-get install -y \
    git \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    curl \
    build-essential \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 command points to python3.10, and upgrade pip, setuptools, wheel globally
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Create virtual environment "testbed" and upgrade pip and setuptools inside it in a single RUN layer
RUN python3 -m venv /opt/testbed && \
    /opt/testbed/bin/pip install --no-cache-dir --upgrade pip setuptools wheel

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the given commit SHA
# Install the project in editable mode and install test dependencies in the virtual environment
ARG COMMIT_SHA=ba00896c5673990923abd0e99dba147938871512
RUN git clone https://github.com/AntonOsika/gpt-engineer /testbed && \
    cd /testbed && \
    git reset --hard ${COMMIT_SHA} && \
    /opt/testbed/bin/pip install --no-cache-dir -e . && \
    /opt/testbed/bin/pip install --no-cache-dir pytest pytest-cov

# Set bash as default shell
SHELL ["/bin/bash", "-c"]
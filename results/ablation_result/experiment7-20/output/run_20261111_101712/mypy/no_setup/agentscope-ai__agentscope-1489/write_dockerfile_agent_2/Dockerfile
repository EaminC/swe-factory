# Use Ubuntu 22.04 base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Update and install system dependencies, including Python and essential build tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    locales \
    locales-all \
    tzdata && \
    rm -rf /var/lib/apt/lists/*

# Set python3 to point to python3.10 explicitly
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Upgrade pip for Python 3.10
RUN python3 -m pip install --upgrade pip

# Set working directory
WORKDIR /testbed/

# Clone the target repository and checkout the specified commit
RUN git clone https://github.com/agentscope-ai/agentscope /testbed && \
    cd /testbed && \
    git reset --hard 08b047e05b02b27a290ee1b850fb75210f186cdb

# Install Python dependencies in editable mode with dev extras using system python and pip
RUN python3 -m pip install --upgrade setuptools wheel && \
    python3 -m pip install -q coverage pytest pytest-asyncio pytest-forked pre-commit && \
    python3 -m pip install -e .[dev]

# Set environment variable needed for test execution
ENV GRPC_VERBOSITY=ERROR

# Add bashrc setup to activate python environment or other environment if needed (optional)
RUN echo "export PATH=$(python3 -m site --user-base)/bin:\$PATH" >> /root/.bashrc
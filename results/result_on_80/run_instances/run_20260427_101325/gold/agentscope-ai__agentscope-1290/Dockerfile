# Use Ubuntu 22.04 base image with bash shell and x86_64 platform
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install essential system packages: git, curl, wget, build tools, python3.10, python3-pip, python-is-python3 and dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    ca-certificates \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3-pip \
    python3.10-distutils \
    python-is-python3 \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Ensure python 3.10 is the default python3 binary - already covered with python-is-python3 package

# Upgrade pip to latest
RUN python3 -m pip install --upgrade pip setuptools wheel

# Create and activate python virtual environment named testbed
RUN python3 -m venv /opt/testbed
ENV PATH="/opt/testbed/bin:$PATH"

# Upgrade pip inside the venv
RUN pip install --upgrade pip setuptools wheel

# Set default shell to bash
SHELL ["/bin/bash", "-c"]

# Set working directory
WORKDIR /testbed/

# Clone repository, checkout specific commit, and install python package in development mode alongside dev dependencies
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    cd /testbed && \
    git reset --hard 28cfb99a21902d330dab6cb3762a739198cf972f && \
    pip install -e .[dev]

# Environment variables required for runtime/testing (user might want to override)
ENV DASHSCOPE_API_KEY=""
ENV GAODE_API_KEY=""

# Append venv activation to .bashrc for convenience (not mandatory)
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc
# Base image specification with Ubuntu 22.04 and bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies including git, python3, pip, build tools, and libraries
# Use system python3 (3.10+ on Ubuntu 22.04) to avoid heavy conda env creation and out-of-memory issues
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3 \
    python3-venv \
    python3-distutils \
    python3-pip \
    python-is-python3 \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to latest version
RUN python3 -m pip install --upgrade pip

# Set working directory to /testbed
WORKDIR /testbed/

# Clone the agentscope repository, checkout the provided commit, and remove origin remote to ensure isolation
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    cd /testbed && \
    git reset --hard 17676eaaf2346ff936fc2df78ec098fa7a81e3e0 && \
    git remote remove origin

# Create and activate a python virtual environment, then install project with all extras and test dependencies in editable mode
RUN python3 -m venv /opt/testbed_venv && \
    source /opt/testbed_venv/bin/activate && \
    pip install --upgrade pip setuptools && \
    pip install -e ".[full]" pytest pytest-cov coverage

# Add virtual environment activation to bashrc for interactive sessions
RUN echo "source /opt/testbed_venv/bin/activate" >> /root/.bashrc
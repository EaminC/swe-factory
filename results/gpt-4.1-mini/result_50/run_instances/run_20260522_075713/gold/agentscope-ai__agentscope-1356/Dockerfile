# Use Ubuntu 22.04 as base image to simplify Python 3.10 package installation
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies including python3.10, python3-venv, python3-distutils, and essential tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3-venv \
    python3-distutils \
    python3-pip \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, and wheel to latest stable versions
RUN python3.10 -m pip install --upgrade pip setuptools==78.1.1 wheel==0.45.1

# Create Python virtual environment for isolation
RUN python3.10 -m venv /opt/testbed

# Add the virtual environment python and pip to PATH
ENV PATH="/opt/testbed/bin:$PATH"

# Clone the target repository at the specified commit SHA
WORKDIR /testbed
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed

ARG COMMIT_SHA=b35c1652c7b46a0af2785f988925d9910e3b7b70
RUN git reset --hard ${COMMIT_SHA}

# Install the project in editable mode with development dependencies only from the cloned repository
RUN pip install -q -e ".[dev]" && pip install coverage pytest pre-commit

# Install pre-commit hooks, do NOT run tests here
RUN pre-commit install

# Fix permissions to avoid potential access issues
RUN chmod -R 777 /testbed

# Set working directory
WORKDIR /testbed

# Configure bash shell to activate the virtual environment automatically for interactive use
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Use bash shell by default
SHELL ["/bin/bash", "-c"]
# Use Ubuntu 22.04 as the base image for reliability and bash support
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, python3.10, pip, venv tools, curl, and locales
RUN apt-get update && apt-get install -y \
    git \
    curl \
    python3.10 \
    python3.10-venv \
    python3-pip \
    python3.10-distutils \
    build-essential \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Generate locale for UTF-8 support
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Upgrade pip
RUN python3.10 -m pip install --upgrade pip

# Set working directory
WORKDIR /testbed/

# Clone the correct repository and checkout the specific commit
RUN git clone --depth 1 https://github.com/strands-agents/sdk-python.git /testbed/

RUN cd /testbed && git fetch --depth=1 origin 776fd93751cc26e3d535776b17612c2e3068cc2b && git checkout 776fd93751cc26e3d535776b17612c2e3068cc2b

# Create and activate virtual environment, install hatch and development dependencies, then install repo in editable mode
RUN python3.10 -m venv .venv && \
    source .venv/bin/activate && \
    pip install --upgrade pip && \
    pip install hatch && \
    # Install main dependencies explicitly except the repo itself (repo installed in editable mode below)
    pip install "boto3>=1.26.0,<2.0.0" "botocore>=1.29.0,<2.0.0" "docstring_parser>=0.15,<1.0" "mcp>=1.11.0,<2.0.0" "pydantic>=2.4.0,<3.0.0" "typing-extensions>=4.13.2,<5.0.0" "watchdog>=6.0.0,<7.0.0" "opentelemetry-api>=1.30.0,<2.0.0" "opentelemetry-sdk>=1.30.0,<2.0.0" "opentelemetry-instrumentation-threading>=0.51b0,<1.00b0" && \
    # Install development dependencies used for testing and linting
    pip install "pytest>=8.0.0,<9.0.0" "pytest-cov>=7.0.0,<8.0.0" "pytest-asyncio>=1.0.0,<1.3.0" "pytest-xdist>=3.0.0,<4.0.0" moto commitizen pre-commit mypy ruff && \
    # Install the current repo in editable mode to ensure local code is referenced
    pip install -e .

# Add the venv activation to root's bashrc for ease of use in interactive shells
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Default shell set to bash for compatibility
ENV SHELL=/bin/bash

# Workdir is already set to /testbed/
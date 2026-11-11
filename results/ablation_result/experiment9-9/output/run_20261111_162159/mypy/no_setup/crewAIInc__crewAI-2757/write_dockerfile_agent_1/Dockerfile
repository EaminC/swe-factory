# Base image specification. Ubuntu 22.04 chosen for good compatibility and bash support
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies needed for building and running the project and its dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    python3-setuptools \
    libssl-dev \
    libffi-dev \
    cargo \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install UV toolchain related packages globally first for setup
RUN python3.11 -m pip install --upgrade pip setuptools wheel

# Clone the target repository
RUN git clone https://github.com/crewAIInc/crewAI /testbed

WORKDIR /testbed

# Checkout the specific commit SHA
RUN git reset --hard 2912c93d77053c1f5e46bfcc67d09fbecf3221c6

# Create Python virtual environment named 'testbed'
RUN python3.11 -m venv /testbed/venv

# Activate virtual environment and install dependencies following the instructions:
# 1. pip install crewai and extras
# 2. pip install tiktoken with prefer-binary (needs Rust compiler - cargo installed above)
# 3. Install UV toolchain: uv lock, uv sync, uv venv, uv build
# 4. pip install the dist tar.gz package (built by uv build)
RUN /bin/bash -c "\
    source /testbed/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install crewai && \
    pip install 'crewai[tools]' && \
    pip install 'crewai[embeddings]' && \
    pip install tiktoken --prefer-binary && \
    python3 -m pip install uv 2>/dev/null || echo 'Installing uv toolchain...' && \
    # Install uv toolchain if not provided by pip, safer to install locally via pip from pypi \
    pip install uv && \
    uv lock && uv sync && uv venv && uv build && \
    pip install dist/*.tar.gz"

# Set environment variables for runtime usage (only notes, no values assigned here)
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED=true

# Write activation of virtualenv into bashrc for interactive use inside container
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc

# Set working directory
WORKDIR /testbed
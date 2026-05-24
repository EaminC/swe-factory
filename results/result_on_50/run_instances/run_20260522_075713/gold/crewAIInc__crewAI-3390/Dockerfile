# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV OTEL_SDK_DISABLED=true

# Use bash shell for compatibility
SHELL ["/bin/bash", "-c"]

# System dependencies installation. Installs essential tools and libraries required for development and runtime (Required)
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    libffi-dev \
    libssl-dev \
    locales-all \
    tzdata \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel && \
    rm -rf /var/lib/apt/lists/*

# Install Rust compiler required for building certain native dependencies (e.g., tiktoken)
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Setup working directory
WORKDIR /testbed/

ARG COMMIT_SHA=45d0c9912c4ddb04fbd7ee515d63dde6c3e8b2cb

# Clone target repository and checkout specific commit SHA and remove origin to prevent accidental pushes
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed && \
    cd /testbed && \
    git reset --hard ${COMMIT_SHA} && \
    git remote remove origin

# Create Python virtual environment and install dependencies and project in editable mode without pre-installing any package from PyPI
RUN python3 -m venv testbed_venv && \
    source testbed_venv/bin/activate && \
    python -m pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir "uv>=0.8.4" && \
    uv sync --all-groups --all-extras && \
    pip install -e . && \
    deactivate

# Add source virtual environment activation to root's bashrc for convenience
RUN echo "source /testbed/testbed_venv/bin/activate" >> /root/.bashrc

# Set working directory for any further instructions or test execution
WORKDIR /testbed/
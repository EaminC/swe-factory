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
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    libssl-dev \
    libffi-dev \
    cargo \
    pkg-config \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, wheel globally
RUN python3.10 -m pip install --upgrade pip setuptools wheel

# Clone the target repository
RUN git clone https://github.com/crewAIInc/crewAI /testbed

WORKDIR /testbed

# Checkout the specific commit SHA
RUN git reset --hard 2912c93d77053c1f5e46bfcc67d09fbecf3221c6

# Create Python virtual environment named 'testbed'
RUN python3.10 -m venv /testbed/venv

# Activate virtual environment and install dependencies and the repo itself in editable mode:
# - install uv toolchain and pinned dependencies using uv commands with UV_VENV_CLEAR=1 to clear existing .venv
# - install tiktoken with prefer-binary (requires Rust which is installed)
# - finally install the local package in editable mode to avoid pre-installing from PyPI
RUN /bin/bash -c "\
    source /testbed/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install tiktoken --prefer-binary && \
    pip install uv && \
    UV_VENV_CLEAR=1 uv lock && uv sync && uv venv && uv build && \
    pip install dist/*.tar.gz && \
    pip install -e ."

# Set environment variables (empty by default, users should provide on container runtime)
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED=true

# Add virtual environment activation to default bashrc for convenience
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc

# Set working directory
WORKDIR /testbed
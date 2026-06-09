# Use Ubuntu 22.04 as the base image for stability and bash support
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies for Python, build tools, git, curl, and rust compiler required for tiktoken builds
RUN apt update && apt install -y \
    git \
    curl \
    build-essential \
    python3.11 \
    python3.11-distutils \
    python3.11-venv \
    python3-pip \
    python3-setuptools \
    libffi-dev \
    rustc \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to the latest version
RUN python3.11 -m pip install --upgrade pip

# Install 'uv' tool globally to run dependency management commands
RUN python3.11 -m pip install uv

# Set working directory to /testbed
WORKDIR /testbed/

# Clone the target repository and checkout the specific commit SHA
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed/ \
    && git reset --hard fbf87327841dd7b92bb04a23fd1575881a3ad3fa \
    && git remote remove origin

# Use uv to create fresh virtual environment in default location .venv by clearing any existing one
RUN /bin/bash -c "\
    uv lock && \
    uv sync && \
    UV_VENV_CLEAR=1 uv venv \
    "

# Install the package in editable development mode with optional tools feature inside the created .venv environment
RUN /bin/bash -c "\
    source /testbed/.venv/bin/activate && \
    pip install 'crewai[tools]' && \
    pip install -e . \
    "

# Install additional fixes recommended for tiktoken (prefer prebuilt wheel)
RUN /bin/bash -c "\
    source /testbed/.venv/bin/activate && \
    pip install --prefer-binary tiktoken || true \
    "

# Set environment variables placeholders; they can be set at container runtime or via an env file
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""

# Set bash as the default shell to ensure shell compatibility in container sessions
ENV SHELL=/bin/bash

# Add command to source the virtual environment automatically on container bash startup
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Final workdir set and shell configured, no test running commands here by design
WORKDIR /testbed/
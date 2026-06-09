# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# System dependencies installation. Installs essential tools and libraries required for development and runtime (Required)
RUN apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    curl \
    ca-certificates \
    locales \
    locales-all \
    tzdata \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    python3.11-dev \
    pkg-config \
    rustc \
    cargo \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Upgrade pip to latest for better dependency management
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install uv tool for dependency management globally
RUN python3 -m pip install uv

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout specific commit SHA
ARG REPO=https://github.com/crewAIInc/crewAI.git
ARG COMMIT_SHA=b4e2db03069fcedbf80eb2130aa91d0cb68b3a43

RUN git clone "$REPO" /testbed/ \
    && cd /testbed/ \
    && git reset --hard "$COMMIT_SHA" \
    && git remote remove origin

# Use uv tool to manage virtual environment and dependencies.
# Use UV_VENV_CLEAR=1 to clear existing .venv and avoid conflicts.
# Install creai with tools extras and editable local package installation.
RUN UV_VENV_CLEAR=1 uv lock && \
    UV_VENV_CLEAR=1 uv sync && \
    UV_VENV_CLEAR=1 uv venv && \
    source .venv/bin/activate && \
    pip install 'crewai[tools]' && \
    pip install -e .

# Install pre-commit hooks as recommended within the created virtual environment.
RUN source .venv/bin/activate && pre-commit install || true

# Add environment variables placeholders for keys (users must set these)
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""

# Add environment activation to bashrc for convenience
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Default workdir
WORKDIR /testbed/
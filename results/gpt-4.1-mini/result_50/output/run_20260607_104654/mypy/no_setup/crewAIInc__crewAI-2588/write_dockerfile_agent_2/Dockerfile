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

# Upgrade pip, setuptools, and wheel for better dependency management
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install uv tool and pre-commit globally for dependency management and git hooks
RUN python3 -m pip install uv pre-commit

# Set working directory
WORKDIR /testbed/

# Build arguments for repo URL and specific commit SHA
ARG REPO=https://github.com/crewAIInc/crewAI.git
ARG COMMIT_SHA=40a441f30eebce88b928db875e4309b892a9ac11

# Clone the repository, checkout the specific commit, and remove origin remote to ensure clean state
RUN git clone "$REPO" /testbed/ \
    && cd /testbed/ \
    && git reset --hard "$COMMIT_SHA" \
    && git remote remove origin

# Use uv tool to lock dependencies, sync, and create virtual environment
RUN UV_VENV_CLEAR=1 uv lock && \
    UV_VENV_CLEAR=1 uv sync && \
    UV_VENV_CLEAR=1 uv venv

# Activate the virtual environment and install extras and editable local package only from the cloned repo (no PyPI pre-install)
RUN source /testbed/.venv/bin/activate && \
    pip install 'crewai[tools]' && \
    pip install -e .

# Install pre-commit git hooks in the virtual environment; failure is not fatal
RUN source /testbed/.venv/bin/activate && pre-commit install || true

# Set environment variables placeholders for required API keys and disable telemetry
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED=true

# Add environment activation command to root bashrc for convenience when entering container
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Reaffirm working directory
WORKDIR /testbed/
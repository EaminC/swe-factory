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

# Upgrade pip, setuptools and wheel for better dependency management
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install uv tool for dependency and virtual environment management globally
RUN python3 -m pip install uv

# Set working directory
WORKDIR /testbed/

# Arguments to specify repository and commit SHA to checkout
ARG REPO=https://github.com/crewAIInc/crewAI.git
ARG COMMIT_SHA=9a6557395595f2491ea253048acf65442ed70418

# Clone repository and checkout specified commit. Remove origin to prevent accidental pushes
RUN git clone "$REPO" /testbed/ \
    && cd /testbed/ \
    && git reset --hard "$COMMIT_SHA" \
    && git remote remove origin

# Use uv tool to manage venv and dependencies including all extras and dev dependencies
RUN UV_VENV_CLEAR=1 uv lock && \
    UV_VENV_CLEAR=1 uv sync --dev --all-extras && \
    UV_VENV_CLEAR=1 uv venv

# Activate virtual environment and install the package in editable mode to ensure local code is used
RUN /bin/bash -c "source /testbed/.venv/bin/activate && pip install -e ."

# Activate virtual environment and install the 'tools' extra (from optional_extras)
RUN /bin/bash -c "source /testbed/.venv/bin/activate && pip install 'crewai[tools]~=0.55.0'"

# Install pre-commit hooks inside the virtual environment
RUN /bin/bash -c "source /testbed/.venv/bin/activate && pre-commit install || true"

# Setup environment variables placeholders for required API keys and OTEL disabled flag
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED=true

# Add environment activation command to root bashrc for convenience
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Set final working directory
WORKDIR /testbed/
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

# Upgrade pip and essential packaging tools
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install uv tool globally for dependency management as required by the project
RUN python3 -m pip install uv pre-commit

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout specific commit SHA; remove git origin to avoid unwanted pushes
ARG REPO=https://github.com/crewAIInc/crewAI.git
ARG COMMIT_SHA=37979a0ca1ab7c657ed005fdfeabacaa1a7a3568

RUN git clone "$REPO" /testbed/ \
    && cd /testbed/ \
    && git reset --hard "$COMMIT_SHA" \
    && git remote remove origin

# Use uv tool to manage virtual environment and dependencies:
# - Clear existing virtualenv if any
# - Lock and sync all dependencies including development and extras
# - Create and activate virtual environment
RUN UV_VENV_CLEAR=1 uv lock \
    && UV_VENV_CLEAR=1 uv sync --dev --all-extras \
    && UV_VENV_CLEAR=1 uv venv

# Install creai with tools extras and install local editable package to ensure latest local code usage
RUN source /testbed/.venv/bin/activate \
    && pip install 'crewai[tools]' \
    && pip install -e . \
    && pre-commit install || true

# Add environment variables placeholders (must be set externally for correct runtime behavior)
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED=""

# Add environment activation to bashrc for convenience in interactive shells
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Final explicit workdir setup (redundant but explicit)
WORKDIR /testbed/
# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies essential for build and runtime
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

# Upgrade pip, setuptools, and wheel for latest dependency management improvements
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install uv tool globally to manage dependencies and virtual environment
RUN python3 -m pip install uv

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit SHA provided as build arg
ARG REPO=https://github.com/crewAIInc/crewAI.git
ARG COMMIT_SHA=c96d4a6823fb5a3ef196427612b784efe504fdce

RUN git clone "$REPO" /testbed/ \
    && cd /testbed/ \
    && git reset --hard "$COMMIT_SHA" \
    && git remote remove origin

# Use uv to lock dependencies, sync (including dev and all extras), create virtual environment;
# Activate it and install crewai with extras and editable local installation
RUN UV_VENV_CLEAR=1 uv lock && \
    UV_VENV_CLEAR=1 uv sync --dev --all-extras && \
    UV_VENV_CLEAR=1 uv venv && \
    source .venv/bin/activate && \
    pip install crewai && \
    pip install 'crewai[tools]' && \
    pip install 'crewai[embeddings]' && \
    pip install tiktoken --prefer-binary && \
    pip install -e .

# Install pre-commit hooks inside the virtual environment; do not fail build if this step fails
RUN source .venv/bin/activate && pre-commit install || true

# Set environment variables placeholders for API keys as recommended
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""

# Disable telemetry as recommended
ENV OTEL_SDK_DISABLED=true

# Load virtual environment automatically for bash sessions
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Confirm the working directory
WORKDIR /testbed/
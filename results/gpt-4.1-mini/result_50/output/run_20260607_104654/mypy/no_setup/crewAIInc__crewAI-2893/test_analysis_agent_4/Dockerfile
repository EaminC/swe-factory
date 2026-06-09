# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies essential for Python, build tools, git, curl, and rust compiler required for some packages
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

# Ensure python3 points to python3.11 explicitly
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Upgrade pip, setuptools, and wheel for latest dependency resolution improvements
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install uv tool globally for dependency and virtual environment management
RUN python3 -m pip install uv

# Set working directory
WORKDIR /testbed/

# Arguments to specify repository and commit SHA to checkout
ARG REPO=https://github.com/crewAIInc/crewAI.git
ARG COMMIT_SHA=9a6557395595f2491ea253048acf65442ed70418

# Clone repository and checkout specified commit. Remove origin remote
RUN git clone "$REPO" /testbed/ \
    && cd /testbed/ \
    && git reset --hard "$COMMIT_SHA" \
    && git remote remove origin

# Use uv tool to lock dependencies, sync with all extras and dev, and create virtual environment in one step
RUN UV_VENV_CLEAR=1 uv lock && \
    UV_VENV_CLEAR=1 uv sync --dev --all-extras && \
    UV_VENV_CLEAR=1 uv venv

# Activate virtual environment and install the package locally in editable mode only (no redundant PyPI package installations)
RUN /bin/bash -c "source /testbed/.venv/bin/activate && pip install -e ."

# Install pre-commit hooks inside the virtual environment, ignoring any errors to avoid failing the build
RUN /bin/bash -c "source /testbed/.venv/bin/activate && pre-commit install || true"

# Set environment variables placeholders for API keys and disable telemetry as recommended
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED=true

# Add activation of virtual environment to root bashrc for convenience in interactive sessions
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Final working directory set
WORKDIR /testbed/
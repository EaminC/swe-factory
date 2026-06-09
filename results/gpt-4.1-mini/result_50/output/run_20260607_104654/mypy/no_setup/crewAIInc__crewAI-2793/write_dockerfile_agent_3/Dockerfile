# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# System dependencies installation: tools, libraries, compilers, python 3.11 and build essentials
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

# Make python3 point to python3.11 explicitly
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Upgrade pip, setuptools and wheel for latest dependency resolution improvements
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install uv and pre-commit globally for dependency management and hooks installation
RUN python3 -m pip install uv pre-commit

# Set working directory to /testbed
WORKDIR /testbed/

# Clone the repository from GitHub and checkout the specific commit SHA (commit SHA passed as build arg)
ARG REPO=https://github.com/crewAIInc/crewAI.git
ARG COMMIT_SHA=fed397f74590a3f1c3be3bfca96e4967fe38a3e1

RUN git clone "$REPO" /testbed/ \
    && cd /testbed/ \
    && git reset --hard "$COMMIT_SHA" \
    && git remote remove origin

# Use uv to lock dependencies, sync, and create fresh virtual environment clearing any existing one
RUN UV_VENV_CLEAR=1 uv lock && \
    UV_VENV_CLEAR=1 uv sync && \
    UV_VENV_CLEAR=1 uv venv

# Activate the virtual environment, install 'crewai[tools]' and install the cloned repo in editable mode
RUN /bin/bash -c "source /testbed/.venv/bin/activate && pip install 'crewai[tools]' && pip install -e ."

# Install pre-commit hooks; ignore failures if pre-commit not configured
RUN /bin/bash -c "source /testbed/.venv/bin/activate && pre-commit install || true"

# Environment variable placeholders; users/CI must set these externally with valid API keys before running tests
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""

# Disable telemetry to reduce noise and logs per project recommendations
ENV OTEL_SDK_DISABLED=true

# Enable automatic activation of the virtual environment on root user shell start
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Confirm working directory
WORKDIR /testbed/
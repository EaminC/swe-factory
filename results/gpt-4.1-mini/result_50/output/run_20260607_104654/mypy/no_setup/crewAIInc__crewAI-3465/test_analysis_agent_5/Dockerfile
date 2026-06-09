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
    pre-commit \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Upgrade pip, setuptools, and wheel for better dependency management
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install UV tool for dependency management globally
RUN python3 -m pip install uv

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout specific commit SHA
ARG REPO=https://github.com/crewAIInc/crewAI.git
ARG COMMIT_SHA=1dc4f2e8977eb68b54dc3184a9548dfe10e57f3e

RUN git clone "$REPO" /testbed/ \
    && cd /testbed/ \
    && git reset --hard "$COMMIT_SHA" \
    && git remote remove origin

# Use uv tool to manage virtual environment and dependencies.
# Clear existing .venv to avoid conflicts.
RUN UV_VENV_CLEAR=1 uv lock && \
    UV_VENV_CLEAR=1 uv sync && \
    UV_VENV_CLEAR=1 uv venv

# Activate virtual environment and install creai with tools extras and install local package in editable mode,
# Without explicitly installing embedchain to avoid redundant or ineffective pip installs;
# rely on requirements as declared in the repo and extras for proper install coverage.
RUN /bin/bash -c "source .venv/bin/activate && \
    pip install 'crewai[tools]' && \
    pip install -e ."

# Install pre-commit hooks within the virtual environment
RUN /bin/bash -c "source .venv/bin/activate && pre-commit install || true"

# Add environment variable placeholders for API keys (to be set at container runtime)
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED="true"

# Add environment activation to root user's bashrc for convenience
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Set default working directory
WORKDIR /testbed/
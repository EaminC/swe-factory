# Base image with Bash and basic utilities
FROM --platform=linux/x86_64 ubuntu:22.04

# Set environment variables to avoid interactive prompts
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies including Python 3.10, git, and build tools
RUN apt-get update && apt-get install -y \
    wget \
    git \
    curl \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3.10 \
    python3.10-dev \
    python3.10-distutils \
    python3.10-venv \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Install uv (modern Python package installer)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && ln -s /root/.local/bin/uv /usr/local/bin/uv

# Set working directory
WORKDIR /testbed

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed \
    && git reset --hard 28cfb99a21902d330dab6cb3762a739198cf972f

# Create virtual environment using uv
RUN uv venv /testbed/.venv
ENV PATH="/testbed/.venv/bin:$PATH"

# Install build system requirements using uv pip
RUN uv pip install --upgrade pip \
    && uv pip install setuptools>=45 wheel

# Install the package in development mode with all core and optional dependencies
# Using uv pip for consistency and reliability
RUN uv pip install -e ".[qdrant,mem0ai,pdf-reader,oceanbase]"

# Install development dependencies for testing
RUN uv pip install \
    pre-commit \
    pytest \
    pytest-forked \
    fakeredis \
    aiosqlite \
    greenlet \
    py-openjudge

# Set up pre-commit (but don't run it)
RUN pre-commit install

# Set environment variables for API keys (placeholder values for test environment)
ENV DASHSCOPE_API_KEY="dummy_key_for_testing"
ENV GAODE_API_KEY="dummy_key_for_testing"

# Ensure proper permissions
RUN chmod -R 755 /testbed

# Clean up to reduce image size
RUN uv cache clean \
    && rm -rf /root/.cache
# Use Ubuntu 22.04 as the base image for bash compatibility and stability
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies, including git, curl, wget, and build tools
# Use Python 3.10 (default in Ubuntu 22.04) instead of 3.12 as 3.12 packages are unavailable in Ubuntu 22.04 repos
RUN apt update && apt install -y \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Make python3.10 the default python3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Upgrade pip and install uv package manager using python3
RUN python3 -m pip install --upgrade pip setuptools wheel \
    && python3 -m pip install uv

# Install bun (frontend package manager) - install via official bun install script
RUN curl -fsSL https://bun.sh/install | bash \
    && mv /root/.bun/bin/bun /usr/local/bin/bun

# Set locale and timezone
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Clone the target repo and checkout the specific commit, then set up the environment
WORKDIR /testbed/
RUN git clone https://github.com/ValueCell-ai/valuecell.git /testbed \
    && git checkout a1ee111f912c54fb0678b608b98c47f5f8d17942 \
    && chmod -R 777 /testbed

# Backend dependencies installation using uv package manager in the python folder with extra dev
RUN cd python \
    # Copy .env.example to .env as required for env config step (no editing here, done externally)
    && cp .env.example .env \
    # Sync dependencies with uv including dev extras as recommended
    && uv sync --extra dev

# Install the backend python package itself in editable mode including dev extras (alternative to uv sync)
RUN cd python && uv pip install --editable ".[dev]"

# Frontend dependencies installation using bun in the frontend directory
RUN cd frontend && bun install

# Expose environment variables related to python path and bun (optional for convenience)
ENV PATH="/root/.bun/bin:$PATH"

# The container is now ready with python 3.10, uv, bun, all repo dependencies installed, with code checked out at the specified commit.
# Test execution will be handled outside of the Dockerfile.

# Set default working directory
WORKDIR /testbed/
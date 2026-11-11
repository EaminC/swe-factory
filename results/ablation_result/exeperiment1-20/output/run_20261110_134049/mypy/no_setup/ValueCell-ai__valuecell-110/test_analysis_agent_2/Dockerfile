# Use Ubuntu 22.04 to ensure stable and compatible base environment with bash
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Add deadsnakes PPA to install Python 3.12 and related packages
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update

# Install essential system dependencies, git, curl, wget, python3.12 and build tools
RUN apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    locales \
    locales-all \
    tzdata \
    ca-certificates \
    python3.12 \
    python3.12-venv \
    python3.12-distutils \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.12 and pip is installed properly
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 && \
    update-alternatives --set python3 /usr/bin/python3.12 && \
    python3 -m ensurepip --upgrade

# Upgrade pip and install uv CLI tool for dependency management
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install uv

# Set working directory
WORKDIR /testbed/

# Clone the repository, checkout the specific commit, and install dependencies in development mode
ARG REPO=https://github.com/ValueCell-ai/valuecell.git
ARG COMMIT_SHA=f4d5eded95c65cfac06d78dea79dbe9459c4b9c0

RUN git clone $REPO . && \
    git reset --hard $COMMIT_SHA

# Copy example .env file to .env as instructed (can be modified later if needed)
RUN cp .env.example .env || echo ".env.example not found, skipping .env copy"

# Install development dependencies using uv tool as specified in the context
RUN uv sync --extra dev

# Install the repository in editable mode (development mode)
RUN python3 -m pip install --editable .

# Set environment variable for python path and locale to avoid locale warnings
ENV PYTHONPATH=/testbed/
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Add uv and python user base binary directory to PATH explicitly to ensure usage
ENV PATH="/root/.local/bin:$PATH"

# Setup bashrc to source python environment on container run
RUN echo 'export PATH="/root/.local/bin:$PATH"' >> /root/.bashrc

# Default shell is bash already specified via SHELL directive
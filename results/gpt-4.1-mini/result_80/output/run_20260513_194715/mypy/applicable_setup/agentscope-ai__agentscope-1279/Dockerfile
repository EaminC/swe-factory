# Use Ubuntu 22.04 as base image with x86_64 architecture and bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies required for building and running Python 3.10 and development tools
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.10 and upgrade pip, setuptools, and wheel
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
    && python3 -m pip install --upgrade pip setuptools wheel

# Create and activate a virtual environment named testbed
RUN python3 -m venv /opt/testbed

ENV VIRTUAL_ENV=/opt/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Clone the target repository, checkout the specified commit SHA, and install it in editable mode with dev dependencies
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    cd /testbed && \
    git reset --hard 28cfb99a21902d330dab6cb3762a739198cf972f && \
    pip install --upgrade pip setuptools wheel && \
    # Install the repository itself in development mode with dev extras to get all dependencies including testing tools
    pip install ".[dev]" && \
    # It's recommended to install any additional optional dev dependencies that may not be included in the above extras
    pip install pre-commit pytest pytest-forked fakeredis aiosqlite greenlet py-openjudge

# Set the working directory to the cloned repo
WORKDIR /testbed

# Default shell remains bash for all RUN commands
SHELL ["/bin/bash", "-c"]
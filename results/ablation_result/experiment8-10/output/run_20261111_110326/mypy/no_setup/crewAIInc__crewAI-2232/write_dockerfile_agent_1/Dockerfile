# Use Ubuntu 22.04 as base image for stable bash environment and broad compatibility
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, curl, wget, build essentials, python3.10, python3-venv, and others for building and running python packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip for python3.10 to latest version (to handle modern package wheels)
RUN python3.10 -m pip install --upgrade pip setuptools wheel

# Create and activate virtual environment 'testbed' with python3.10
RUN python3.10 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Clone the target repository into /testbed, checkout the specific commit, and install package and dev dependencies based on pyproject.toml
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed && \
    cd /testbed && \
    git reset --hard 34d299345677c7ce26b1368f240c559596526fa7

WORKDIR /testbed

# Install Poetry (dependency manager referenced indirectly by pyproject.toml usually)
RUN curl -sSL https://install.python-poetry.org | python3.10 - --version 1.8.0
ENV PATH="/root/.local/bin:$PATH"

# Use Poetry to install core, optional and dev dependencies (including pytest and other testing deps) and install package in editable mode
RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi --with dev,optional && \
    pip install -e .

# Add bashrc command to activate virtual environment on container start (for convenience)
RUN echo "source /opt/venv/bin/activate" >> /root/.bashrc

# Default working directory set as required
WORKDIR /testbed
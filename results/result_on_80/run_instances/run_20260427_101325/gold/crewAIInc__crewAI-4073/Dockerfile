# Use Ubuntu 22.04 as base image to ensure bash shell and stable environment
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, build essentials, python 3.10, curl, Rust compiler, and other essential tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        curl \
        git \
        build-essential \
        ca-certificates \
        wget \
        locales \
        locales-all \
        tzdata \
        python3.10 \
        python3.10-venv \
        python3.10-distutils \
        python3-pip && \
    # Setup python3 alias to python3.10 explicitly
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    # Upgrade pip for python3.10
    python3 -m pip install --upgrade pip && \
    # Install Rust compiler required for building some dependencies
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    # Add cargo path to global PATH
    echo "source $HOME/.cargo/env" >> /root/.bashrc && \
    # Clean up apt caches
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.cargo/bin:${PATH}"

# Create and activate python virtual environment 'testbed'
RUN python3 -m venv /testbed/venv

# Set environment variables for virtual environment usage
ENV VIRTUAL_ENV=/testbed/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Remove /testbed if it exists to ensure clean clone
RUN rm -rf /testbed

# Clone the repo and checkout specified commit
RUN git clone https://github.com/crewAIInc/crewAI /testbed && \
    cd /testbed && \
    git checkout e43c7debbd444486df77c83fc604641e18f1cd8a

WORKDIR /testbed/

# Upgrade pip inside the venv
RUN pip install --upgrade pip

# Install uv tool version 0.8.4
RUN pip install uv==0.8.4

# Use uv commands to sync dependencies and install all extras
RUN uv sync --all-groups --all-extras

# Install the cloned crewai package in development mode, no pre-install from PyPI
RUN pip install -e .

# Install crewai extras [tools] and [embeddings] for additional dependencies like tiktoken with preferred binary wheels
RUN pip install 'crewai[tools]' 'crewai[embeddings]' --prefer-binary

# Ensure permissions - make sure the /testbed directory is writable
RUN chmod -R 777 /testbed
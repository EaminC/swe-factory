# Use Ubuntu 22.04 as the base image for stability and bash availability
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Update and install core system dependencies including git, curl, wget, and python 3.10 components
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    locales \
    locales-all \
    tzdata \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to latest version compatible with Python 3.10
RUN python3.10 -m pip install --upgrade pip setuptools wheel

# Install Dapr CLI as required by the environment setup instructions
RUN wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash

# Set python3 alternative to python3.10 explicitly
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Set working directory before cloning to avoid any cache/diff issues
WORKDIR /testbed/

# Clone the repository and checkout the specified commit (passed as build-arg)
ARG REPO=https://github.com/dapr/dapr-agents.git
ARG COMMIT_SHA=c872c5a8bd1d5cd9de745b1a680b1e5e1fb6c0c5
RUN git clone --recursive $REPO /testbed && \
    cd /testbed && \
    git reset --hard $COMMIT_SHA && \
    git submodule update --init --recursive

# Set up python virtual environment inside /testbed/testbed
RUN python3.10 -m venv /testbed/testbed

# Install the project in editable/development mode inside the virtual environment without installing from PyPI
RUN /testbed/testbed/bin/pip install --upgrade pip setuptools wheel && \
    cd /testbed && \
    /testbed/testbed/bin/pip install -e .

# Do NOT install dapr SDK separately to avoid conflict with repo install (assume repo dependencies are handled in setup)
# Ensure bash shell usage and source virtualenv activation in bashrc for convenience
RUN echo 'source /testbed/testbed/bin/activate' >> /root/.bashrc

# Set environment SHELL to bash explicitly
ENV SHELL=/bin/bash
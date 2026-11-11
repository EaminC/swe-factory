# Use Ubuntu 22.04 as the base image for stability and bash availability
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Update and install core system dependencies including git, curl, wget, and Python 3.10 components.
# Split install steps to reduce layer size and isolate failure points.
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    locales \
    locales-all \
    tzdata \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, wheel in separate step to isolate potential issues
RUN python3.10 -m pip install --upgrade pip setuptools wheel

# Install Dapr CLI - installed in isolated step allowing cache reuse and avoiding conflicts
RUN wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash

# Set python3 alternative explicitly
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Create and set working directory early to avoid cache/diff issues on clone
WORKDIR /testbed/

# Clone the repository and checkout the specified commit (passed as build-arg)
ARG REPO=https://github.com/dapr/dapr-agents.git
ARG COMMIT_SHA=c872c5a8bd1d5cd9de745b1a680b1e5e1fb6c0c5
RUN git clone --recursive $REPO /testbed \
    && cd /testbed \
    && git reset --hard $COMMIT_SHA \
    && git submodule update --init --recursive

# Create Python virtual environment
RUN python3.10 -m venv /testbed/testbed

# Upgrade pip, setuptools, wheel inside the virtual environment and install project in editable mode
RUN /testbed/testbed/bin/pip install --upgrade pip setuptools wheel \
    && cd /testbed \
    && /testbed/testbed/bin/pip install -e .

# Add virtual environment activation to root bashrc for interactive shell convenience
RUN echo 'source /testbed/testbed/bin/activate' >> /root/.bashrc

# Set environment SHELL to bash explicitly
ENV SHELL=/bin/bash
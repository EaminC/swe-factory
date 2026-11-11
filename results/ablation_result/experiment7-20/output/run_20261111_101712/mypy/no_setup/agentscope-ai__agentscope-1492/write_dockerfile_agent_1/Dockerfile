# Use Ubuntu 22.04 as base image for stability and bash support
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install essential system dependencies and Python 3.10+
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    curl \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to latest version for Python 3.10
RUN python3.10 -m pip install --no-cache-dir --upgrade pip

# Set workdir
WORKDIR /testbed/

# Clone the repository and checkout the specified commit SHA
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    git reset --hard 08b047e05b02b27a290ee1b850fb75210f186cdb && \
    git remote remove origin

# Create Python virtual environment named testbed and install repo in editable mode
RUN python3.10 -m venv /testbed/testbed_env

# Install the package and dependencies inside the virtual environment without running tests
RUN /bin/bash -c "\
    source /testbed/testbed_env/bin/activate && \
    pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir pre-commit && \
    pip install --no-cache-dir -e ."

# Add bashrc entry for automatic venv activation on container start/run
RUN echo "source /testbed/testbed_env/bin/activate" >> /root/.bashrc

# Default shell to bash
SHELL ["/bin/bash", "-c"]
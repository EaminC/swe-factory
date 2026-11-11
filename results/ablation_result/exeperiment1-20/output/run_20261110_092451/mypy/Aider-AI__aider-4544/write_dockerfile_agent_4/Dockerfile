# Use Ubuntu 22.04 as base image for a stable environment with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies, Python 3.10 (within 3.9-3.12 range), git, build tools, and necessary utilities
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
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set locale environment variables to avoid locale-related warnings
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Update alternatives to use python3.10 as python3 and python executable
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && python -m pip install --upgrade pip setuptools wheel

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specified commit as authoritative source of truth
# To mitigate issues with git reset, combine cloning and checkout in one step
RUN git clone --branch main --single-branch https://github.com/Aider-AI/aider /testbed/ \
    && cd /testbed \
    && git fetch --all \
    && git checkout 249e38976508007aeda1c74344c83e1e37ec8e14

# Create python virtual environment and install project and all dependencies in editable mode within venv
RUN python -m venv /testbed/testbed_venv

RUN /bin/bash -c "source /testbed/testbed_venv/bin/activate \
    && pip install --upgrade pip \
    && pip install -e . \
    && if [ -f requirements.txt ]; then pip install -r requirements.txt; fi \
    && if [ -d requirements ] && [ -f requirements/requirements-dev.txt ]; then pip install -r requirements/requirements-dev.txt; fi"

# Ensure bash environment activates the virtual environment by default upon container start
RUN echo "source /testbed/testbed_venv/bin/activate" >> /root/.bashrc
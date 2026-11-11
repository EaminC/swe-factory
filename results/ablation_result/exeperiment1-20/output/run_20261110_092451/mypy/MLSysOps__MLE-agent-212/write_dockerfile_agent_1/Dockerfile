# Use Ubuntu 20.04 as base image to match CI environment and ensure bash support
FROM --platform=linux/x86_64 ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, python3.11, pip, build essentials and others required
RUN apt-get update && apt-get install -y \
    software-properties-common \
    git \
    wget \
    build-essential \
    curl \
    ca-certificates \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3.11-dev \
    && rm -rf /var/lib/apt/lists/*

# Set python3 and pip3 alternatives to python3.11 and pip for python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && wget https://bootstrap.pypa.io/get-pip.py -O get-pip.py \
    && python3 get-pip.py \
    && rm get-pip.py

# Create a python virtual environment named testbed and activate it
RUN python3 -m venv /opt/testbed

ENV PATH="/opt/testbed/bin:$PATH"

# Upgrade pip inside venv and install necessary pinned dependencies plus the local package in editable mode
# The pinned versions and other deps collected from the requirements information will be installed from requirements.txt in the repo after cloning
# Therefore, install git now, clone repo next, then install dependencies inside venv

# Set workdir before cloning repo
WORKDIR /testbed/

# Clone repository and checkout to the specified commit SHA (must be provided during docker build)
ARG COMMIT_SHA=a405d8130cbb24e6556fb0125f634c3fb738eb2a
RUN git clone https://github.com/MLSysOps/MLE-agent.git . \
    && git reset --hard ${COMMIT_SHA} \
    && git submodule update --init --recursive

# Install/upgrade pip, then install requirements and the package itself in editable mode
RUN pip install --upgrade pip wheel setuptools \
    && if [ -f requirements.txt ]; then pip install -r requirements.txt; fi \
    && pip install mle-agent -U \
    && pip install -e .

# Fix permission to avoid potential permission issues
RUN chmod -R a+rwx /testbed

# Add conda-like activation to bashrc to ensure venv activation for interactive shells
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Set working directory to /testbed
WORKDIR /testbed/
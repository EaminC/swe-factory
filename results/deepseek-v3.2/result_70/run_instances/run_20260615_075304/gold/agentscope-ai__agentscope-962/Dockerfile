# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation. Installs essential tools and libraries required for development and runtime (Required)
RUN apt update && apt install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    python3 \
    python3-pip \
    python-is-python3 \
    curl \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install package and environment manager. Downloads and sets up miniconda
RUN wget 'https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-2-Linux-x86_64.sh' -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

RUN conda init --all \
    && conda config --append channels conda-forge

# Sets up a dedicated environment with specific Python version 3.10 as required
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -n testbed python=3.10 -y && \
    conda activate testbed && \
    pip install --upgrade pip && \
    pip install setuptools==78.1.1 wheel==0.45.1"

# set default workdir to testbed. (Required)
WORKDIR /testbed/

# Target Project setup. Clones source code, checkouts to the target version, configures it, and installs project-specific dependencies
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/agentscope-ai/agentscope /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard a2bf80ec96e29cb760ac6d4018680d6af68c9416 && \
    git remote remove origin"

# Install the project in development mode with all dependencies including dev
# Using exact versions from CI workflow
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    cd /testbed && \
    pip install -q -e .[dev]"

# Install additional test dependencies (coverage as per unittest.yml)
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    pip install coverage pytest"

# Set up environment for test execution
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc

# Note: Tests will be executed separately via eval script, not during Docker build
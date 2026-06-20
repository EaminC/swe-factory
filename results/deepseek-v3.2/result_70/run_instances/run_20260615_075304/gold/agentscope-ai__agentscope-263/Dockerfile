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
    libtiff-dev \
    python3 \
    python3-pip \
    python-is-python3 \
    jq \
    curl \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install package and environment manager. Downloads and sets up a lightweight environment management tool
RUN wget 'https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-2-Linux-x86_64.sh' -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

RUN conda init --all \
    && conda config --append channels conda-forge

# Sets up a dedicated environment with specific dependencies for the target environment
# Using Python 3.9+ as required by the project
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -n testbed python=3.9 -y && \
    conda activate testbed && \
    pip install --upgrade pip"

# set default workdir to testbed. (Required)
WORKDIR /testbed/

# Target Project setup. Clones source code, checkouts to the target version, configures it, and installs project-specific dependencies
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/agentscope-ai/agentscope /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard f761cf215fbd1f0a1e57eb2d073229628b77f462 && \
    git remote remove origin"

# Install the project in development mode with all dependencies
# Using the full installation to ensure all required packages are available
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    cd /testbed && \
    pip install -e .[full,dev]"

# Set up environment for test execution
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc

# Note: Tests will be executed separately via eval script, not during Docker build
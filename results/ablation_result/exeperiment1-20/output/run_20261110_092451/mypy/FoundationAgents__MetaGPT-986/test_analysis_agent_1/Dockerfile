# Base image specification. Use Ubuntu 22.04 with bash shell by default
FROM --platform=linux/x86_64 ubuntu:22.04

# Use noninteractive frontend for apt commands
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, wget, bzip2, curl, ca-certificates, build tools, and utilities
RUN apt-get update && apt-get install -y \
    git \
    wget \
    bzip2 \
    curl \
    ca-certificates \
    build-essential \
    locales \
    locales-all \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda3 (latest Python 3.9 environment)
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_23.3.1-0-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/miniconda3 && \
    rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda and set conda-forge channel
RUN conda init bash && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority strict

# Create and activate conda environment 'metagpt' with python 3.9
# Install pip and upgrade it first
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -y -n metagpt python=3.9 && \
    conda activate metagpt && \
    pip install --upgrade pip"

# Set working directory for cloning repository
WORKDIR /testbed/

# Clone the target repository and checkout the specified commit bbb9645f7c60c35177922d10ccc7ed4b90d261c3
RUN git clone https://github.com/FoundationAgents/MetaGPT.git /testbed && \
    cd /testbed && \
    git reset --hard bbb9645f7c60c35177922d10ccc7ed4b90d261c3

# Install python dependencies:
# - Install test dependencies specified in extras_require['test'] of setup.py using pip
# - Install the target package in editable/development mode (pip install -e .)
# - Also run the test dependencies installation shell script (run_install_deps.sh) prior to test runs is handled by eval agent, so here just install deps

RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate metagpt && \
    pip install -e .[test]"

# Copy tests/config2.yaml to ~/.metagpt/config2.yaml according to context in eval (config initialization is done by metagpt --init-config)
# Since COPY disallowed, the eval agent will handle config file placement during test runtime
# Only ensure metagpt CLI is available (installed by pip install metagpt via the -e . option)

# Add conda environment activation to root user's bashrc for interactive shell use
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate metagpt" >> /root/.bashrc

# Default shell is /bin/bash and working directory /testbed is set
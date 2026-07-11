# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation. Installs essential tools and libraries required for development and runtime (Required)
RUN apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3-dev \
    python3-pip \
    python-is-python3 \
    curl \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install package and environment manager (Conda)
RUN wget 'https://repo.anaconda.com/miniconda/Miniconda3-py310_23.11.0-2-Linux-x86_64.sh' -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

RUN conda init --all \
    && conda config --append channels conda-forge

# Sets up a dedicated environment with specific Python version for the target environment
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -n testbed python=3.9 -y && \
    conda activate testbed && \
    pip install --upgrade pip"

# Set default workdir to testbed. (Required)
WORKDIR /testbed/

# Target Project setup. Clones source code, checkouts to the target version, configures it, and installs project-specific dependencies
ARG COMMIT_SHA=be8db4cc484b77d0d3bc60a012e9035c4395bee3
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/modelscope/agentscope.git /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard ${COMMIT_SHA} && \
    git remote remove origin && \
    pip install -e .[full]"

# Ensure the conda environment is activated by default for subsequent RUN commands and interactive shells
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc

# Set default shell to bash explicitly
SHELL ["/bin/bash", "-c"]
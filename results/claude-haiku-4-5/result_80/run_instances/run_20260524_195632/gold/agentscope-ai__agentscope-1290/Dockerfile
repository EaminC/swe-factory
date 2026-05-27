# Base image specification - using Ubuntu 22.04 for stability and bash compatibility
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation - essential tools and libraries for development
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    libtiff-dev \
    python3 \
    python3-pip \
    python3-venv \
    python-is-python3 \
    jq \
    curl \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda for environment and dependency management
RUN wget 'https://repo.anaconda.com/miniconda/Miniconda3-py310_23.11.0-2-Linux-x86_64.sh' -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda for all shells
RUN conda init --all \
    && conda config --append channels conda-forge

# Create and activate conda environment with Python 3.10+
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -n testbed python=3.10 -y"

# Set default workdir to testbed
WORKDIR /testbed/

# Clone the target repository and setup the project
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/agentscope-ai/agentscope /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard 28cfb99a21902d330dab6cb3762a739198cf972f && \
    git remote remove origin"

# Install project dependencies with development extras
# This includes all core dependencies and development/testing dependencies
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    cd /testbed && \
    pip install --upgrade pip setuptools wheel && \
    pip install -e '.[dev]'"

# Configure bash to activate conda environment by default
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc

# Set shell to bash for proper environment activation
SHELL ["/bin/bash", "-c"]
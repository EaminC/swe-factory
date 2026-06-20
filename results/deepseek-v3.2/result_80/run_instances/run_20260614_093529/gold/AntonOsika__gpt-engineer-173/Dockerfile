# Base image specification. Defines the foundation OS and architecture for the container
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation. Installs essential tools and libraries required for development and runtime
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

# Install patch (required for some patching operations)
RUN apt install -y patch

# Install Miniconda for environment management
RUN wget 'https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-2-Linux-x86_64.sh' -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH
RUN conda init --all \
    && conda config --append channels conda-forge

# Create and activate a dedicated environment with Python 3.10 (as used in CI)
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -n testbed python=3.10 -y && \
    conda activate testbed && \
    pip install --upgrade pip setuptools wheel"

# Set default workdir to testbed
WORKDIR /testbed/

# Target Project setup. Clone source code, checkout target version, and install project
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/AntonOsika/gpt-engineer.git /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard 35c35b3ffab89cfa0eb714f5d5c28c6eb2aa7faa && \
    git remote remove origin"

# Install project dependencies and development setup
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    pip install -r requirements.txt && \
    pip install -e ."

# Install test dependencies (as in CI setup)
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    pip install pytest pytest-cov"

# Set up pre-commit hooks (optional, but part of development setup)
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    pre-commit install"

# Set environment variable for OpenAI API key (required for execution, can be overridden)
ENV OPENAI_API_KEY="dummy-key-for-testing"

# Ensure conda environment is activated in bash sessions
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc
# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation. Installs essential tools and libraries required for development and runtime (Required)
RUN apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    curl \
    ca-certificates \
    libffi-dev \
    python3 \
    python3-pip \
    python3-venv \
    python3-setuptools \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda to manage the Python environment
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-2-Linux-x86_64.sh -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

# Configure conda channels without creating the environment yet to reduce memory usage
RUN conda config --append channels conda-forge

# Create conda environment with Python 3.10 separately to reduce peak memory usage
RUN /bin/bash -c " \
    source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -n testbed python=3.10 -y \
    "

# Set workdir
WORKDIR /testbed/

# Clone the repository and checkout the commit SHA
RUN /bin/bash -c " \
    source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/agentscope-ai/agentscope /testbed && \
    cd /testbed && \
    git reset --hard 046298720d12639ed54c9d643103b48c5aaaf169 \
    "

# Upgrade pip and setuptools, install required libraries and the package in editable mode in separate steps to mitigate memory pressure
RUN /bin/bash -c " \
    source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    pip install --upgrade pip setuptools wheel \
    "

RUN /bin/bash -c " \
    source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    pip install grpcio==1.60.0 grpcio-tools==1.60.0 protobuf==4.25.0 gradio==4.19.1 modelscope_studio==0.0.5 Flask==3.0.0 Flask-Cors==4.0.0 Flask-SocketIO==5.3.6 dashscope==1.14.1 'openai>=1.3.0' 'ollama>=0.1.7' 'google-generativeai>=0.4.0' pytest pytest-cov pre-commit numpy requests Pillow \
    "

RUN /bin/bash -c " \
    source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    pip install -e . && \
    pip install -e .[dev] \
    "

# Ensure bash is default shell
SHELL ["/bin/bash", "-c"]

# Add conda source and environment activation to bashrc for convenience
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc
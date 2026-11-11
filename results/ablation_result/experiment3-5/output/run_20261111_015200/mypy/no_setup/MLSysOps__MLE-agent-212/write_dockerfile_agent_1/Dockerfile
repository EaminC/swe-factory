# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# System dependencies installation. Installs essential tools and libraries required for development and runtime (Required)
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    libffi-dev \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install pip for Python 3.11 explicitly (in case python3-pip points to older pip)
RUN python3.11 -m ensurepip --upgrade \
    && python3.11 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Install Miniconda for environment management
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-2-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/miniconda3 \
    && rm /tmp/miniconda.sh
ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda and create testbed environment with python 3.11
RUN conda init bash \
    && /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
       conda create --yes -n testbed python=3.11 && \
       conda clean --all --yes"

# Set working directory
WORKDIR /testbed/

# Clone target repository, checkout the specific commit, and install dependencies in dev mode
ARG COMMIT_SHA=a405d8130cbb24e6556fb0125f634c3fb738eb2a
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/MLSysOps/MLE-agent.git /testbed && \
    cd /testbed && \
    git checkout ${COMMIT_SHA} && \
    pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install -e ."

# Ensure bashrc sources conda environment activation by default
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh" >> /root/.bashrc && \
    echo "conda activate testbed" >> /root/.bashrc
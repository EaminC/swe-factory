# Use Ubuntu 22.04 base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04

# Set non-interactive frontend for apt and timezone environment variable
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies and tools
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

# Install Miniconda3 for Python 3.9 environment (pin a stable version)
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_23.1.0-1-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/miniconda3 && \
    rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda and configure conda-forge channel
RUN conda init bash
RUN conda config --add channels conda-forge
RUN conda config --set channel_priority strict

# Create conda environment 'metagpt' with Python 3.9 in separate steps for better layer handling
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && conda create -y -n metagpt python=3.9"
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate metagpt && pip install --upgrade pip"

# Set working directory for source code
WORKDIR /testbed/

# Clone repository and checkout specific commit
RUN git clone https://github.com/FoundationAgents/MetaGPT.git /testbed
RUN cd /testbed && git reset --hard bbb9645f7c60c35177922d10ccc7ed4b90d261c3

# Install package and test extras in editable mode inside conda environment
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate metagpt && pip install -e .[test]"

# Add conda environment activation to root user's .bashrc for convenience
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate metagpt" >> /root/.bashrc
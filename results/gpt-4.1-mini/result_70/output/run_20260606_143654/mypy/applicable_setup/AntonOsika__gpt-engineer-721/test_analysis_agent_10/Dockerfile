FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and tools
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    python3-distutils \
    python3-setuptools \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda (single RUN to reduce layers and complexity)
RUN wget "https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-2-Linux-x86_64.sh" -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/miniconda3 && \
    rm miniconda.sh && \
    /opt/miniconda3/bin/conda init bash && \
    /opt/miniconda3/bin/conda config --append channels conda-forge && \
    /opt/miniconda3/bin/conda create -y -n testbed python=3.10 && \
    echo "source /opt/miniconda3/etc/profile.d/conda.sh" >> /root/.bashrc && \
    echo "conda activate testbed" >> /root/.bashrc

ENV PATH=/opt/miniconda3/bin:$PATH

# Upgrade pip and install pytest within the testbed env using a small script to avoid complex RUN commands with conda activate
RUN bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed && pip install --upgrade pip pytest==7.3.1"

# Set working directory
WORKDIR /testbed/

# Clone repo, checkout commit, and install in editable mode within conda env
RUN bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed && \
    git clone https://github.com/AntonOsika/gpt-engineer /testbed && \
    cd /testbed && \
    git reset --hard 7dac88a3f8e8c0610e9e3189c867b19d055dab2d && \
    pip install -e ."

# Enable conda activation for interactive shells
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc
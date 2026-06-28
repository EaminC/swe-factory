FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies including git, build tools, and wget
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    wget \
    curl \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda for Python environment management
RUN wget 'https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-2-Linux-x86_64.sh' -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

RUN conda init --all \
    && conda config --append channels conda-forge

# Create conda environment with Python 3.10 (minimum required version)
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -n testbed python=3.10 -y && \
    conda activate testbed"

# Set working directory
WORKDIR /testbed/

# Clone repository, checkout specific commit, and install dependencies
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard c29bdded396eff9a47aa36643ce1169b2ebf5318 && \
    git remote remove origin && \
    pip install setuptools==78.1.1 wheel==0.45.1 && \
    pip install -e .[dev]"

# Configure bash to automatically activate conda environment
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc
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
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda with Python 3.10
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py310_23.11.0-2-Linux-x86_64.sh -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda
RUN conda init bash \
    && conda config --append channels conda-forge

# Create testbed environment with Python 3.10
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -n testbed python=3.10 -y"

# Set working directory
WORKDIR /testbed/

# Clone repository, checkout specific commit, and install in development mode with dev dependencies
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    cd /testbed && \
    git reset --hard b35c1652c7b46a0af2785f988925d9910e3b7b70 && \
    git remote remove origin && \
    pip install --upgrade pip && \
    pip install -e \".[dev]\""

# Set default shell to bash and ensure conda environment is activated
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc
ENV SHELL=/bin/bash
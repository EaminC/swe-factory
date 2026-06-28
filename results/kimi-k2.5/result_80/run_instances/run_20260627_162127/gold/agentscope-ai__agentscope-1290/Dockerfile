# Base image specification with bash shell support
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation including build tools, git, and audio libraries for sounddevice
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    libffi-dev \
    libtiff-dev \
    portaudio19-dev \
    python3-dev \
    jq \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda with Python 3.10 support
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py310_23.11.0-2-Linux-x86_64.sh -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda and create testbed environment with Python 3.10
RUN conda init bash \
    && conda config --append channels conda-forge \
    && conda create -n testbed python=3.10 -y

# Set working directory
WORKDIR /testbed/

# Clone repository, checkout specific commit, and install in development mode with dev dependencies
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    cd /testbed && \
    git reset --hard 28cfb99a21902d330dab6cb3762a739198cf972f && \
    git remote remove origin && \
    pip install -e '.[dev]'"

# Configure bash environment to automatically activate conda environment
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> ~/.bashrc

# Set default shell to bash
SHELL ["/bin/bash", "-c"]
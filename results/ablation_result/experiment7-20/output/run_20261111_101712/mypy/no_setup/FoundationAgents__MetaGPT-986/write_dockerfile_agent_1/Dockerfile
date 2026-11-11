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
    ca-certificates \
    libffi-dev \
    libssl-dev \
    software-properties-common \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda (lightweight Conda installer)
RUN wget 'https://repo.anaconda.com/miniconda/Miniconda3-py39_23.3.1-0-Linux-x86_64.sh' -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/conda \
    && rm miniconda.sh

ENV PATH=/opt/conda/bin:$PATH

# Initialize conda for bash shell
RUN conda init bash && \
    /bin/bash -c "source /opt/conda/etc/profile.d/conda.sh"

# Create and activate conda environment named 'testbed' with Python 3.9
RUN /bin/bash -c "source /opt/conda/etc/profile.d/conda.sh && \
    conda create -y -n testbed python=3.9 && \
    conda clean -afy"

# Set working directory
WORKDIR /testbed/

# Clone the target repository and checkout specified commit
ARG REPO=https://github.com/FoundationAgents/MetaGPT.git
ARG COMMIT_SHA=bbb9645f7c60c35177922d10ccc7ed4b90d261c3

RUN git clone $REPO /testbed && \
    cd /testbed && \
    git reset --hard $COMMIT_SHA && \
    # Remove any remote origin to avoid accidental pushes
    git remote remove origin

# Install dependencies and project in editable mode inside conda environment
RUN /bin/bash -c "source /opt/conda/etc/profile.d/conda.sh && \
    conda activate testbed && \
    # Upgrade pip first
    pip install --upgrade pip && \
    # Install core and test dependencies via provided scripts and setup.py extras_require  
    # The repo uses tests/scripts/run_install_deps.sh to install dependencies
    bash tests/scripts/run_install_deps.sh && \
    # Install the project in editable mode to enable development mode usage
    pip install -e ."

# Configure bash environment for conda activate by default
RUN echo "source /opt/conda/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc
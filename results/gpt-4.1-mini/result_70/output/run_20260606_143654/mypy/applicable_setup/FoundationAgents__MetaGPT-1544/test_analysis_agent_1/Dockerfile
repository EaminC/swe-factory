# Use Ubuntu 22.04 as base image for stability and bash availability
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Set bash as default shell
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, curl, wget, build essentials, python3.9 and tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    locales \
    tzdata \
    libffi-dev \
    libssl-dev \
    python3.9 \
    python3.9-venv \
    python3.9-distutils \
    python3-pip \
    python3.9-dev \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.9
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1

# Upgrade pip and install setuptools and wheel
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install Miniconda to manage python environment with exact Python version 3.9
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_23.7.2-0-Linux-x86_64.sh -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda and create environment named 'testbed' with python 3.9
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -n testbed python=3.9 -y && \
    conda clean -afy"

# Clone the repo, checkout specific commit, install dependencies, and setup environment
RUN /bin/bash -c " \
    source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/FoundationAgents/MetaGPT /testbed && \
    cd /testbed && \
    git reset --hard 8b209d4e17ad7dfc1ad7a80505eac42f71228734 && \
    pip install -e .[test] && \
    npm install -g @mermaid-js/mermaid-cli && \
    playwright install --with-deps \
"

# Set working directory as /testbed
WORKDIR /testbed/

# Add environment activation to bashrc for convenience
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc

# Set environment variable recommended by testing info to disallow OpenAI calls by default
ENV ALLOW_OPENAI_API_CALL=0
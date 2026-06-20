# Base image with Python 3.10 (minimum required version)
FROM --platform=linux/x86_64 ubuntu:22.04

# Environment configuration
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PATH=/opt/miniconda3/bin:$PATH

# System dependencies
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    curl \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget 'https://repo.anaconda.com/miniconda/Miniconda3-py310_23.11.0-2-Linux-x86_64.sh' -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

# Configure conda
RUN conda init --all \
    && conda config --append channels conda-forge

# Create and activate testbed environment with Python 3.10
RUN conda create -n testbed python=3.10 -y \
    && echo "conda activate testbed" >> /root/.bashrc

# Set working directory
WORKDIR /testbed

# Clone the repository
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed

# Checkout specific commit
RUN git reset --hard 28cfb99a21902d330dab6cb3762a739198cf972f

# Install project dependencies in development mode
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh \
    && conda activate testbed \
    && pip install setuptools==78.1.1 wheel==0.45.1 \
    && pip install -e .[dev] \
    && pip install coverage pytest"

# Set environment variables (optional, for API keys if needed during tests)
ENV DASHSCOPE_API_KEY=""
ENV GAODE_API_KEY=""

# Final configuration
RUN chmod -R 777 /testbed
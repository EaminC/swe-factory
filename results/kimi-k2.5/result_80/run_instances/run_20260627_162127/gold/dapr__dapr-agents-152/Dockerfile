FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies and essential tools
RUN apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    libffi-dev \
    curl \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda for Python environment management
RUN wget 'https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-2-Linux-x86_64.sh' -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda for bash
RUN conda init bash

# Create conda environment with Python 3.10 and upgrade build tools
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -n testbed python=3.10 -y && \
    conda activate testbed && \
    pip install --upgrade pip setuptools>=61.0 wheel setuptools_scm"

# Set working directory
WORKDIR /testbed/

# Clone repository, checkout specific commit, and install in development mode with test dependencies
# Also upgrade protobuf to fix version incompatibility with durabletask package
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/dapr/dapr-agents /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard caaad181ce706c4e7a5b55a225ca06154965ec70 && \
    git remote remove origin && \
    pip install -e '.[test]' && \
    pip install 'protobuf>=6.31.1'"

# Set environment variables required for tests
ENV DAPR_LLM_COMPONENT_DEFAULT=openai
ENV OPENAI_API_KEY=test-api-key

# Configure shell environment to ensure conda activation on login
SHELL ["/bin/bash", "-c"]
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc
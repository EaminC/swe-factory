# Base image with bash, python3.9+, git and essential build tools
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and tools including python3.10, pip, git, build essentials
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3-pip \
    python3.10-distutils \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Use python3.10 as python by default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# Upgrade pip
RUN python -m pip install --upgrade pip

# Set WORKDIR
WORKDIR /testbed/

# Clone the repository and checkout the specific commit sha ARG
ARG COMMIT_SHA=e616e52f444d01dbb249ea3d2e205cbd1c8fb848

RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    cd /testbed && \
    git reset --hard ${COMMIT_SHA} && \
    git remote remove origin

# Create and activate virtual environment and install dependencies including editable install with optional [distribute]
RUN python -m venv /testbed/testbed_venv

ENV PATH="/testbed/testbed_venv/bin:$PATH"

# Upgrade pip inside venv
RUN pip install --upgrade pip

# Install all pinned core dependencies with fixed versions plus unpinned dependencies with minimum versions, pytest, pre-commit, dev extras
# Install editable with [distribute] extra
RUN pip install loguru==0.6.0 Flask==3.0.0 Flask-Cors==4.0.0 Flask-SocketIO==5.3.6 grpcio==1.60.0 grpcio-tools==1.60.0 protobuf==4.25.0 gradio==4.44.1 modelscope_studio==0.0.5 llama-index==0.10.30 babel==2.15.0 \
    openai>=1.3.0 dashscope>=1.19.0 networkx black pydantic tiktoken requests pytest pytest-cov pre-commit sphinx transformers google-generativeai

# Install the repository itself in editable mode with distribute extras
RUN pip install -e .[distribute]

# Expose environment variables for runtime (can be overridden at container run)
ENV OPENAI_API_KEY=""
ENV OPENAI_ORGANIZATION=""

# Add bashrc entry for virtualenv activation
RUN echo "source /testbed/testbed_venv/bin/activate" >> /root/.bashrc

# Set working directory to /testbed
WORKDIR /testbed/
# Use Ubuntu 22.04 as base image with bash support
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies including python3-tk for tkinter module
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    ca-certificates \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-tk \
    build-essential \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set locale to avoid potential locale-related errors
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Use python3.10 explicitly by linking python and pip
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Upgrade pip and install setuptools wheel for install robustness
RUN python3 -m pip install --upgrade pip setuptools wheel

# Set working directory
WORKDIR /testbed/

# Clone the repo and checkout the specified commit
ARG COMMIT_SHA=2058edb3cfb8764cf642d73035af4bb6c783b7e5
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed/ \
    && cd /testbed/ \
    && git reset --hard ${COMMIT_SHA} 

# Create and activate Python virtual environment,
# install dependencies excluding those provided by the repo itself.
# Pin langchain to version 0.0.247 known to include MODEL_COST_PER_1K_TOKENS
RUN python -m venv /testbed/venv && \
    source /testbed/venv/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install \
        click>=8.0.0 \
        openai==0.27.8 \
        pytest==7.3.1 \
        pytest-cov \
        termcolor==2.3.0 \
        rudder-sdk-python==2.0.2 \
        dataclasses-json==0.5.7 \
        tiktoken>=0.0.4 \
        tabulate==0.9.0 \
        python-dotenv>=0.21.0 \
        "langchain==0.0.247" && \
    pip install -e .

# Ensure environment activation on interactive shell login
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc

# Export environment variable placeholder note (OPENAI_API_KEY must be set externally at runtime)
ENV OPENAI_API_KEY=""

# Optional: Export SHELL environment variable
RUN echo "export SHELL=/bin/bash" >> /root/.bashrc
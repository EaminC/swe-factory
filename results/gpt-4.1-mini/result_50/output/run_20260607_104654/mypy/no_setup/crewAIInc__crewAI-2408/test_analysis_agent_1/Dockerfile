FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies
RUN apt update && apt install -y \
    git \
    wget \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    curl \
    rustc \
    cargo \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set locale for proper Unicode support
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Upgrade pip to latest version for Python 3.11
RUN python3.11 -m pip install --upgrade pip

# Create workdir
WORKDIR /testbed/

# Clone the repo, checkout specific commit, create virtualenv and install dependencies
RUN git clone https://github.com/crewAIInc/crewAI /testbed/ && \
    git reset --hard 4f6054d439c602f93283eda351fe6b67133b9a84 && \
    python3.11 -m venv testbed_venv && \
    source testbed_venv/bin/activate && \
    # Upgrade pip inside venv
    pip install --upgrade pip && \
    # Install prebuilt wheel for tiktoken to avoid building from source
    pip install tiktoken --prefer-binary && \
    # Install core package in editable mode
    pip install -e . && \
    # Install optional extras tools and embeddings as recommended
    pip install 'crewai[tools]' 'crewai[embeddings]' && \
    # Install test and dev dependencies including pytest and pytest-asyncio
    pip install pytest pytest-asyncio pytest-subprocess pytest-recording ruff mypy pre-commit mkdocs

# Set environment variables for virtualenv usage in bash sessions
RUN echo "source /testbed/testbed_venv/bin/activate" >> /root/.bashrc

ENV PATH="/testbed/testbed_venv/bin:$PATH"

WORKDIR /testbed/
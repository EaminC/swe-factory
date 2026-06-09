# Use Ubuntu 22.04 as base image with bash shell support
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies including locales and tzdata
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    wget \
    locales \
    tzdata \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Configure locale properly to avoid python issues
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Poetry 1.8.2 as per CI environment using official installer
RUN curl -sSL https://install.python-poetry.org | python3.10 - --version 1.8.2
ENV PATH="/root/.local/bin:$PATH"

# Install Node.js 20.x to ensure compatibility with npm version
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    # Do NOT upgrade npm globally to prevent version conflict issues
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /testbed/

# Clone repository and checkout specific commit, then install dependencies in development mode
RUN git clone https://github.com/langflow-ai/langflow.git /testbed && \
    git reset --hard 667713f6c04fbc208fb7eefba70f101562070c9e && \
    git remote remove origin && \
    \
    python3.10 -m venv /opt/testbed-venv && \
    source /opt/testbed-venv/bin/activate && \
    pip install --upgrade pip && \
    pip install poetry==1.8.2 && \
    poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi && \
    pip install -e . && \
    \
    cd src/frontend && \
    npm install && \
    cd /testbed

# Use bash as default shell
ENV SHELL=/bin/bash

# Add python virtual environment to PATH
ENV PATH="/opt/testbed-venv/bin:$PATH"

# Activate python virtual environment automatically in interactive shells
RUN echo "source /opt/testbed-venv/bin/activate" >> /root/.bashrc
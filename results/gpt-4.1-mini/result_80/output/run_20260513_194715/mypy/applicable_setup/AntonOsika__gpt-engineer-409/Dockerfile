# Use Ubuntu 22.04 as base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies and tools
RUN apt-get update && apt-get install -y \
    git \
    python3.10 \
    python3.10-venv \
    python3-pip \
    python3.10-distutils \
    curl \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Upgrade pip globally
RUN python3 -m pip install --upgrade pip

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
ARG COMMIT_SHA=0596b07a39c2c99c46509c17660f5c8aef4b2114
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed/ && \
    git reset --hard $COMMIT_SHA

# Create and activate virtual environment, install project in development mode with dependencies
RUN python3 -m venv venv
ENV VIRTUAL_ENV=/testbed/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Upgrade pip and install project's dependencies and dev dependencies
RUN pip install --upgrade pip setuptools wheel
RUN pip install -e . "pytest>=7.3.1" "pytest-cov" "black==23.3.0" "click>=8.0.0" "mypy==1.3.0" "openai==0.27.8" "pre-commit==3.3.3" "ruff==0.0.272" "termcolor==2.3.0" "typer>=0.3.2" "rudder-sdk-python==2.0.2" "dataclasses-json==0.5.7"

# Install pre-commit hooks (optional, as in makefile)
RUN pre-commit install || true

# Set default shell to bash
ENV SHELL=/bin/bash

# Environment variable placeholder for user to provide OpenAI API Key at runtime
ENV OPENAI_API_KEY=""

# Working directory stays /testbed/
WORKDIR /testbed/
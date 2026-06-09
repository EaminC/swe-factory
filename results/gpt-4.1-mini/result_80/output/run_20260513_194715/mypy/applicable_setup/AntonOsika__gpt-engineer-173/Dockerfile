# Base image specification. Uses Ubuntu 22.04 with bash shell as default (Required)
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# System dependencies installation: essential tools and python3.10 (Required)
RUN apt update && apt install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Use python3.10 explicitly by linking python and pip
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Set up working directory
WORKDIR /testbed/

# Clone the target repository and checkout the specified commit (commit passed as build arg)
ARG REPO=https://github.com/AntonOsika/gpt-engineer.git
ARG COMMIT=35c35b3ffab89cfa0eb714f5d5c28c6eb2aa7faa

RUN git clone "${REPO}" /testbed && \
    cd /testbed && \
    git checkout ${COMMIT} && \
    chmod -R 777 /testbed

# Create and activate Python virtual environment, install dependencies via pip in editable mode,
# including packages specified by the repository (via pip install -e .) and test dependencies.
RUN python -m venv /testbed/venv && \
    source /testbed/venv/bin/activate && \
    # Upgrade pip and setuptools in venv
    pip install --upgrade pip setuptools && \
    # Install dependencies needed based on context retrieval info
    pip install black==23.3.0 \
                openai==0.27.8 \
                pre-commit==3.3.3 \
                ruff==0.0.272 \
                typer==0.9.0 \
                pytest \
                pytest-cov && \
    # Install the repository itself in editable mode
    pip install -e . 

# Ensure environment activation on interactive shell login
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc

# Export environment variable placeholder note (OPENAI_API_KEY must be set externally at runtime)
ENV OPENAI_API_KEY=""

# The container by default does nothing; tests will be run later outside this Dockerfile.
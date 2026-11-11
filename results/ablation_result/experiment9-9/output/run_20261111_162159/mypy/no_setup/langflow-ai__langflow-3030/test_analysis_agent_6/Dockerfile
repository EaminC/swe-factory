# Use ubuntu 22.04 as base image because it supports python3.10 and related packages natively
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies including git, curl, python3.10, venv, distutils, pip, and libc6 libraries
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    ca-certificates \
    locales \
    locales-all \
    zip \
    unzip \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Set python3 and pip3 alternatives to python3.10 and pip3 for consistency
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
 && python3 -m pip install --upgrade pip setuptools wheel

# Clone the repository into /testbed
WORKDIR /testbed
RUN git clone https://github.com/langflow-ai/langflow.git /testbed

# Install dependencies via pip, since pyproject.toml may not contain [tool.poetry] section.
# Use pip to upgrade setuptools and wheel before installing local package in editable mode.
RUN python3 -m pip install --upgrade setuptools wheel \
 && python3 -m pip install -e .

# Expose environment variable placeholder for OPENAI_API_KEY and others as documented
ENV OPENAI_API_KEY=""

# Default shell is bash
CMD ["/bin/bash"]
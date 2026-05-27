# Base image specification - using Ubuntu with bash support
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation - essential tools and libraries for development and runtime
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    libtiff-dev \
    python3 \
    python3-pip \
    python3-venv \
    python-is-python3 \
    curl \
    locales \
    locales-all \
    tzdata \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Set default workdir to testbed (Required)
WORKDIR /testbed/

# Clone the repository and checkout to the target commit
RUN git clone https://github.com/agentscope-ai/agentscope /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard c29bdded396eff9a47aa36643ce1169b2ebf5318 && \
    git remote remove origin

# Create and activate a Python 3.9+ virtual environment using venv
RUN python3 -m venv /testbed/venv

# Set environment variables for the virtual environment
ENV PATH="/testbed/venv/bin:$PATH"
ENV VIRTUAL_ENV="/testbed/venv"

# Upgrade pip, setuptools, and wheel in the virtual environment
RUN /testbed/venv/bin/pip install --upgrade pip setuptools wheel

# Install core dependencies and test dependencies
RUN /testbed/venv/bin/pip install \
    openai \
    flask \
    gunicorn \
    requests \
    pydantic \
    pyyaml \
    pytest \
    pytest-asyncio

# Install the dashscope optional dependency group (required for formatter_dashscope_test.py)
RUN /testbed/venv/bin/pip install -e ".[dashscope]"

# Activate virtual environment in bashrc for interactive shells
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc

# Configure shell to use bash
SHELL ["/bin/bash", "-c"]

# Verify installation
RUN /testbed/venv/bin/python -c "import agentscope; print('agentscope installed successfully')" && \
    /testbed/venv/bin/python -c "import dashscope; print('dashscope installed successfully')" && \
    /testbed/venv/bin/python -c "import pytest; print('pytest installed successfully')"
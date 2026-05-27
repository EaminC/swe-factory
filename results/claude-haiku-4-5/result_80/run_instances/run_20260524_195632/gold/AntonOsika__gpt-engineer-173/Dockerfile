# Base image with Python 3.11 and essential build tools
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies and essential tools
RUN apt update && apt install -y \
    wget \
    git \
    curl \
    build-essential \
    libffi-dev \
    libtiff-dev \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    python-is-python3 \
    jq \
    locales \
    locales-all \
    tzdata \
    make \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Upgrade pip
RUN python3.11 -m pip install --upgrade pip setuptools wheel

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/AntonOsika/gpt-engineer /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard 35c35b3ffab89cfa0eb714f5d5c28c6eb2aa7faa && \
    git remote remove origin

# Create Python virtual environment
RUN python3.11 -m venv /testbed/venv

# Activate virtual environment and install test dependencies
RUN /bin/bash -c "source /testbed/venv/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install pytest && \
    pip install pytest-cov"

# Install the repository in development mode (includes core dependencies)
RUN /bin/bash -c "source /testbed/venv/bin/activate && \
    pip install -e /testbed"

# Configure bash to activate virtual environment by default
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc

# Set the shell to bash
SHELL ["/bin/bash", "-c"]

# Verify installations
RUN /bin/bash -c "source /testbed/venv/bin/activate && \
    python --version && \
    pip list | grep -E 'pytest|openai|typer|black|ruff'"
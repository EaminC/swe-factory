# Use Ubuntu 22.04 LTS as base for stable repositories (Python 3.12 not in default repos, so install manually)
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    wget \
    locales \
    locales-all \
    tzdata \
    ca-certificates \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add Deadsnakes PPA for Python 3.12 packages
RUN add-apt-repository ppa:deadsnakes/ppa -y && apt-get update && apt-get install -y \
    python3.12 \
    python3.12-venv \
    python3.12-distutils \
    && rm -rf /var/lib/apt/lists/*

# Install pip for python3.12
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

# Upgrade pip, setuptools, wheel
RUN python3.12 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Install uv tool (dependency manager) needed by repo
RUN python3.12 -m pip install --no-cache-dir uv

# Set working directory
WORKDIR /testbed/

# Clone repository and checkout specific commit
RUN git clone https://github.com/ValueCell-ai/valuecell.git /testbed && \
    git reset --hard 67d56f93a45e712e924f5334119779c93830e208

# Use uv to install dependencies according to repo lock and extras info
RUN uv sync --locked --all-extras --dev

# Install repo in editable mode to ensure local source code is used
RUN python3.12 -m pip install --no-cache-dir -e .

# Set UTF-8 encoding for python output
RUN echo "export PYTHONIOENCODING=utf-8" >> ~/.bashrc

# Set default shell
ENV SHELL=/bin/bash
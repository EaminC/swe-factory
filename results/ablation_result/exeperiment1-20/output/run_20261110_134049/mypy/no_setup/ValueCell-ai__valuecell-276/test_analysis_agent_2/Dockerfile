# Use Ubuntu 23.04 as base to get python3.12 from default repos
FROM --platform=linux/x86_64 ubuntu:23.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and tools: git, curl, build essentials, python3.12 and modules, locales, tzdata, etc.
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3.12 \
    python3.12-venv \
    python3.12-distutils \
    wget \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install pip for python3.12
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

# Upgrade pip, setuptools, wheel
RUN python3.12 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Install uv tool (dependency manager) per repo requirement
RUN python3.12 -m pip install --no-cache-dir uv

# Set working directory
WORKDIR /testbed/

# Clone repository and checkout specific commit
RUN git clone https://github.com/ValueCell-ai/valuecell.git /testbed && \
    git reset --hard 67d56f93a45e712e924f5334119779c93830e208

# Install dependencies using uv as per context info (all extras + dev + locked)
RUN uv sync --locked --all-extras --dev

# Install repository in editable mode to ensure local code usage
RUN python3.12 -m pip install --no-cache-dir -e .

# Ensure UTF-8 output encoding by default when running bash
RUN echo "export PYTHONIOENCODING=utf-8" >> ~/.bashrc

# Set default shell
ENV SHELL=/bin/bash
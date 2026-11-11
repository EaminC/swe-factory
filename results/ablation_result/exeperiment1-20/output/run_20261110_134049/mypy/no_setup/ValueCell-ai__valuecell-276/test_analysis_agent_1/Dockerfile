# Base image with Bash and Python 3.12+
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and tools: git, curl, build essentials, python3.12 and pip, locales, tzdata, etc.
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

# Upgrade pip
RUN python3.12 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Install uv tool (dependency manager) as per repo requirement
RUN python3.12 -m pip install --no-cache-dir uv

# Set work directory
WORKDIR /testbed/

# Clone repository and checkout specific commit
RUN git clone https://github.com/ValueCell-ai/valuecell.git /testbed && \
    git reset --hard 67d56f93a45e712e924f5334119779c93830e208

# Install dependencies using uv according to context info (all extras + dev + locked)
RUN uv sync --locked --all-extras --dev

# Install current repo in editable mode to use local source code correctly
RUN python3.12 -m pip install --no-cache-dir -e .

# Make sure shell startup activates any environment if needed (uv uses no explicit venv but env variables)
RUN echo "export PYTHONIOENCODING=utf-8" >> ~/.bashrc

# Set default shell
ENV SHELL=/bin/bash
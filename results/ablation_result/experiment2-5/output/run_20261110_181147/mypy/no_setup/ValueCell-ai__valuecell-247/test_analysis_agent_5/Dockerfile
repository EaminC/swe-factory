# Use official Python 3.12 image with full stdlib and distutils support (based on Debian bookworm slim)
FROM --platform=linux/x86_64 python:3.12-slim-bookworm

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies required for building and runtime
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set bash as default shell
SHELL ["/bin/bash", "-c"]

# Upgrade pip, setuptools, and wheel to latest versions
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install bun (JS/TS toolkit) system-wide
RUN curl -fsSL https://bun.sh/install | bash

ENV PATH="/root/.bun/bin:${PATH}"

# Install uv tool globally from its install script
RUN curl -fsSL https://raw.githubusercontent.com/astral-sh/uv/main/scripts/install.sh | bash

# Set working directory
WORKDIR /testbed/

# Clone the repo and checkout the specific commit SHA
RUN git clone https://github.com/ValueCell-ai/valuecell.git /testbed && \
    cd /testbed && \
    git reset --hard 146faeb125cb123d94ee9393db4513d2e5d113aa

# Set up Python virtual environment named testbed at /testbed/venv
RUN python3 -m venv /testbed/venv

# Upgrade pip etc inside the venv
RUN /testbed/venv/bin/pip install --upgrade pip setuptools wheel

# Install Python backend dependencies inside the venv per project instructions:
# Use uv pip install --editable ".[dev]" inside python/ directory
RUN /bin/bash -c "\
    source /testbed/venv/bin/activate && \
    cd /testbed/python && \
    uv pip install --editable '.[dev]' \
"

# Install frontend dependencies using bun in /testbed/frontend
RUN cd /testbed/frontend && bun install

# Add virtual environment activation to root's bashrc for convenience
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc
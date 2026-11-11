# Base image: Ubuntu 22.04 with bash shell by default
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Add deadsnakes PPA to get Python 3.12 packages (excluding python3.12-distutils which is unavailable)
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    locales-all \
    tzdata \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip \
    python3-distutils \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.12 and upgrade pip/setuptools/wheel
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Manually link distutils to the Python3.12 stdlib location if needed
RUN python3 -c "import sys; print(sys.version)" && \
    python3 -m pip install --upgrade pip setuptools wheel

# Install bun (JS/TS toolkit) - system-wide (latest stable) per https://bun.sh
RUN curl -fsSL https://bun.sh/install | bash

ENV PATH="/root/.bun/bin:${PATH}"

# Install uv tool globally from its install script
RUN curl -fsSL https://raw.githubusercontent.com/astral-sh/uv/main/scripts/install.sh | bash

# Setup working directory
WORKDIR /testbed/

# Clone the repo and checkout the specific commit SHA
RUN git clone https://github.com/ValueCell-ai/valuecell.git /testbed && \
    cd /testbed && \
    git reset --hard 146faeb125cb123d94ee9393db4513d2e5d113aa

# Set up Python virtual environment (named testbed) at /testbed/venv and activate it
RUN python3 -m venv /testbed/venv

# Upgrade pip inside the venv
RUN /testbed/venv/bin/pip install --upgrade pip setuptools wheel

# Install Python backend dependencies inside the venv per instructions:
# - cd python
# - use uv sync --extra dev OR uv pip install --editable ".[dev]"
# We'll use uv pip install --editable ".[dev]"
RUN /bin/bash -c "\
    source /testbed/venv/bin/activate && \
    cd /testbed/python && \
    uv pip install --editable '.[dev]' \
"

# Install frontend dependencies using bun (in /testbed/frontend)
RUN cd /testbed/frontend && bun install

# Make sure bash is the default shell and add environment activation in .bashrc for convenience
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc
SHELL ["/bin/bash", "-c"]
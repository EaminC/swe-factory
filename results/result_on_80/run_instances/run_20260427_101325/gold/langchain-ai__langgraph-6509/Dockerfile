# Use Ubuntu 22.04 LTS base image with bash available
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    curl \
    build-essential \
    wget \
    locales \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Setup python3.10 as python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# Install pip for python3.10
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python

# Create working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit SHA
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed \
    && git reset --hard 5212369bd0791806083f183cb19ccce024db8790

# Create Python virtual environment named 'testbed' and install dependencies
RUN python -m venv /testbed/venv

# Upgrade pip in the venv and install test dependencies & the repo in editable mode
RUN /testbed/venv/bin/pip install --upgrade pip setuptools wheel

# Install test dependencies first
RUN /testbed/venv/bin/pip install \
    pytest \
    pytest-asyncio \
    pytest-mock \
    pytest-watcher \
    syrupy \
    psycopg-binary

# Install langchain-core only from PyPI (since it's external and not in the repo)
RUN /testbed/venv/bin/pip install langchain-core

# Install langgraph and checkpoint related packages in editable mode from cloned repo
RUN /testbed/venv/bin/pip install -e ./libs/langgraph
RUN /testbed/venv/bin/pip install -e ./libs/checkpoint
RUN /testbed/venv/bin/pip install -e ./libs/checkpoint-sqlite
RUN /testbed/venv/bin/pip install -e ./libs/checkpoint-postgres

# Export bashrc to load venv by default on interactive shell
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc

# Set WORKDIR explicitly again for clarity
WORKDIR /testbed
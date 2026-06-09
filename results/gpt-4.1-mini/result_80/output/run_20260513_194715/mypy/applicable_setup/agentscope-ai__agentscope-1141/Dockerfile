FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.10 and pip is installed correctly
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
    && python3 -m pip install --upgrade pip setuptools wheel

# Create a virtual environment named testbed
RUN python3 -m venv /opt/testbed

# Activate the virtual environment and install dependencies
# Use pip to install build dependencies including the repo itself in editable mode

ENV VIRTUAL_ENV=/opt/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Clone repo, checkout specific commit SHA, install in editable mode including dev dependencies
RUN git clone -b main https://github.com/agentscope-ai/agentscope.git /testbed && \
    cd /testbed && \
    git reset --hard c29bdded396eff9a47aa36643ce1169b2ebf5318 && \
    pip install --upgrade pip setuptools wheel && \
    pip install -e . && \
    # Install dev dependencies from pyproject.toml via pip in one command
    pip install pre-commit pytest pytest-forked sphinx-gallery matplotlib fakeredis aiosqlite greenlet

WORKDIR /testbed

# Ensure bash is used by default for all RUN commands
SHELL ["/bin/bash", "-c"]
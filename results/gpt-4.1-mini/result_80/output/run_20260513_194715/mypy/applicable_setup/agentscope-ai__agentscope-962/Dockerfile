# Use Ubuntu 22.04 as base image and x86_64 arch with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and Python 3.10 with development tools
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

# Set python3 alternative to python3.10 and upgrade pip/setuptools/wheel
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
    && python3 -m pip install --upgrade pip setuptools wheel

# Create virtual environment at /opt/testbed and activate it
RUN python3 -m venv /opt/testbed

ENV VIRTUAL_ENV=/opt/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Clone repository, checkout specific commit SHA, and install the package in editable mode with dev extras
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed \
    && cd /testbed \
    && git reset --hard a2bf80ec96e29cb760ac6d4018680d6af68c9416 \
    && pip install --upgrade pip setuptools wheel \
    && pip install -e ".[dev]" \
    && pip install pre-commit pytest pytest-forked fakeredis aiosqlite greenlet py-openjudge

# Set working directory
WORKDIR /testbed

# Keep bash as default shell
SHELL ["/bin/bash", "-c"]
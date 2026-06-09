# Use Ubuntu 22.04 with bash shell and x86_64 architecture
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies for Python 3.10, git, build tools, locales, and other essentials
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

# Ensure python3 points to python3.10 and upgrade pip, setuptools, wheel
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
    && python3 -m pip install --upgrade pip setuptools wheel

# Create and activate a virtual environment in /opt/testbed
RUN python3 -m venv /opt/testbed

ENV VIRTUAL_ENV=/opt/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Clone the repository and checkout specified commit SHA
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed \
    && cd /testbed \
    && git reset --hard 28cfb99a21902d330dab6cb3762a739198cf972f

WORKDIR /testbed

# Upgrade pip etc. inside the virtual environment and install the repository in editable mode with dev extras
RUN pip install --upgrade pip setuptools wheel && pip install ".[dev]" 

# Install additional testing and development dependencies specified
RUN pip install pre-commit pytest pytest-forked fakeredis aiosqlite greenlet py-openjudge

# Set default shell to bash
SHELL ["/bin/bash", "-c"]
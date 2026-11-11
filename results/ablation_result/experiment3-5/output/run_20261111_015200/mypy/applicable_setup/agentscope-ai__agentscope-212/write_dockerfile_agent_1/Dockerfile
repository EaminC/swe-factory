# Base image specification: Ubuntu 22.04 with bash shell for compatibility
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    ca-certificates \
    locales \
    locales-all \
    tzdata \
    python3.9 \
    python3.9-venv \
    python3.9-distutils \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set python3 to point to python3.9
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1

# Upgrade pip to latest version
RUN python3 -m pip install --upgrade pip setuptools wheel

# Create a python virtual environment named testbed
RUN python3 -m venv /opt/testbed

# Activate the virtual environment and import bashrc changes for conda-like activation convenience
# Install development/test dependencies inside the venv
RUN /bin/bash -c "source /opt/testbed/bin/activate && \
    pip install -U pip setuptools wheel && \
    pip install pytest pytest-cov pre-commit"

WORKDIR /testbed/

# Clone the repository and checkout specified commit
ARG REPO=https://github.com/agentscope-ai/agentscope.git
ARG COMMIT_SHA=8b817541dac5128db2e47e55c920a289d02037a0

RUN git clone $REPO /testbed && \
    cd /testbed && \
    git reset --hard $COMMIT_SHA && \
    git remote remove origin

# Install the repository in development mode with all dependencies (full extras) inside the virtual environment
RUN /bin/bash -c "source /opt/testbed/bin/activate && \
    pip install -e .[full]"

# Add script to activate testbed virtual environment easily for runtime
RUN echo 'source /opt/testbed/bin/activate' >> /root/.bashrc

ENV VIRTUAL_ENV=/opt/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Default workdir already set to /testbed
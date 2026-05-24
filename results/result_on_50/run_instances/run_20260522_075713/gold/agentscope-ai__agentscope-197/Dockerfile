FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system packages, Python 3 (default 3.10), git, curl, and necessary tools
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3 \
    python3-venv \
    python3-distutils \
    python3-pip \
    python3-setuptools \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Configure python command to point to system python3
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# Upgrade pip using python3 executable (without ensurepip)
RUN python3 -m pip install --upgrade pip

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specified commit
RUN git clone https://github.com/agentscope-ai/agentscope /testbed/ \
    && git reset --hard be8db4cc484b77d0d3bc60a012e9035c4395bee3

# Install project in development mode with full and dev dependencies quietly
RUN pip install -e .[full,dev] -q

# Install coverage tool quietly for test coverage reporting
RUN pip install coverage -q

# Define environment variable placeholders, can be overridden at runtime
ENV OPENAI_API_KEY=""
ENV OPENAI_ORGANIZATION=""

# Explicitly set bash as default shell
SHELL ["/bin/bash", "-c"]
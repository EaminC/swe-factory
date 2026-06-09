# Use Ubuntu 22.04 as base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install software-properties-common to add PPAs
RUN apt-get update && apt-get install -y software-properties-common

# Add deadsnakes PPA to get python3.11 packages
RUN add-apt-repository ppa:deadsnakes/ppa -y

# Update apt and install required packages including python3.11 and associated tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    python3.11-dev \
    python3-setuptools \
    ca-certificates \
    wget \
    locales \
    locales-all \
    tzdata \
    rustc \
    cargo \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set python3 and python to point to python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Set locale to UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Upgrade pip and setuptools for python3.11
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install uv tool pinned to latest compatible version to reduce dependency conflicts
RUN python3 -m pip install "uv>=0.5.4,<0.6"

# Clone the crewAI repository and checkout the specific commit
WORKDIR /testbed/
RUN git clone https://github.com/crewAIInc/crewAI /testbed && \
    git reset --hard b992ee9d6b604993b3cc09ae366e314f68f78705

# Setup Python virtual environment named 'testbed' using python3.11
RUN python3 -m venv /testbed/testbed

# Activate virtual environment, install uv, sync dependencies with uv, then install the project in editable mode with [tools]
RUN /bin/bash -c "\
    source /testbed/testbed/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install 'uv>=0.5.4,<0.6' && \
    uv sync --dev --all-extras --active && \
    pip install -e .[tools] \
    "

# Add virtual environment activation to root user's bashrc for convenience
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

# Environment variables note:
# OPENAI_API_KEY and SERPER_API_KEY should be provided at container runtime for the tests.

# Set working directory to /testbed/
WORKDIR /testbed/
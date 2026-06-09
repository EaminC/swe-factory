# Use Ubuntu 22.04 as base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install base system dependencies and essential tools
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    curl \
    wget \
    ca-certificates \
    locales \
    software-properties-common \
    python3 \
    python3-venv \
    python3-distutils \
    python3-pip \
    rustc \
    cargo \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set locale to UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Upgrade pip and setuptools for default python3 version
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install UV tool (uv) version pinned to latest compatible to reduce dependency conflicts
RUN python3 -m pip install "uv>=0.5.4,<0.6"

# Clone the crewAI repository and checkout the specific commit
WORKDIR /testbed/
RUN git clone https://github.com/crewAIInc/crewAI /testbed && \
    git reset --hard b992ee9d6b604993b3cc09ae366e314f68f78705

# Setup Python virtual environment named 'testbed' using system python3
RUN python3 -m venv /testbed/testbed

# Activate virtual environment, add uv to this environment, then run uv sync only (no pip install)
# Next, separately install the local package with extras
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
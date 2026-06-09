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
    python3.12 \
    python3.12-venv \
    python3.12-distutils \
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

# Upgrade pip for python3.12
RUN python3.12 -m pip install --upgrade pip setuptools wheel

# Install UV tool (uv) via pip (system-wide)
RUN python3.12 -m pip install uv

# Clone the crewAI repository, checkout given commit, and install in dev mode
WORKDIR /testbed/
RUN git clone https://github.com/crewAIInc/crewAI /testbed && \
    git reset --hard b992ee9d6b604993b3cc09ae366e314f68f78705

# Setup Python virtual environment named 'testbed' using python3.12
RUN python3.12 -m venv /testbed/testbed

# Activate virtual environment and sync the dependencies with uv (with all extras and dev)
RUN /bin/bash -c "\
    source /testbed/testbed/bin/activate && \
    uv sync --dev --all-extras && \
    pip install -e .[tools] \
    "

# Add virtual environment activation to bashrc for interactive use
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

# Environment variables note (to be provided at runtime):
# OPENAI_API_KEY and SERPER_API_KEY should be injected by the user using --env or .env file at container runtime

# Set working directory
WORKDIR /testbed/
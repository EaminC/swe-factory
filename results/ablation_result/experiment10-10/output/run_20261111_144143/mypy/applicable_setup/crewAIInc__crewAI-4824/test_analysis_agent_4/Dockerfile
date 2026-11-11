# Use Ubuntu 22.04 LTS (jammy) for a stable base environment
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and Python 3.10 (default in Ubuntu 22.04),
# and essential build tools, rust and cargo for rust-based packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libssl-dev \
    libffi-dev \
    libsqlite3-dev \
    rustc \
    cargo \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Configure python3 and pip to point to python3.10 and upgrade pip ecosystem
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    python3 -m pip install --upgrade pip setuptools wheel

# Install uv CLI tool (CrewAI's environment manager)
RUN python3 -m pip install uv

# Set working directory to /testbed
WORKDIR /testbed/

# Clone the target repository and checkout specific commit SHA (build argument)
ARG REPO=https://github.com/crewAIInc/crewAI.git
ARG COMMIT_SHA=542afe61a8adfca1b9a0434189b9f339dfb07817
RUN git clone ${REPO} . && \
    git reset --hard ${COMMIT_SHA}

# Create UV-managed virtual environment and install the local repository in editable mode with optional 'tools'
RUN /bin/bash -c "\
    uv venv && \
    source .venv/bin/activate && \
    uv pip install --upgrade pip && \
    uv pip install 'crewai[tools]' && \
    uv pip install -e . \
    "

# Set environment variable for Python unbuffered output
ENV PYTHONUNBUFFERED=1

# Append activation of the uv virtual environment to root bashrc for convenience
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Default shell explicitly bash
SHELL ["/bin/bash", "-c"]
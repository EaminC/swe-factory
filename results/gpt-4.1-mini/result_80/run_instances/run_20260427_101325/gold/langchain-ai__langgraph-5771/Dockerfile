FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install essential system dependencies and tools, including docker CLI for test needs
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    ca-certificates \
    locales \
    tzdata \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# Point python3 to python3.11 explicitly and upgrade pip, setuptools, wheel
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install uv tool globally for virtual env and dependency management
RUN pip install uv

# Set working directory before cloning repository
WORKDIR /testbed

# Clone repository and checkout the specified commit
ARG COMMIT_SHA=18887e9f86a6d8675a2b4aed03a1c190ef6e1581
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed && \
    git reset --hard $COMMIT_SHA

# Setup Python virtual environment, sync dependencies and install the package in editable mode within libs/langgraph
RUN /bin/bash -c "\
    uv venv -p python3 && \
    source .venv/bin/activate && \
    cd libs/langgraph && \
    uv sync --frozen --group dev && \
    pip install -e . && \
    cd ../.. \
"

# Configure bash to activate virtual environment when opening shell
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

SHELL ["/bin/bash", "-c"]
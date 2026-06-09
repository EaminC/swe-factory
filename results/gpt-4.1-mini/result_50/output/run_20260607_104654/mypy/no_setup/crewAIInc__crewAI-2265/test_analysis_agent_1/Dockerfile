# Use Ubuntu 22.04 as base image for stability and bash support
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies, git, curl, wget, build tools, and Python prerequisites
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3-pip \
    python3-venv \
    python3-distutils \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install uv CLI tool to manage python version, environments, and dependencies
RUN pip3 install --no-cache-dir uv

# Clone the repository into /testbed and checkout to the specified commit
RUN git clone https://github.com/crewAIInc/crewAI /testbed
WORKDIR /testbed
RUN git reset --hard e1a73e0c44fd85b2ad34ca0a3eda57964c0dee4b

# Setup Python virtual environment via uv CLI, install all dependencies including dev and extras
RUN uv venv -v && \
    uv lock && \
    uv sync --dev --all-extras

# Install the local repository in editable/development mode to ensure local code is used
RUN /bin/bash -c "source .venv/bin/activate && pip install -e ."

# Upgrade pip and install additional tools & dependencies as specified
RUN /bin/bash -c "source .venv/bin/activate && pip install --upgrade pip && pip install tiktoken --prefer-binary"

# Setup bashrc for interactive environment with the virtual environment activated
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Set working directory and default shell
WORKDIR /testbed
ENV PATH="/testbed/.venv/bin:$PATH"
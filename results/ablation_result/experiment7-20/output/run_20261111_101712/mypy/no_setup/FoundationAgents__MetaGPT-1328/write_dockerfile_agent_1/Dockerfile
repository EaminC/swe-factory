# Base image specification with Ubuntu 22.04 and bash
FROM --platform=linux/x86_64 ubuntu:22.04

# Noninteractive frontend for apt and set timezone environment variable
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and essential tools including git, python3.9, pip, npm (for mermaid-cli), curl, locales, and build essentials
RUN apt-get update && apt-get install -y \
    git \
    python3.9 \
    python3.9-venv \
    python3-pip \
    python3-distutils \
    curl \
    locales \
    locales-all \
    tzdata \
    build-essential \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Set locale to avoid locale warnings
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Upgrade pip
RUN python3.9 -m pip install --upgrade pip

# Create and activate Python virtual environment named testbed
RUN python3.9 -m venv /testbed/testbed

# Ensure pip inside the virtual environment is upgraded and required global Node dependencies are installed
RUN /bin/bash -c "source /testbed/testbed/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    npm install -g @mermaid-js/mermaid-cli"

# Clone the repository and checkout the specified commit SHA inside /testbed
RUN git clone https://github.com/geekan/MetaGPT.git /testbed && \
    cd /testbed && \
    git checkout 5e8bd105177e08848990d32b9ea636daa639be19

# Install Python dependencies in editable mode with test extras inside the virtual environment including running playwright install with deps
RUN /bin/bash -c "source /testbed/testbed/bin/activate && \
    cd /testbed && \
    pip install -e .[test] && \
    pip install --upgrade metagpt && \
    pip install --upgrade git+https://github.com/geekan/MetaGPT.git && \
    playwright install --with-deps"

# Copy test config file config2.yaml from repository to ~/.metagpt/config2.yaml for tests
RUN mkdir -p /root/.metagpt && cp /testbed/tests/config2.yaml /root/.metagpt/config2.yaml

# Set working directory to /testbed
WORKDIR /testbed

# Set environment so that bash activates virtual environment automatically
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

# Default shell to bash explicitly
SHELL ["/bin/bash", "--login", "-c"]
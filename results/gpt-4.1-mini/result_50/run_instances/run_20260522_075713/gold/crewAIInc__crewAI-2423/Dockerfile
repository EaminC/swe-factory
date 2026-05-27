# Use Ubuntu 22.04 stable base image with bash shell
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system essentials including git, curl, wget, build tools, Python 3.10 and related packages, and ca-certificates
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to the latest version
RUN python3.10 -m pip install --no-cache-dir --upgrade pip

# Install Rust compiler required for building certain native dependencies
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y && \
    source $HOME/.cargo/env
ENV PATH="/root/.cargo/bin:${PATH}"

# Create python3.10 virtual environment at /opt/testbed
RUN python3.10 -m venv /opt/testbed

# Clone the repository, checkout specific commit, upgrade pip, and install the project in editable mode with optional features inside the virtual environment
RUN /bin/bash -c "\
    source /opt/testbed/bin/activate && \
    git clone https://github.com/crewAIInc/crewAI /testbed && \
    cd /testbed && \
    git reset --hard cb522cf5005f856b21c6976e8d94709ae4f9c3f3 && \
    pip install --no-cache-dir --upgrade pip && \
    pip install -e '.[tools,embeddings]' \
"

# Set working directory inside the container
WORKDIR /testbed

# Ensure virtual environment is activated by default for interactive shells
RUN echo 'source /opt/testbed/bin/activate' >> /root/.bashrc

# Define environment variables placeholders
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED="true"

# Use bash shell as default
SHELL ["/bin/bash", "-c"]
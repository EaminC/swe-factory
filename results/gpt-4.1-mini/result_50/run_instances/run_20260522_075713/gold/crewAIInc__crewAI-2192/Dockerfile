# Use a stable Ubuntu base image with bash
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system essentials including git, curl, build tools, Python 3.10 and pip
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

# Upgrade pip to latest version
RUN python3.10 -m pip install --no-cache-dir --upgrade pip

# Install Rust compiler needed for some dependencies (like tiktoken)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Create a virtual environment named 'testbed' using python3.10
RUN python3.10 -m venv /opt/testbed

# Activate virtual environment and install the target repository and its optional features
#  - Install Poetry or uv tools are not explicitly requested, so we follow pip install with editable mode 
#  - Use uv lock/sync/venv if they were scripts but no package names specified, so skip explicit install.
#  - Install with optional features [tools] and [embeddings] as recommended
RUN /bin/bash -c " \
    source /opt/testbed/bin/activate && \
    pip install --no-cache-dir --upgrade pip && \
    git clone https://github.com/crewAIInc/crewAI /testbed && \
    cd /testbed && \
    git reset --hard b4e2db03069fcedbf80eb2130aa91d0cb68b3a43 && \
    pip install --no-cache-dir -e '.[tools,embeddings]' \
"

# Set workdir to /testbed
WORKDIR /testbed

# Ensure bash shell activates the virtual environment by default
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Environment variables placeholder for user to inject before running tests
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED="true"

# Set default shell to bash explicitly
SHELL ["/bin/bash", "-c"]
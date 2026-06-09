# Base image: Ubuntu 22.04 with bash and essential tools
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and basics including Python 3.10, Rust tooling, Node.js, and npm
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    rustc \
    cargo \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Set python3.10 as default python3 and upgrade pip tools (including build and setuptools for pyproject.toml support)
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
    && python3 -m pip install --upgrade pip setuptools wheel build

# Environment variables to disable telemetry and placeholders for API keys
ENV OTEL_SDK_DISABLED=true
ENV OPENAI_API_KEY="sk-..."
ENV SERPER_API_KEY="YOUR_KEY_HERE"

# Set npm global install prefix and add npm global binaries directory to PATH permanently
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH="${NPM_CONFIG_PREFIX}/bin:${PATH}"

WORKDIR /testbed/

# Clone the crewAI repository and checkout the specific commit SHA
RUN git clone https://github.com/crewAIInc/crewAI /testbed \
    && git reset --hard e43c7debbd444486df77c83fc604641e18f1cd8a

# Setup Python virtual environment named 'testbed' and upgrade pip and build tools
RUN python3 -m venv ./testbed \
    && source ./testbed/bin/activate \
    && python -m pip install --upgrade pip setuptools wheel build

# Install the repo as editable along with optional extras to get the 'uv' CLI available,
# since 'uv' command likely comes bundled with the crewai package tooling, not npm
RUN source ./testbed/bin/activate \
    && pip install -e . \
    && pip install '.[tools]' \
    && pip install '.[embeddings]'

# Run uv commands via python -m uv in virtual environment, avoid relying on npm global uv CLI
RUN source ./testbed/bin/activate \
    && python -m uv lock \
    && python -m uv sync \
    && python -m uv venv \
    && python -m uv build

# Install pre-commit and run pre-commit install, then crewai install and update
RUN source ./testbed/bin/activate \
    && pip install pre-commit \
    && pre-commit install \
    && crewai install \
    && crewai update

# Persist environment activation on container shell start
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

WORKDIR /testbed/
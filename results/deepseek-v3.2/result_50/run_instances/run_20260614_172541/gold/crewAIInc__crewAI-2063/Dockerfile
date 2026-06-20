# Base image specification. Use Ubuntu 22.04 for stability and bash compatibility
FROM --platform=linux/x86_64 ubuntu:22.04

# Set environment variables for non-interactive installation
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation. Installs essential tools and libraries required for development and runtime
RUN apt-get update && apt-get install -y \
    wget \
    git \
    curl \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    pkg-config \
    libssl-dev \
    libffi-dev \
    libtiff-dev \
    libjpeg-dev \
    libopenjp2-7-dev \
    zlib1g-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    tcl-dev \
    tk-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libxcb1-dev \
    && rm -rf /var/lib/apt/lists/*

# Install UV (the project's dependency manager) from official source and update PATH in same layer
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && export PATH="/root/.local/bin:$PATH" \
    && uv --version

# Set PATH to include uv for subsequent commands
ENV PATH="/root/.local/bin:$PATH"

# Set default workdir to testbed
WORKDIR /testbed

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed \
    && chmod -R 777 /testbed

# Checkout the specific commit SHA provided
RUN cd /testbed && git reset --hard 6f4ad532e615a961ae7c5d57da48bb7209e3598b \
    && git remote remove origin

# Verify uv is available before using it
RUN which uv && uv --version

# Create virtual environment using UV and install all dependencies (including dev and extras)
RUN cd /testbed && uv venv \
    && uv sync --dev --all-extras

# Set up environment variables for testing (required by tests)
ENV OPENAI_API_KEY="fake-api-key"
ENV SERPER_API_KEY="fake-serper-key"
ENV OPEN_ROUTER_API_KEY="fake-openrouter-key"

# Disable telemetry by default
ENV OTEL_SDK_DISABLED="true"

# Add UV's virtual environment to PATH for easier access
ENV PATH="/testbed/.venv/bin:$PATH"

# Create a wrapper script to activate the virtual environment and run commands
RUN echo '#!/bin/bash\nsource /testbed/.venv/bin/activate\n"$@"' > /usr/local/bin/run-in-venv \
    && chmod +x /usr/local/bin/run-in-venv

# Set up the shell to automatically activate the virtual environment
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Verify Python version matches project requirements
RUN python --version
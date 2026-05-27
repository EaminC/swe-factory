# Base image specification - using Ubuntu 22.04 for stability and broad package support
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation
# Install essential build tools, development libraries, and utilities required for Python development
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    libtiff-dev \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    python-is-python3 \
    jq \
    curl \
    locales \
    locales-all \
    tzdata \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# Set workdir to testbed
WORKDIR /testbed/

# Clone the crewAI repository
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed && \
    chmod -R 777 /testbed

# Checkout to the specific commit
RUN cd /testbed && \
    git reset --hard e43c7debbd444486df77c83fc604641e18f1cd8a && \
    git remote remove origin || true

# Set up Python virtual environment
RUN python3 -m venv /testbed/.venv
ENV PATH="/testbed/.venv/bin:$PATH"
ENV VIRTUAL_ENV="/testbed/.venv"

# Upgrade pip, setuptools, and wheel in the virtual environment
RUN /testbed/.venv/bin/pip install --upgrade pip setuptools wheel

# Install UV package manager via pip in the virtual environment
# This ensures UV is available in subsequent RUN commands with the virtual environment active
RUN /testbed/.venv/bin/pip install uv

# Use UV to install dependencies and sync workspace
# uv sync will install the workspace packages (including lib/crewai) in development mode
# based on pyproject.toml configuration
RUN cd /testbed && \
    /testbed/.venv/bin/uv lock && \
    /testbed/.venv/bin/uv sync

# Install additional development dependencies and test frameworks via pip
# Using pip directly for these to avoid potential build issues with uv pip
RUN /testbed/.venv/bin/pip install \
    pytest==8.4.2 \
    pytest-asyncio==1.3.0 \
    pytest-subprocess==1.5.3 \
    vcrpy==7.0.0 \
    pytest-recording==0.13.4 \
    pytest-randomly==4.0.1 \
    pytest-timeout==2.4.0 \
    pytest-xdist==3.8.0 \
    pytest-split==0.10.0

# Set up critical environment variables for testing
ENV CREWAI_TESTING=true
ENV CREWAI_DISABLE_TELEMETRY=true
ENV OTEL_SDK_DISABLED=true
ENV CREWAI_TRACING_ENABLED=false
ENV PYTEST_VCR_RECORD_MODE=none
ENV PYTHONUNBUFFERED=1

# Set up test API keys (fake keys for testing without real API calls)
ENV OPENAI_API_KEY=fake-api-key
ENV ANTHROPIC_API_KEY=fake-anthropic-key
ENV GEMINI_API_KEY=fake-gemini-key
ENV AZURE_API_KEY=fake-azure-key
ENV OPENROUTER_API_KEY=fake-openrouter-key
ENV AWS_ACCESS_KEY_ID=fake-aws-access-key
ENV AWS_SECRET_ACCESS_KEY=fake-aws-secret-key
ENV AWS_DEFAULT_REGION=us-east-1
ENV OPENAI_BASE_URL=https://api.openai.com/v1
ENV OPENAI_API_BASE=https://api.openai.com/v1

# Create .env.test file for test environment configuration
RUN echo "CREWAI_TESTING=true" > /testbed/.env.test && \
    echo "CREWAI_DISABLE_TELEMETRY=true" >> /testbed/.env.test && \
    echo "OTEL_SDK_DISABLED=true" >> /testbed/.env.test && \
    echo "CREWAI_TRACING_ENABLED=false" >> /testbed/.env.test && \
    echo "PYTEST_VCR_RECORD_MODE=none" >> /testbed/.env.test && \
    echo "PYTHONUNBUFFERED=1" >> /testbed/.env.test

# Create temporary storage directory for tests
RUN mkdir -p /tmp/crewai_test_storage && chmod -R 777 /tmp/crewai_test_storage

# Ensure bash is the default shell
SHELL ["/bin/bash", "-c"]

# Set up bash profile to activate virtual environment
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Verify installations
RUN /testbed/.venv/bin/uv --version && \
    python --version && \
    /testbed/.venv/bin/pytest --version && \
    which python
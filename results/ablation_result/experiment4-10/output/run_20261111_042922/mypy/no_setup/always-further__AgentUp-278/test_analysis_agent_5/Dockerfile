# Use Ubuntu 22.04 as base image for stability and bash availability
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies including git, curl, python3.11 and essential build tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    python3-setuptools \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to latest version
RUN python3.11 -m pip install --upgrade pip

# Create and activate virtual environment 'testbed' using python3.11 venv
RUN python3.11 -m venv /opt/testbed

ENV PATH="/opt/testbed/bin:$PATH"

# Upgrade pip inside virtual env and install wheel to support all builds
RUN pip install --upgrade pip wheel

# Set workdir
WORKDIR /testbed/

# Clone repository and checkout specific commit
# The commit SHA will be provided during build time as build-arg
ARG COMMIT_SHA=a78ff2c52f20238958c078f51732ec95b22cd935

RUN git clone https://github.com/always-further/AgentUp.git /testbed/ \
    && cd /testbed/ \
    && git reset --hard ${COMMIT_SHA} \
    && git remote remove origin

# Install runtime and test dependencies from PyPI based on collected info
# (We install runtime + test deps because tests require pytest and pytest-asyncio)
RUN pip install \
    "click>=8.1.0" \
    "questionary>=2.0.1" \
    "pyyaml>=6.0.1" \
    "jinja2>=3.1.0" \
    "httpx>=0.28.1" \
    "a2a-sdk[sql]>=0.3.0" \
    "uvicorn>=0.34.3" \
    "fastapi>=0.115.12" \
    "numpy>=1.26.4" \
    "pillow>=11.3.0" \
    "asyncio>=3.4.3" \
    "fastmcp>=2.8.1" \
    "mcp>=1.0.0" \
    "pydantic>=2.11.5" \
    "pydantic-settings>=2.7.0" \
    "python-dotenv>=1.1.0" \
    "authlib>=1.6.0" \
    "psutil>=7.0.0" \
    "valkey>=6.0.0" \
    "pyjwt>=2.10.1" \
    "structlog>=25.4.0,<26.0.0" \
    "asgi-correlation-id>=4.3.4" \
    "redis>=6.2.0" \
    "aiohttp>=3.12.15" \
    "semver>=3.0.4" \
    "packaging>=23.0" \
    "importlib-metadata>=8.7.0" \
    "pytest>=8.4.0" \
    "pytest-asyncio>=1.0.0"

# Install the repository itself in editable/develop mode to reflect local changes
RUN pip install -e .

# Ensure bash is default shell
SHELL ["/bin/bash", "-c"]

# Add conda-analogous activation for venv to bashrc for convenience if needed
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Final working directory set to /testbed as required
WORKDIR /testbed/
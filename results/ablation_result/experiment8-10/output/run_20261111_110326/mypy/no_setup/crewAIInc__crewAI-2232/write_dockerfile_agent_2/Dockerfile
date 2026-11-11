# Use Ubuntu 22.04 as base image for stable bash environment and broad compatibility
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, curl, wget, build essentials, python3.10, python3-venv, python3-distutils, pip, setuptools, wheel, and ca-certificates
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools and wheel for Python 3.10 to ensure latest compatibility
RUN python3.10 -m pip install --upgrade pip setuptools wheel

# Create and activate a virtual environment 'testbed'
RUN python3.10 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Clone the repository into /testbed and checkout the requested commit
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed && \
    cd /testbed && \
    git reset --hard 34d299345677c7ce26b1368f240c559596526fa7

WORKDIR /testbed

# Install core, optional, and development dependencies and finally install the package in editable mode
# Use pip to install dependencies as per pyproject.toml requires hatchling build system: we will install hatch first, then build dependencies with pip
RUN pip install hatch build

# Extract core, optional and dev dependencies from pyproject.toml manually with hatch by building a wheel with dependencies installed via pip.
# Since direct poetry is not used and we have hatchling, install dependencies manually:
RUN pip install "pydantic>=2.4.2" "openai>=1.13.3" "litellm==1.60.2" "instructor>=1.3.3" "pdfplumber>=0.11.4" "regex>=2024.9.11" "opentelemetry-api>=1.22.0" "opentelemetry-sdk>=1.22.0" "opentelemetry-exporter-otlp-proto-http>=1.22.0" "chromadb>=0.5.23" "openpyxl>=3.1.5" "pyvis>=0.3.2" "auth0-python>=4.7.1" "python-dotenv>=1.0.0" "click>=8.1.7" "appdirs>=1.4.4" "jsonref>=1.1.0" "json-repair>=0.25.2" "uv>=0.4.25" "tomli-w>=1.1.0" "tomli>=2.0.2" "blinker>=1.9.0" "json5>=0.10.0" \
    ruff mypy pre-commit mkdocs mkdocstrings mkdocs-material pillow cairosvg pytest pytest-vcr python-dotenv pytest-asyncio pytest-subprocess

# Then install the repository itself in editable mode to ensure local code is used
RUN pip install -e .

# Add bashrc command to activate the virtual environment automatically for convenience
RUN echo "source /opt/venv/bin/activate" >> /root/.bashrc

# Default working directory as requested
WORKDIR /testbed
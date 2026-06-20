# Base image with Python 3.10 (matching CI requirements)
FROM --platform=linux/x86_64 python:3.10-slim

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /testbed

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    git reset --hard c29bdded396eff9a47aa36643ce1169b2ebf5318 && \
    git remote remove origin

# Upgrade pip, setuptools, and wheel to match CI configuration
RUN pip install --upgrade pip setuptools==78.1.1 wheel==0.45.1

# Install the package in development mode with dev extras (as per CI)
RUN pip install -q -e .[dev]

# Install additional test dependencies (coverage, pytest)
RUN pip install coverage pytest

# Clean up pip cache
RUN pip cache purge

# Set environment variable for DashScope (optional, but may be needed for tests)
ENV DASHSCOPE_API_KEY="dummy_key_for_testing"

# Verify Python version and installed packages
RUN python --version && \
    pip list | grep agentscope
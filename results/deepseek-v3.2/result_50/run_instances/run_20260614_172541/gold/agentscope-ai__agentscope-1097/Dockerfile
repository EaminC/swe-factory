# Base image with Python 3.10 (minimum required version) and bash
FROM --platform=linux/x86_64 python:3.10-bookworm

# Set environment variables to avoid interactive prompts
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    libffi-dev \
    libtiff-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /testbed

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    git reset --hard f44b10fcf8d88b2be1cb4474598bf5875242d21d && \
    git remote remove origin

# Upgrade pip and install setuptools/wheel to specific versions (from CI)
RUN pip install --upgrade pip && \
    pip install setuptools==78.1.1 wheel==0.45.1

# Install the package in development mode with dev extras
# This installs both core dependencies and development/test dependencies
RUN pip install -e .[dev]

# Install additional test dependencies (coverage, pytest-forked, etc.)
RUN pip install coverage pytest pytest-forked

# Install optional dependencies for the target test files
# gemini: for model_gemini_test.py
# ollama: for model_ollama_test.py
# dashscope is already a core dependency
RUN pip install google-genai ollama>=0.5.4

# Install pre-commit (optional, for development but may be needed for some hooks)
RUN pip install pre-commit

# Set up environment for testing (no API keys needed as tests are mocked)
# No additional environment variables required based on context retrieval

# Verify installation
RUN python -c "import agentscope; print(f'AgentScope version: {agentscope.__version__}')" && \
    python -c "import dashscope; import google.genai; import ollama; print('Optional dependencies installed successfully')"

# Clean up to reduce image size
RUN pip cache purge && \
    apt-get clean
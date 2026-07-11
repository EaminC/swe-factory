FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Use bash as the shell for all RUN commands
SHELL ["/bin/bash", "-c"]

# Install system dependencies including Python 3.10 (required >=3.10), git, and build tools
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    wget \
    curl \
    ca-certificates \
    python3.10 \
    python3-pip \
    python3.10-venv \
    python-is-python3 \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Ensure python and python3 point to python3.10
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Upgrade pip to latest version
RUN pip install --no-cache-dir --upgrade pip

# Set working directory
WORKDIR /testbed/

# Clone the repository, checkout the specific commit, and set permissions
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed/ && \
    git reset --hard f44b10fcf8d88b2be1cb4474598bf5875242d21d && \
    git remote remove origin && \
    chmod -R 777 /testbed/

# Install build dependencies and the package in development mode with dev extras
# This includes pytest, dashscope, google-genai, ollama, and other test dependencies
RUN pip install setuptools==78.1.1 wheel==0.45.1 && \
    pip install -e .[dev]

# Set Python environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Default to bash shell
CMD ["/bin/bash"]
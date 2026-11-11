# Use Ubuntu 22.04 as the base image with bash shell by default
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies including python3.10, git, curl, build essentials, and tzdata
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, and wheel for Python 3.10
RUN python3.10 -m pip install --upgrade pip setuptools wheel

# Create working directory /testbed
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed \
    && git checkout dc7a2bd0f546ea29929faa57b8e618c413c86bb2

# Install the repository in editable mode (includes all dependencies from setup.cfg or pyproject.toml)
RUN python3.10 -m pip install -e .

# Explicitly install langchain version known to include 'langchain.callbacks' submodule
# Pin a stable version that includes callbacks (e.g., a more recent version than 0.0.240)
RUN python3.10 -m pip install "langchain>=0.0.170" --force-reinstall

# Install additional test dependencies separately if needed (pytest, pytest-cov)
RUN python3.10 -m pip install pytest==7.3.1 pytest-cov

# Verify langchain.callbacks module availability, fail build if missing
RUN python3.10 -c "from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler"

# Add default bashrc initialization for convenience (optional)
RUN echo "export OPENAI_API_KEY=\"\"" >> /root/.bashrc

# Set working directory to /testbed explicitly
WORKDIR /testbed/
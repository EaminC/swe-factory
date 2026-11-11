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

# Upgrade pip and setuptools for Python 3.10
RUN python3.10 -m pip install --upgrade pip setuptools wheel

# Create working directory /testbed
WORKDIR /testbed/

# Clone the repository, checkout the specific commit, and install the package in editable mode
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed \
    && git checkout dc7a2bd0f546ea29929faa57b8e618c413c86bb2

# Install required Python packages including dependencies and dev/test tools
# Use only the requirements inside the repo by installing the package in editable mode
RUN python3.10 -m pip install -e . \
    && python3.10 -m pip install \
        black==23.3.0 \
        click>=8.0.0 \
        mypy==1.3.0 \
        openai==0.27.8 \
        pre-commit==3.3.3 \
        pytest==7.3.1 \
        ruff==0.0.272 \
        termcolor==2.3.0 \
        typer>=0.3.2 \
        rudder-sdk-python==2.0.2 \
        dataclasses-json==0.5.7 \
        tiktoken>=0.0.4 \
        tabulate==0.9.0 \
        python-dotenv>=0.21.0 \
        langchain>=0.0.240

# Ensure bash prompt sources python in PATH for interactive runs
ENV PATH="/usr/local/bin:$PATH"

# Add default bashrc initialization for convenience (optional)
RUN echo "export OPENAI_API_KEY=\"\"" >> /root/.bashrc

# Set working directory to /testbed explicitly
WORKDIR /testbed/
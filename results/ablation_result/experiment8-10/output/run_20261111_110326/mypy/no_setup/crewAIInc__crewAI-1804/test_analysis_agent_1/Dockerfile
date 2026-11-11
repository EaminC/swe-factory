# Use Ubuntu 22.04 as base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies, git, Python and other needed tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3-pip \
    python3.11-distutils \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Upgrade pip and install uv tool globally
RUN python3 -m pip install --upgrade pip \
    && pip install uv

# Create working directory
WORKDIR /testbed/

# Clone the repository and checkout the specified commit
ARG REPO=https://github.com/crewAIInc/crewAI.git
ARG COMMIT_SHA=409892d65fab88e4a390f05c46b399b5a9260463
RUN git clone "$REPO" . \
    && git reset --hard "$COMMIT_SHA"

# Create and activate virtual environment in /testbed/.venv, install dependencies using uv commands
RUN python3 -m venv .venv \
    && source .venv/bin/activate \
    && pip install --upgrade pip setuptools wheel \
    && uv lock \
    && uv sync \
    # Build the package and install locally in editable mode
    && uv build \
    && pip install dist/*.tar.gz

# Fix permissions to ensure read/write access
RUN chmod -R a+rw /testbed

# Set environment variables as placeholders (can be overridden at runtime)
ENV OPENAI_API_KEY=fake-api-key
ENV SERPER_API_KEY=fake-api-key
ENV OTEL_SDK_DISABLED=true

# Set working directory
WORKDIR /testbed/

# Ensure shell activates the venv by default
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc
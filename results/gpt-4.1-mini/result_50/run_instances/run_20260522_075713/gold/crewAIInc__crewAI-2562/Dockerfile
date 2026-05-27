# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# System dependencies installation. Installs essential tools and libraries required for development and runtime (Required)
RUN apt update && apt install -y \
    git \
    wget \
    curl \
    build-essential \
    libffi-dev \
    libssl-dev \
    locales-all \
    tzdata \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    python3 -m pip install --upgrade pip && \
    rm -rf /var/lib/apt/lists/*

# Install hatchling build system globally since project uses it
RUN python3 -m pip install hatchling

# Set working directory
WORKDIR /testbed/

# Clone target repository and checkout specific commit SHA
ARG COMMIT_SHA=5780c3147afd2db9be5cd7eb88450a0f04f12977
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed && \
    cd /testbed && \
    git reset --hard ${COMMIT_SHA} && \
    git remote remove origin

# Create and activate Python virtual environment, install uv tool and dependencies, then install the project in editable mode
RUN python3 -m venv testbed && \
    source testbed/bin/activate && \
    python -m pip install --upgrade pip setuptools wheel && \
    # Install uv tool for dependency resolution as per environment setup
    pip install uv==0.4.25 && \
    # Use uv to install pinned dependencies and sync environment
    uv lock && \
    uv sync && \
    # Install the local package in editable mode
    pip install -e . && \
    # Install test dependencies according to context retrieval info
    pip install pytest>=8.0.0 pytest-asyncio pytest-subprocess pytest-vcr mypy pre-commit ruff python-dotenv crewai-tools~=0.40.1 tiktoken~=0.7.0 agentops>=0.3.0 && \
    deactivate

# Add activation command to bashrc for convenience
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

# Set default shell explicitly (bash already set by SHELL above)
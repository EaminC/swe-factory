FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies and essential tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3 \
    python3-dev \
    python-is-python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install uv (the package manager used by the project)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout to the specific commit
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed/ && \
    git reset --hard 69dd20e523c4c392d751034384afab275dcf305f && \
    git remote remove origin

# Install dependencies using uv from the langgraph library directory
# This creates a virtual environment and installs:
# - The langgraph package in editable mode
# - All development dependencies (pytest, syrupy, etc.)
# - All local workspace packages (checkpoint, prebuilt, sdk, etc.) in editable mode
RUN cd /testbed/libs/langgraph && \
    uv sync --frozen --all-extras --all-packages --group dev

# Ensure the virtual environment is activated by default
ENV PATH="/testbed/libs/langgraph/.venv/bin:$PATH"

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]
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
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install uv (the package manager used by the project)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout to the specific commit
# The repository is a monorepo with libs/langgraph as the target
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed/ && \
    git reset --hard d68bac386564054cf6a572064f46c55186219041 && \
    git remote remove origin

# Change to the langgraph library directory where pyproject.toml is located
WORKDIR /testbed/libs/langgraph

# Install dependencies using uv
# This creates a virtual environment (.venv) and installs:
# - The langgraph package in editable mode
# - All development dependencies (pytest, etc.)
# - Editable local dependencies (prebuilt, checkpoint, etc.) from sibling directories
RUN uv sync --frozen --group dev

# Ensure the virtual environment is activated by default
ENV PATH="/testbed/libs/langgraph/.venv/bin:$PATH"

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]
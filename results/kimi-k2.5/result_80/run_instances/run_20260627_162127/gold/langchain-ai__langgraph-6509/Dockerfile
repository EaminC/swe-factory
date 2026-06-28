FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies and Python 3.11
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    ca-certificates \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Astral's Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Set working directory
WORKDIR /testbed/

# Clone repository and checkout specific commit
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed/ && \
    git checkout 5212369bd0791806083f183cb19ccce024db8790 && \
    git remote remove origin

# Navigate to the prebuilt library directory and install dependencies
# This installs the package in editable mode along with all local dependencies and test dependencies
WORKDIR /testbed/libs/prebuilt
RUN uv sync --frozen --group test --no-dev

# Set environment variable for fast tests (in-memory checkpointer, no Docker services required)
ENV LANGGRAPH_TEST_FAST=1

# Configure bash as the default shell
SHELL ["/bin/bash", "-c"]
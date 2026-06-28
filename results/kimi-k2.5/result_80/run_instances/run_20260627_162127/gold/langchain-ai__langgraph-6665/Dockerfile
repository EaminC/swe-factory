FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies including git, build tools, and curl
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    curl \
    wget \
    ca-certificates \
    python3 \
    python3-dev \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install uv (modern Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Set working directory for cloning
WORKDIR /testbed/

# Clone repository and checkout specific commit
ARG COMMIT_SHA=8ccead9560f6cd76537f632d7a310ba41e38f28b
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed/ && \
    git reset --hard ${COMMIT_SHA} && \
    git remote remove origin && \
    chmod -R 777 /testbed/

# Install Python 3.11
RUN uv python install 3.11

# Change to the langgraph package directory where pyproject.toml is located
WORKDIR /testbed/libs/langgraph

# Install dependencies including test dependencies and local editable packages
# Using --group test as specified in CI configuration for testing
RUN uv sync --frozen --group test --no-dev --python 3.11

# Add virtual environment to PATH to make pytest and python available
ENV PATH="/testbed/libs/langgraph/.venv/bin:$PATH"

# Set environment variable to skip tests requiring external Docker services (PostgreSQL/Redis)
ENV NO_DOCKER=true

# Ensure bash is used as the default shell
SHELL ["/bin/bash", "-c"]
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies including build tools, git, and PostgreSQL client libraries
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    llvm \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    software-properties-common \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.11 (within the >=3.9 requirement)
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y python3.11 python3.11-dev python3.11-venv && \
    rm -rf /var/lib/apt/lists/* && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    ln -sf /usr/bin/python3.11 /usr/bin/python

# Install uv (ultrafast Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv $HOME/.local/bin/uv /usr/local/bin/uv && \
    uv --version

# Set workdir
WORKDIR /testbed/

# Clone repository and checkout specific commit
ARG REPO_URL=https://github.com/langchain-ai/langgraph.git
ARG COMMIT_SHA=328129e5bd01805ed9a2c925df4d02d065e9ac15

RUN git clone ${REPO_URL} . && \
    git reset --hard ${COMMIT_SHA} && \
    git remote remove origin && \
    chmod -R 777 /testbed/

# Install dependencies using uv in the correct subdirectory where pyproject.toml exists
RUN cd /testbed/libs/langgraph && uv sync --frozen --group dev

# Set environment variables for testing
# NO_DOCKER=true ensures tests use in-memory/SQLite variants instead of requiring external Redis/PostgreSQL services
ENV NO_DOCKER=true
ENV PYTHONUNBUFFERED=1
# Ensure the virtual environment binaries are in PATH (venv is created in the subdirectory)
ENV PATH="/testbed/libs/langgraph/.venv/bin:$PATH"
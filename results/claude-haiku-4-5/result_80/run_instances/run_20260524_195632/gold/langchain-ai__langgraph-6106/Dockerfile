# Base image specification
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    libtiff-dev \
    python3 \
    python3-pip \
    python-is-python3 \
    curl \
    locales \
    locales-all \
    tzdata \
    jq \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default (satisfies >=3.9 requirement)
RUN apt-get update && apt-get install -y python3.11 python3.11-venv python3.11-dev \
    && rm -rf /var/lib/apt/lists/*

# Install uv package manager using pip (more reliable than curl script)
RUN python3.11 -m pip install --upgrade pip setuptools wheel && \
    python3.11 -m pip install uv

# Set work directory
WORKDIR /testbed/

# Clone the LangGraph repository
RUN git clone https://github.com/langchain-ai/langgraph /testbed && \
    chmod -R 777 /testbed

# Checkout specific commit
RUN cd /testbed && \
    git reset --hard 6fc5b3aeda2aaa89277c79dc3682e7c723e2abb6 && \
    git remote remove origin

# Create virtual environment and install all dependencies in one RUN command
# This preserves PATH and environment variables throughout the installation
# Install local monorepo packages first, then other dependencies
RUN /bin/bash -c "cd /testbed && \
    python3.11 -m uv venv /testbed/.venv --python python3.11 && \
    source /testbed/.venv/bin/activate && \
    uv pip install 'langchain-core>=0.1' && \
    uv pip install -e libs/checkpoint && \
    uv pip install -e libs/checkpoint-sqlite && \
    uv pip install -e libs/checkpoint-postgres && \
    uv pip install -e libs/prebuilt && \
    uv pip install -e libs/sdk-py && \
    uv pip install -e libs/cli && \
    uv pip install \
    'xxhash>=3.5.0' \
    'pydantic>=2.7.4' \
    pytest \
    pytest-cov \
    pytest-dotenv \
    pytest-mock \
    syrupy \
    httpx \
    pytest-watcher \
    mypy \
    ruff \
    jupyter \
    'pytest-xdist[psutil]' \
    pytest-repeat \
    'psycopg[binary]' \
    'uvloop==0.21.0b1' \
    pyperf \
    py-spy \
    types-requests \
    pycryptodome \
    redis \
    pytest-anyio && \
    uv pip install -e libs/langgraph/"

# Set up environment variables for the virtual environment
ENV VIRTUAL_ENV=/testbed/.venv
ENV PATH="/testbed/.venv/bin:$PATH"

# Configure shell to activate venv on startup
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Set shell to bash
SHELL ["/bin/bash", "-c"]
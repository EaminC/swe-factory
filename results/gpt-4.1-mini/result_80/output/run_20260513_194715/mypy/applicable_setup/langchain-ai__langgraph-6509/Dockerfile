# Use official Ubuntu 22.04 as base image for stable bash environment and compatibility
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies: git, curl, wget, build tools, python3.11 and related packages,
# as well as PostgreSQL client libraries and gcc for compiling native extensions (e.g. psycopg)
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    gcc \
    libpq-dev \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    python3.11-dev \
    locales \
    locales-all \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install virtualenv
RUN python3.11 -m pip install --upgrade pip setuptools wheel virtualenv

# Create directory and set workdir
WORKDIR /testbed/

# Clone the repository and checkout the given commit SHA (build ARG)
ARG REPO=https://github.com/langchain-ai/langgraph.git
ARG COMMIT_SHA=5212369bd0791806083f183cb19ccce024db8790

RUN git clone $REPO /testbed/ && \
    cd /testbed && \
    git reset --hard $COMMIT_SHA

# Create and activate python virtual environment, install dependencies
RUN python3.11 -m venv /testbed/testbed-venv && \
    source /testbed/testbed-venv/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    # Install editable package libs/cli first because it is required, using pip install -e .
    cd libs/cli && pip install -e . && \
    cd /testbed && \
    # Install editable packages for subfolders that contain packaging, excluding root which lacks setup.py or pyproject.toml
    for pkg in libs/langgraph libs/sdk-py libs/prebuilt libs/checkpoint-sqlite libs/checkpoint-postgres libs/checkpoint; do \
        if [ -f "$pkg/pyproject.toml" ] || [ -f "$pkg/setup.py" ]; then \
            cd $pkg && pip install -e . && cd /testbed; \
        fi \
    done

# Expose environment variable placeholder for LANGSMITH_API_KEY
ENV LANGSMITH_API_KEY=""

# Fix permissions for /testbed to ensure ease of use when running tests
RUN chmod -R a+rwx /testbed

# Set default working directory
WORKDIR /testbed

# Default shell as bash
ENV SHELL=/bin/bash
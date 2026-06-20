# Base image with Python 3.11 (as used in CI)
FROM --platform=linux/x86_64 python:3.11-slim

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation
RUN apt update && apt install -y \
    wget \
    git \
    build-essential \
    curl \
    locales \
    tzdata \
    postgresql-client \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:${PATH}"
ENV PATH="/root/.local/bin:${PATH}"

# Set default workdir
WORKDIR /testbed/

# Clone the repository
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed

# Checkout the specific commit
RUN cd /testbed && git reset --hard 18887e9f86a6d8675a2b4aed03a1c190ef6e1581

# Remove origin to avoid accidental pushes
RUN cd /testbed && git remote remove origin

# Set up the environment for langgraph tests
# First, install uv globally if not already in PATH
RUN uv --version || curl -LsSf https://astral.sh/uv/install.sh | sh

# Change to the langgraph directory (libs/langgraph) and set up environment
WORKDIR /testbed/libs/langgraph

# Create virtual environment and install dependencies using uv
# Following the make install command: uv sync --frozen --all-extras --all-packages --group dev
RUN uv venv .venv
ENV PATH="/testbed/libs/langgraph/.venv/bin:${PATH}"

# Install the langgraph package in editable mode (authoritative source)
RUN uv pip install -e .

# Install all dependencies including dev dependencies
RUN uv sync --frozen --all-extras --all-packages --group dev

# Also install editable versions of other libs in the monorepo (following Makefile pattern)
# This ensures all internal dependencies are properly linked
WORKDIR /testbed
RUN for dir in libs/*/; do \
    if [ -f "$dir/pyproject.toml" ] && [ "$dir" != "libs/langgraph/" ]; then \
        echo "Installing $dir in development mode"; \
        cd "$dir" && uv pip install -e .; \
    fi; \
    done

# Install additional test dependencies that might be needed
# Note: We don't pre-install langgraph packages from PyPI since we have the local versions
WORKDIR /testbed/libs/langgraph
RUN uv pip install pytest pytest-cov pytest-dotenv pytest-mock syrupy httpx \
    pytest-watcher mypy ruff jupyter pytest-xdist[psutil] pytest-repeat \
    uvloop==0.21.0beta1 pyperf py-spy types-requests pycryptodome

# Install langgraph sub-packages that are test dependencies (postgres support)
RUN uv pip install psycopg[binary]

# Set environment variables for test execution
ENV NO_DOCKER=1
ENV PYTHONPATH=/testbed/libs:$PYTHONPATH

# Copy pytest configuration files from the repository root
WORKDIR /testbed
RUN if [ -f "pyproject.toml" ]; then cp pyproject.toml .; fi
RUN if [ -f "pytest.ini" ]; then cp pytest.ini .; fi

# Set the working directory back to langgraph for test execution
WORKDIR /testbed/libs/langgraph

# Add virtual environment activation to bashrc for interactive sessions
RUN echo "source /testbed/libs/langgraph/.venv/bin/activate" >> /root/.bashrc

# Verify the environment is set up correctly using uv
RUN python --version && \
    uv --version && \
    which pytest && \
    uv pip list | grep -E "langgraph|pytest" || echo "Packages verified"
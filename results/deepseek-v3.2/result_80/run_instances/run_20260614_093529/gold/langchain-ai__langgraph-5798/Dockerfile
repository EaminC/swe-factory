# Base image with Python 3.11 (as used in CI)
FROM --platform=linux/x86_64 python:3.11-slim-bookworm

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
    docker.io \
    docker-compose \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Verify uv installation
RUN which uv && uv --version

# Set default workdir
WORKDIR /testbed/

# Clone the repository
RUN git clone https://github.com/langchain-ai/langgraph /testbed

# Checkout specific commit
RUN cd /testbed && git reset --hard 220314b53a960964a82657451b846f3a7cb2f348

# Go to langgraph directory
WORKDIR /testbed/libs/langgraph

# Create a virtual environment in the project directory
RUN uv venv .venv

# Set up virtual environment paths
ENV VIRTUAL_ENV="/testbed/libs/langgraph/.venv" \
    PATH="/testbed/libs/langgraph/.venv/bin:${PATH}"

# Install dependencies using uv sync with dev group (should install pytest and all dev dependencies)
RUN uv sync --frozen --all-extras --all-packages --group dev

# Install the package in development mode to ensure local code is referenced
RUN uv pip install -e .

# Set up environment variables for test execution
ENV NO_DOCKER="false" \
    TEST="." \
    PYTHONPATH="/testbed/libs:/testbed/libs/langgraph:${PYTHONPATH}"

# Clean up to reduce image size
RUN apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create a script to activate the virtual environment
RUN echo "source /testbed/libs/langgraph/.venv/bin/activate 2>/dev/null || true" >> /root/.bashrc
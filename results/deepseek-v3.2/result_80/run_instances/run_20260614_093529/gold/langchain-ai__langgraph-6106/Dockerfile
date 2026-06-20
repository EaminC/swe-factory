# Base image specification. Defines the foundation OS and architecture for the container
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation. Installs essential tools and libraries required for development and runtime
RUN apt update && apt install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    libssl-dev \
    libpq-dev \
    python3 \
    python3-pip \
    python-is-python3 \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    curl \
    locales \
    tzdata \
    docker.io \
    docker-compose \
    && rm -rf /var/lib/apt/lists/*

# Set up Python 3.11 as the default python3 (matches Python >=3.9 requirement and CI configuration)
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Install uv package manager (required by the project for dependency management)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH=/root/.local/bin:$PATH

# Verify uv installation
RUN which uv && uv --version

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Set default workdir to testbed
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed && \
    cd /testbed && \
    git reset --hard 6fc5b3aeda2aaa89277c79dc3682e7c723e2abb6

# Change to the langgraph subdirectory (where the target test file is located)
WORKDIR /testbed/libs/langgraph

# Install dependencies using uv (as specified in the Makefile)
# Install with all extras and dev group to ensure all test dependencies are available
RUN uv sync --frozen --all-extras --all-packages --group dev

# Install the package in development mode to ensure local code is referenced
RUN uv pip install -e .

# Set environment variables for test execution
ENV NO_DOCKER=false \
    TEST=. \
    PYTHONPATH=/testbed/libs/langgraph:$PYTHONPATH

# Set the default command to bash
CMD ["/bin/bash"]
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
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Set up Python 3.11 as the default python3 (matches CI configuration)
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Install uv package manager (required by the project)
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
    git reset --hard 84023451a2bd5987b1d4df530f4145d503d75ccb

# Install dependencies using uv for both target libraries
# First install langgraph dependencies (using --group test without --no-dev to include pytest)
WORKDIR /testbed/libs/langgraph
RUN uv sync --frozen --all-extras --all-packages --group test

# Install langgraph in development mode
RUN uv pip install -e .

# Then install prebuilt dependencies
WORKDIR /testbed/libs/prebuilt
RUN uv sync --frozen --all-extras --all-packages --group test

# Install prebuilt in development mode
RUN uv pip install -e .

# Install other internal dependencies in the monorepo to ensure proper linking
# This follows the pattern from the Makefile
WORKDIR /testbed
RUN for dir in libs/*/; do \
    if [ -f "$dir/pyproject.toml" ] && [ "$dir" != "libs/langgraph/" ] && [ "$dir" != "libs/prebuilt/" ]; then \
        echo "Installing $dir in development mode"; \
        cd "$dir" && uv pip install -e .; \
    fi; \
    done

# Set environment variables for test execution
ENV PYTHONPATH=/testbed/libs:$PYTHONPATH

# Set the default command to bash
CMD ["/bin/bash"]
FROM --platform=linux/x86_64 python:3.10-bookworm

# Set environment variables to avoid interactive prompts
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    libffi-dev \
    libtiff-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /testbed

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    git reset --hard 8faa353e579591f99f3322a1aab3f35f2abafdf8 && \
    git remote remove origin

# Upgrade pip and install setuptools/wheel to specific versions (from CI)
RUN pip install --upgrade pip && \
    pip install setuptools==78.1.1 wheel==0.45.1

# Install the package in development mode with dev extras
# This installs both core dependencies and development/test dependencies including aiosqlite
RUN pip install -e .[dev]

# Install additional test dependencies that might not be in dev extras
RUN pip install pytest-forked coverage

# Install optional dependencies for the target test files
# from async_related_dependencies: ensure aiosqlite is installed (already included in dev)
# Install fakeredis explicitly for Redis memory tests
RUN pip install fakeredis

# Set up environment for testing (no API keys needed as tests are mocked)
ENV GRPC_VERBOSITY=ERROR

# Clean up to reduce image size
RUN pip cache purge && \
    apt-get clean
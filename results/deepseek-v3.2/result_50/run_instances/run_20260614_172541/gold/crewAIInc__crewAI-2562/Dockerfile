# Base image specification. Defines the foundation OS and architecture for the container
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation. Installs essential tools and libraries required for development and runtime
RUN apt update && apt install -y \
    wget \
    git \
    build-essential \
    curl \
    locales \
    tzdata \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install specific Python versions (3.10, 3.11, 3.12) as required by pyproject.toml
# Ensure all required versions are available for potential dependency resolution
RUN add-apt-repository ppa:deadsnakes/ppa -y \
    && apt update && apt install -y \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pip for Python 3.12 (which we'll use as default)
RUN wget https://bootstrap.pypa.io/get-pip.py \
    && python3.12 get-pip.py \
    && rm get-pip.py

# Install UV (dependency management tool used in the project)
RUN python3.12 -m pip install uv>=0.4.25

# Set default workdir to testbed
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/crewAIInc/crewAI /testbed \
    && chmod -R 777 /testbed \
    && cd /testbed \
    && git reset --hard 5780c3147afd2db9be5cd7eb88450a0f04f12977 \
    && git remote remove origin

# Set up Python environment using UV with Python 3.12
# Using 3.12 instead of 3.10 to fix typing.Self import error
RUN uv python install 3.12

# Install project dependencies with all extras and dev dependencies
RUN uv sync --dev --all-extras

# Install the project in development mode
RUN uv pip install -e .

# Set environment variables required for tests
ENV OPENAI_API_KEY="test-key"
ENV SERPER_API_KEY="test-key"
ENV OTEL_SDK_DISABLED="true"

# Add UV to PATH and set up environment activation
RUN echo 'export PATH="/root/.local/bin:$PATH"' >> /root/.bashrc
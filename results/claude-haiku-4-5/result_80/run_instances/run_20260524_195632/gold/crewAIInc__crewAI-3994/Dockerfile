# Base image with Python and build tools
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    git \
    curl \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-dev \
    python3-pip \
    python-is-python3 \
    ca-certificates \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install UV package manager
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Set PATH for UV immediately
ENV PATH="/root/.local/bin:$PATH"

# Verify UV installation
RUN /root/.local/bin/uv --version

# Set workdir
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/crewAIInc/crewAI /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard 4d8eec96e8432eda570207a601655ec29e9d1d6e && \
    git remote remove origin

# Lock dependencies
RUN /root/.local/bin/uv lock

# Sync all dependencies and install workspace members
# uv sync handles installing all workspace members (lib/crewai, lib/crewai-tools, lib/devtools)
# and all their dependencies, including test requirements
RUN /root/.local/bin/uv sync

# Install LiteLLM as an optional dependency required for testing
# LiteLLM is needed for fallback LLM functionality in crewAI
RUN /root/.local/bin/uv pip install 'litellm>=1.74.9'

# Install additional optional dependencies for comprehensive testing
RUN /root/.local/bin/uv pip install 'boto3>=1.40.38' 'anthropic>=0.69.0' 'google-genai>=1.2.0'

# Verify Python and pip are available
RUN python3 --version && pip --version

# Set required environment variables for testing
ENV OPENAI_API_KEY="test-key-placeholder"
ENV SERPER_API_KEY="test-key-placeholder"
ENV OTEL_SDK_DISABLED=true

# Set default shell to bash
SHELL ["/bin/bash", "-c"]

# Configure bash to use the UV environment by default
RUN echo 'export PATH="/root/.local/bin:$PATH"' >> /root/.bashrc
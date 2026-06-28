FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies required for building Python packages and running the application
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    ca-certificates \
    python3-dev \
    libffi-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager) - modern Python tooling used by crewAI
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Set working directory to /testbed as required
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
# Remove origin to prevent accidental pushes during development
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed/ && \
    git reset --hard e43c7debbd444486df77c83fc604641e18f1cd8a && \
    git remote remove origin && \
    chmod -R 777 /testbed/

# Navigate to the specific package directory where pyproject.toml is located
WORKDIR /testbed/lib/crewai

# Set up Python environment using uv
# Use Python 3.12 (matches mypy target and is within supported range >=3.10, <3.14)
RUN uv venv --python 3.12 && \
    uv lock && \
    uv sync --all-groups --all-extras

# Ensure the package is installed in editable/development mode
# This ensures that code modifications in /testbed are reflected immediately
RUN uv pip install -e .

# Set environment variables required for testing (from .env.test)
# These fake API keys and settings allow tests to run without real external services
ENV OPENAI_API_KEY=fake-api-key
ENV ANTHROPIC_API_KEY=fake-anthropic-key
ENV GEMINI_API_KEY=fake-gemini-key
ENV AZURE_API_KEY=fake-azure-key
ENV AWS_ACCESS_KEY_ID=fake-aws-access-key
ENV AWS_SECRET_ACCESS_KEY=fake-aws-secret-key
ENV AWS_DEFAULT_REGION=us-east-1
ENV SERPER_API_KEY=fake-serper-key
ENV CREWAI_DISABLE_TELEMETRY=true
ENV OTEL_SDK_DISABLED=true
ENV CREWAI_TESTING=true
ENV PYTEST_VCR_RECORD_MODE=none
ENV PYTHONUNBUFFERED=1

# Set default shell to bash for compatibility
SHELL ["/bin/bash", "-c"]

# Return to /testbed as the final working directory
WORKDIR /testbed/
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies including Python 3.11, git, and build tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set python3.11 as the default python3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Install UV package manager (as specified in the project requirements)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Set working directory to /testbed
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed && \
    git reset --hard 7e6171d5bc35da485e119fef9442faa02fcd0984 && \
    git remote remove origin && \
    chmod -R 777 /testbed

# Create virtual environment using UV with Python 3.11
RUN uv venv .venv --python=python3.11
ENV PATH="/testbed/.venv/bin:$PATH"

# Lock dependencies and sync to install all dependencies (including workspace members)
RUN uv lock
RUN uv sync

# Set required environment variables for testing (dummy values as placeholders)
ENV OPENAI_API_KEY=sk-test-dummy-key-for-testing
ENV SERPER_API_KEY=dummy-serper-api-key

# Ensure bash is the default shell for compatibility
SHELL ["/bin/bash", "-c"]
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PYTHONUNBUFFERED=1
SHELL ["/bin/bash", "-c"]

# Install system dependencies including Python 3.11
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python-is-python3 \
    libffi-dev \
    libssl-dev \
    pkg-config \
    locales \
    tzdata \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install uv 0.8.4
RUN curl -LsSf https://astral.sh/uv/0.8.4/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Clone repository, checkout specific commit, and ensure pristine state
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed && \
    cd /testbed && \
    git reset --hard 528d81226361be0f87c9e077ed0d3eb28243120f && \
    git clean -fd && \
    git remote remove origin && \
    chmod -R 777 /testbed

WORKDIR /testbed

# Create virtual environment with Python 3.11
RUN uv venv .venv --python=python3.11
ENV PATH="/testbed/.venv/bin:$PATH"

# Install all dependencies including dev/test groups and extras
RUN uv sync --all-groups --all-extras

# Ensure pristine state: reset any modified files and clean untracked files
RUN git reset --hard && git clean -fd

# Set dummy environment variables required for testing
ENV OPENAI_API_KEY=sk-test-dummy-key-for-testing
ENV SERPER_API_KEY=dummy-serper-api-key

# Configure shell environment
RUN echo 'export PATH="/root/.local/bin:$PATH"' >> /root/.bashrc && \
    echo 'export PATH="/testbed/.venv/bin:$PATH"' >> /root/.bashrc
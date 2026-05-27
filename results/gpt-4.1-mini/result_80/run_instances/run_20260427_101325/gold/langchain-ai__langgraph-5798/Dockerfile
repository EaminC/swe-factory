FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install essential system dependencies
RUN apt update && apt install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    locales \
    locales-all \
    tzdata \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Set /bin/bash as the default shell
SHELL ["/bin/bash", "-c"]

# Upgrade pip and install poetry only
RUN python3.10 -m pip install --upgrade pip \
    && python3.10 -m pip install poetry

# Create workdir and clone repo, checkout specific commit, verify pyproject.toml presence
WORKDIR /testbed/
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed/ \
    && git checkout 220314b53a960964a82657451b846f3a7cb2f348 \
    && ls -la /testbed/libs/langgraph/pyproject.toml

# Change working directory to where pyproject.toml is located for poetry install
WORKDIR /testbed/libs/langgraph

# Configure poetry to avoid creating virtualenvs and install dependencies excluding docs (no group 'docs')
RUN poetry config virtualenvs.create false \
    && poetry install --no-root

# Run uv sync to synchronize dependencies as per Makefile (uv tool installed by poetry)
RUN uv sync --frozen --group dev || true

# Install the package itself in development mode so local changes are reflected
RUN pip install -e .

# Reset working directory to /testbed
WORKDIR /testbed/
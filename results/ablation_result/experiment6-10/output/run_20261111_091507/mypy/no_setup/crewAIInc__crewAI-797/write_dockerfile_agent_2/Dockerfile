# Use a stable Ubuntu base image with bash support
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and tools required for building and running Python projects
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    locales \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set locale to avoid potential locale issues
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Poetry (dependency manager) latest stable as recommended by crewAI environment
RUN curl -sSL https://install.python-poetry.org | python3.11 -

# Add Poetry to PATH environment variable
ENV PATH="/root/.local/bin:$PATH"

# Create working directory and clone the repository
WORKDIR /testbed/

# Clone the specified repo and checkout the given commit (build arg REPO_SHA must be set at build)
ARG REPO_SHA=377f919d42724744908fa0bcca5cf76826685e07
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed && \
    cd /testbed && \
    git fetch --all && \
    git reset --hard ${REPO_SHA} && \
    git remote remove origin

# Clear Poetry cache to avoid stale or corrupted dependencies
RUN poetry cache clear --all pypi

# Install dependencies using Poetry excluding optional test and dev groups to avoid lancedb issues
RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi --without test,dev

# Install the package in editable mode to ensure local source is used
RUN pip install -e .

# Set environment variables placeholders for required API keys (to be provided at runtime)
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OPENAI_API_BASE=""
ENV OPENAI_MODEL_NAME=""

# Set bash as the default shell
CMD ["/bin/bash"]
# Use Ubuntu 22.04 as base image for stability and bash shell availability
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies except nodejs/npm for now
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.11 and pip3 to pip of python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
 && update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
 && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

# Install a current Node.js LTS (v20.x) from official NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Upgrade npm to latest stable after installing proper node version
RUN npm install -g npm@latest

# Install Poetry (dependency management)
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=/opt/poetry python3 - && \
    ln -s /opt/poetry/bin/poetry /usr/local/bin/poetry

# Set working directory
WORKDIR /testbed/

# Clone the repo and checkout specific commit (commit SHA is passed as build argument)
ARG COMMIT_SHA=667713f6c04fbc208fb7eefba70f101562070c9e

RUN git clone https://github.com/langflow-ai/langflow . && \
    git fetch --all && \
    git reset --hard ${COMMIT_SHA} && \
    git clean -fdx

# Install Python dependencies using Poetry (including dev dependencies for testing)
RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi

# Install frontend dependencies with npm inside src/frontend
RUN cd src/frontend && \
    npm install

# Install Playwright browsers required for frontend tests
RUN cd src/frontend && npx playwright install --with-deps

# Install pre-commit hooks (recommended by Makefile/notes)
RUN poetry run make init

# Fix permissions (optional) to avoid permission issues during testing
RUN chmod -R a+rwx /testbed

# Default shell environment is bash (already set)
ENV SHELL=/bin/bash

# Set working directory explicitly again for user clarity
WORKDIR /testbed/

# Note: Do NOT run tests here. Tests will be executed by the eval script in this environment.
# Use official Python slim image to avoid venv and permission issues
FROM --platform=linux/x86_64 python:3.10-slim
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies and tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    ca-certificates \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Upgrade pip, setuptools, and wheel globally
RUN python -m pip install --upgrade pip setuptools wheel

# Create working directory
WORKDIR /testbed/

# Clone the repository and checkout the specified commit
ARG COMMIT_SHA=2b8e056d5d4d14665b88a01c41356253c94b9259
RUN git clone https://github.com/AntonOsika/gpt-engineer /testbed/ && \
    git reset --hard $COMMIT_SHA && \
    chmod -R a+rwx /testbed/

# Install project and all required dependencies globally without duplicated packages from PyPI
# Install 'tiktoken' explicitly as it is missing and required for tests
RUN python -m pip install --no-cache-dir -e . && \
    python -m pip install --no-cache-dir \
    pytest pytest-cov pre-commit ruff mypy openai termcolor typer rudder-sdk-python dataclasses-json tabulate tiktoken

# Set bash as default shell
SHELL ["/bin/bash", "-c"]

# Set working directory explicitly
WORKDIR /testbed/

# Note: No tests or commands to run tests inside Dockerfile per instructions
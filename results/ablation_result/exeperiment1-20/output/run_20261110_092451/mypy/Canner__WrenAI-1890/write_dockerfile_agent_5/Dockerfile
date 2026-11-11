# Use ubuntu 22.04 as base image for stability and better ecosystem support
FROM ubuntu:22.04

# Use bash as default shell
SHELL ["/bin/bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies with python3.10 (default Ubuntu 22.04 version), venv, distutils, pip, and required tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    curl \
    locales \
    git \
    netcat-traditional \
    build-essential \
    ca-certificates \
    wget \
    bash-completion \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 - \
    && rm -rf /var/lib/apt/lists/*

# Setup UTF-8 locale correctly
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Set python3.10 as default python and pip
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
 && update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip 1

# Install Poetry 1.8.3 via official installer
ENV POETRY_VERSION=1.8.3
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=/opt/poetry python3.10 - --version $POETRY_VERSION \
    && ln -s /opt/poetry/bin/poetry /usr/local/bin/poetry

# Set working directory
WORKDIR /testbed

# Clone the repository and checkout the specific commit with explicit error handling and confirmation of pyproject.toml presence
ARG REPO=https://github.com/Canner/WrenAI.git
ARG COMMIT_SHA=9b589c65fed699a48d1c93fe74c9e57bc361b70d

RUN git clone --depth 1 --branch master $REPO . \
 && git reset --hard $COMMIT_SHA \
 && test -f pyproject.toml

# Configure Poetry to create virtualenvs inside the project folder
RUN poetry config virtualenvs.in-project true

# Install dependencies excluding dev, eval, test groups as per context information
RUN poetry install --no-interaction --no-ansi --without dev --without eval --without test

# Install package in development mode to ensure local source usage
RUN poetry run pip install -e .

# Enable auto-activation of poetry virtualenv in bash
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Default environment variable for unbuffered Python stdout/stderr
ENV PYTHONUNBUFFERED=1

# Install just 1.36.0 for task commands
RUN curl -Ls https://github.com/casey/just/releases/download/1.36.0/just-1.36.0-x86_64-unknown-linux-gnu.tar.gz | tar xz -C /usr/local/bin just

# Final working directory set
WORKDIR /testbed
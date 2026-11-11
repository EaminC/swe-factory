# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# System dependencies installation. Installs essential tools and libraries required for development and runtime (Required)
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    libffi-dev \
    libssl-dev \
    locales \
    locales-all \
    tzdata \
    unzip \
    # python3.11 dependencies
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3.11-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install pip for python3.11 explicitly (sometimes python3-pip points to python3.10)
RUN python3.11 -m ensurepip --upgrade \
    && python3.11 -m pip install --upgrade pip setuptools wheel

# Install Poetry (dependency management tool)
RUN curl -sSL https://install.python-poetry.org | python3.11 -

ENV PATH="/root/.local/bin:$PATH"

# Set work directory
WORKDIR /testbed/

# Clone target repository and checkout specific commit SHA
ARG REPO=https://github.com/crewAIInc/crewAI.git
ARG COMMIT_SHA=9e9b945a4662e6cea9f6ca621cac3224a3119622

RUN git clone ${REPO} . \
    && git reset --hard ${COMMIT_SHA}

# Install dependencies and project in editable mode using Poetry
RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi --without dev

# Install the project itself in editable mode to ensure tests run against the local sources
RUN python3.11 -m pip install -e .

# Set environment variables placeholder (user/deployment may override these, not setting actual keys here)
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""

# Make sure bashrc activates needed env variables or PATH, if needed (here no virtualenv created by Poetry)
RUN echo "export PATH=$PATH" >> /root/.bashrc

# Working directory is /testbed, location of cloned code
WORKDIR /testbed/
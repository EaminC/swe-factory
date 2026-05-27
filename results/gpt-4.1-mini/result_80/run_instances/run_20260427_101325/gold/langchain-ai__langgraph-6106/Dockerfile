FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, curl, wget, build-essential, python3.10 with venv, distutils, pip, setuptools, wheel, locales, tzdata, bash
RUN apt-get update && apt-get install -y \
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
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install poetry
RUN python3.10 -m pip install --upgrade pip \
    && python3.10 -m pip install poetry

# Create working directory and clone the repo, checkout specific commit, verify pyproject.toml in libs/langgraph
WORKDIR /testbed/
ARG COMMIT_SHA=6fc5b3aeda2aaa89277c79dc3682e7c723e2abb6
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed/ \
    && cd /testbed && git checkout ${COMMIT_SHA} \
    && ls -la libs/langgraph/pyproject.toml

# Change working directory to libs/langgraph for poetry install
WORKDIR /testbed/libs/langgraph

# Configure poetry to create virtualenv and install dependencies (no docs group as none defined)
RUN poetry config virtualenvs.create true \
    && poetry install --no-root

# Install the package itself in development mode so local changes are reflected
RUN pip install -e .

# Reset working directory to /testbed/
WORKDIR /testbed/

# Set default shell to bash
ENV SHELL=/bin/bash
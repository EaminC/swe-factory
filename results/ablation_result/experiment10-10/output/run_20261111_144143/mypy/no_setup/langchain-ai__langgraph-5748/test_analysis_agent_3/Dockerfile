# Use Ubuntu 22.04 base image with bash available
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install essential system packages: git, curl, build tools, python3.10, and required libs
RUN apt update && apt install -y \
    git \
    curl \
    build-essential \
    wget \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set python3 to point to python3.10 explicitly
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Install Poetry (dependency manager) - recommended script method
RUN curl -sSL https://install.python-poetry.org | python3 -

# Add Poetry to PATH for all users
ENV PATH="/root/.local/bin:$PATH"

# Create working directory for the repo
WORKDIR /testbed/

# Clone the repo and checkout the specific commit
ARG REPO=https://github.com/langchain-ai/langgraph.git
ARG COMMIT_SHA=18887e9f86a6d8675a2b4aed03a1c190ef6e1581

RUN /bin/bash -c "\
    git clone $REPO /testbed && \
    cd /testbed && \
    git checkout $COMMIT_SHA && \
    chmod -R a+rw /testbed"

# Install Python dependencies via Poetry inside the libs/prebuilt directory
# Use `poetry install --no-root` because the project does not have a package configured for install
# Do NOT run `pip install -e .` to avoid conflicts and errors reported
RUN /bin/bash -c "\
    cd libs/prebuilt && \
    poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi --no-root"

# Set default shell to /bin/bash
SHELL ["/bin/bash", "-c"]

# Environment variables used in tests if needed
ENV LANGGRAPH_TEST_FAST=1

# Default workdir as requested
WORKDIR /testbed/
# Use Ubuntu 22.04 as base image with bash shell support
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, curl, build tools, python3.10, nodejs, npm, poetry dependencies etc.
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    wget \
    locales \
    locales-all \
    tzdata \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Configure locale to UTF-8 (some python packages require a proper locale)
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Poetry 1.8.2 specifically to match CI environment (using official installer)
RUN curl -sSL https://install.python-poetry.org | python3.10 - --version 1.8.2
ENV PATH="/root/.local/bin:$PATH"

# Install Node.js 20.x (to ensure compatibility with latest npm)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    # Do NOT upgrade npm globally to avoid version incompatibility issues
    rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /testbed/

# Clone repo, checkout to target commit, install dependencies and development mode installs.
# Use poetry to install python deps, install node dependencies with npm in frontend.
RUN git clone https://github.com/langflow-ai/langflow.git /testbed && \
    git reset --hard 667713f6c04fbc208fb7eefba70f101562070c9e && \
    git remote remove origin && \
    \
    # Setup Python environment with venv
    python3.10 -m venv /opt/testbed-venv && \
    source /opt/testbed-venv/bin/activate && \
    # Upgrade pip and install poetry to the venv to isolate it
    pip install --upgrade pip && \
    pip install poetry==1.8.2 && \
    \
    # Install python dependencies using poetry
    poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi && \
    \
    # Development mode install of python package to reflect source code changes
    pip install -e . && \
    \
    # Frontend setup: install npm dependencies
    cd src/frontend && \
    npm install && \
    \
    # Development mode linking for frontend package is not described; assume normal npm install suffices
    cd /testbed

# Set default shell to bash
ENV SHELL=/bin/bash

# Add the python venv to PATH
ENV PATH="/opt/testbed-venv/bin:$PATH"

# Inform that the shell will activate the venv by default in interactive shells
RUN echo "source /opt/testbed-venv/bin/activate" >> /root/.bashrc
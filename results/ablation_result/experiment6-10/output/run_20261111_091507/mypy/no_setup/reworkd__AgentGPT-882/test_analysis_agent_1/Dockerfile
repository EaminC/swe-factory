# Use Ubuntu 22.04 base image for stability and bash availability
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system utilities, git, curl, python, nodejs, npm, mysql client, and build tools
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    mysql-client \
    nodejs \
    npm \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set PYTHON to python3.10 explicitly
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1
RUN update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Install Poetry globally using the recommended install script
RUN curl -sSL https://install.python-poetry.org | python3 -

ENV PATH="/root/.local/bin:$PATH"

# Create working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit SHA
ARG REPO_URL=https://github.com/reworkd/AgentGPT.git
ARG COMMIT_SHA=ed41e877e1c493a7aec13312a8284b209b67495b

RUN git clone $REPO_URL . && \
    git checkout $COMMIT_SHA && \
    chmod -R 777 /testbed/

# Install Python dependencies using Poetry in a virtual environment 'testbed'
# Configure Poetry to create virtualenvs inside the project directory for isolation
RUN poetry config virtualenvs.in-project true && \
    poetry install --no-root --no-interaction --no-ansi

# Install the local project package in editable mode using Poetry
RUN poetry install --no-interaction --no-ansi

# Install Node.js dependencies if package.json is present
# This repo mandates Node.js 18+, the installed Node might be older, upgrade Node.js 18+ via NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    if [ -f package.json ]; then npm install; fi

# Link the Node.js package globally if applicable (npm link) - to reflect local source
RUN if [ -f package.json ]; then npm link; fi

# Export bash command to activate Poetry environment by default on container start
RUN echo 'source /root/.bashrc && source /testbed/.venv/bin/activate' >> /root/.bashrc

# Set WORKDIR to /testbed
WORKDIR /testbed/
# Use Ubuntu 22.04 base image for stability and bash availability
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system utilities, git, curl, python, nodejs, npm, mysql client, mysql dev libraries, and build tools
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
    default-libmysqlclient-dev \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set PYTHON to python3.10 explicitly
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
 && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Install Node.js 18.x from NodeSource for correct version
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
 && apt-get install -y nodejs

# Install Poetry globally using the recommended install script
RUN curl -sSL https://install.python-poetry.org | python3 -

ENV PATH="/root/.local/bin:$PATH"

# Create working directory
WORKDIR /testbed/

ARG REPO_URL=https://github.com/reworkd/AgentGPT.git
ARG COMMIT_SHA=ed41e877e1c493a7aec13312a8284b209b67495b

# Clone repo and checkout the specified commit
RUN git clone $REPO_URL . \
 && git checkout $COMMIT_SHA \
 && chmod -R 777 /testbed/

# Add debug step to verify pyproject.toml presence in platform directory and repo root
RUN ls -l /testbed/ && ls -l /testbed/platform/

# Configure Poetry to create virtualenvs inside the project directory
RUN poetry config virtualenvs.in-project true

# Install dependencies from platform directory (where pyproject.toml is located)
WORKDIR /testbed/platform/
RUN poetry install --no-interaction --no-ansi

# Install the local project package in editable mode
RUN poetry install --no-root --no-interaction --no-ansi

# Back to root workdir
WORKDIR /testbed/

# Install Node.js dependencies if package.json present at root (or adapt if elsewhere)
RUN if [ -f package.json ]; then npm install; fi

# If package.json at /testbed/platform/, install there as well (depending on project setup)
RUN if [ -f platform/package.json ]; then cd platform && npm install; fi

# Link local Node package if package.json present (npm link for local dev mode)
RUN if [ -f package.json ]; then npm link; fi
RUN if [ -f platform/package.json ]; then cd platform && npm link; fi

# Add bashrc updates to activate poetry env by default on container start
RUN echo 'source /root/.bashrc && source /testbed/platform/.venv/bin/activate' >> /root/.bashrc

# Final working directory set to /testbed
WORKDIR /testbed/
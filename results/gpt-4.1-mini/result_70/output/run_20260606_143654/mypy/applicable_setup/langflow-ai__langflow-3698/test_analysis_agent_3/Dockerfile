# Use Ubuntu 22.04 base image with bash shell support for a stable environment
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system essentials and dependencies: git, curl, wget, build tools, Python 3.11 and related packages,
# locales, timezone data, gnupg and software-properties-common for adding repos
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    python3-setuptools \
    ca-certificates \
    locales \
    tzdata \
    gnupg \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Configure locale to UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Node.js 20.x LTS via NodeSource to ensure compatibility with latest npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    rm -rf /var/lib/apt/lists/*

# Install Poetry 1.6.1 as specified via official install script
RUN curl -sSL https://install.python-poetry.org | python3 - --version 1.6.1

# Add Poetry to PATH to be available in sessions
ENV PATH="/root/.local/bin:$PATH"

# Set working directory
WORKDIR /testbed/

# Clone repository and checkout the exact commit SHA
ARG REPO=https://github.com/langflow-ai/langflow.git
ARG COMMIT_SHA=a4dc5381b2cf31c507cc32f9027f76bf00d61ccc

RUN git clone $REPO /testbed && \
    cd /testbed && \
    git checkout $COMMIT_SHA && \
    git submodule update --init --recursive && \
    chmod -R a+rwx /testbed

# Create Python virtual environment, install dependencies via Poetry, and install project in editable mode
RUN python3.11 -m venv /testbed/.venv && \
    source /testbed/.venv/bin/activate && \
    python -m pip install --upgrade pip setuptools wheel && \
    poetry config virtualenvs.in-project true && \
    poetry install --no-root --no-interaction --no-ansi && \
    poetry install --with dev --no-interaction --no-ansi && \
    pip install -e . && \
    # Install Node.js dependencies only if package.json exists
    if [ -f package.json ]; then npm install; fi

# Persist environment activation and Poetry path for interactive shells
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc && \
    echo "export PATH=/root/.local/bin:\$PATH" >> /root/.bashrc

# Ensure default shell is bash for all commands and interactive use
ENV SHELL=/bin/bash
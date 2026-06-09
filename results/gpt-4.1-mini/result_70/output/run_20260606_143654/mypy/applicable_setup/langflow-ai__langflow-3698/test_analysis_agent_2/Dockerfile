# Use a Ubuntu base image with bash shell support and stable package manager behavior
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system essentials and dependencies: git, curl, wget, software-properties-common for adding repos,
# build-essential, python3, python3-venv, python3-pip, nodejs, npm, and other utilities
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

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Node.js 20.x (LTS current) via NodeSource to match npm compatibility requirements
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    rm -rf /var/lib/apt/lists/*

# Install Poetry >=1.4 using official recommended install script
RUN curl -sSL https://install.python-poetry.org | python3 - --version 1.6.1

# Add Poetry to PATH
ENV PATH="/root/.local/bin:$PATH"

# Create working directory
WORKDIR /testbed/

# Clone the repo and checkout specific commit
ARG REPO=https://github.com/langflow-ai/langflow.git
ARG COMMIT_SHA=a4dc5381b2cf31c507cc32f9027f76bf00d61ccc

RUN git clone $REPO /testbed && \
    cd /testbed && \
    git checkout $COMMIT_SHA && \
    git submodule update --init --recursive && \
    chmod -R a+rwx /testbed

# Install Python dependencies using Poetry inside a virtual environment "testbed" as recommended
RUN python3.11 -m venv /testbed/.venv && \
    source /testbed/.venv/bin/activate && \
    python -m pip install --upgrade pip setuptools wheel && \
    poetry config virtualenvs.in-project true && \
    poetry install --no-root --no-interaction --no-ansi && \
    poetry install --with dev --no-interaction --no-ansi && \
    pip install -e . && \
    # Install Node.js dependencies if package.json exists
    if [ -f package.json ]; then npm install; fi

# Write an environment activation script for convenience, enabling virtual environment and Poetry in bash
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc && \
    echo "export PATH=/root/.local/bin:\$PATH" >> /root/.bashrc

# Set default shell to bash for all RUN commands and interactive shell
ENV SHELL=/bin/bash
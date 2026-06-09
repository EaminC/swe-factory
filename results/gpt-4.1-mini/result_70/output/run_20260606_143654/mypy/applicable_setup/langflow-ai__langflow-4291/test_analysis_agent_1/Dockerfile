# Base image with bash, suitable for Python environment and node setup
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies required for building, git, python 3.10, pip, curl, node, npm, and build essentials
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    npm \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Setup alternatives to use python3.10 and pip3 as default python and pip
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    python3 -m pip install --upgrade pip setuptools wheel && \
    npm install -g npm@latest

# Set working directory
WORKDIR /testbed/

# Clone the target repository and checkout the specific commit
RUN git clone https://github.com/langflow-ai/langflow.git /testbed && \
    git reset --hard 3131c0ce083e157f5188cea833592c6cf4aad9d2

# Install pipx for uv tool installation (uv is required and installed via pipx)
RUN python3 -m pip install pipx && \
    python3 -m pipx ensurepath

# Install Poetry (pinned in context: Poetry 1.8.2 is used in CI)
RUN curl -sSL https://install.python-poetry.org | python3 - --version 1.8.2 && \
    ln -s /root/.local/bin/poetry /usr/local/bin/poetry

# Install frontend node version 21 compatible with the repo (npm installed above)
# Confirm Node.js version 21 is installed via NodeSource or n (alternative method)
RUN curl -fsSL https://deb.nodesource.com/setup_21.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# Install project dependencies via make init (runs poetry install and npm install/build etc)
# Use bash because makefile requires bash shell
RUN /bin/bash -c "poetry config virtualenvs.in-project true && \
    poetry install --no-interaction --no-ansi && \
    make init"

# Make sure uv tool is installed into pipx environment and available in PATH
ENV PATH="/root/.local/bin:$PATH"

# Bashrc setup for poetry virtual environment activation convenience (optional)
RUN echo "source ~/.bashrc" >> /root/.bashrc

# Set default shell to bash for runtime and scripts
ENV SHELL=/bin/bash
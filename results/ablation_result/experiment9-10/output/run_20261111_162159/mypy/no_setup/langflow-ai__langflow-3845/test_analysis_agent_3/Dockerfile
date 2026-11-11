# Use Ubuntu 22.04 as base image for stability and bash compatibility
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV SHELL=/bin/bash

# Install essential system dependencies, including git, curl, python3.11, build tools, nodejs, and locale setup
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    python3.11-dev \
    locales \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Setup locales to avoid locale warnings
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Poetry >=1.4 via official install script for dependency management
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=/opt/poetry python3.11 - && \
    ln -s /opt/poetry/bin/poetry /usr/local/bin/poetry

ENV PATH="/opt/poetry/bin:$PATH"

# Install Node.js 24 LTS from nodesource repository and upgrade npm
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    rm -rf /var/lib/apt/lists/*

# Set working directory inside container
WORKDIR /testbed/

# Clone the repository and checkout the specified commit SHA
ARG REPO_URL=https://github.com/langflow-ai/langflow.git
ARG REPO_COMMIT=bad009c0fab91dfdde20872995f65da9b551d994

RUN git clone ${REPO_URL} /testbed && \
    cd /testbed && \
    git reset --hard ${REPO_COMMIT} && \
    chmod -R a+rwx /testbed

# Create Python 3.11 virtual environment named 'testbed'
RUN python3.11 -m venv /testbed/testbed

# Install dependencies using Poetry without creating virtual environments to rely on above venv,
# then install the project in editable mode via pip from the cloned source,
# ensuring no pre-installed PyPI packages override local code.
RUN /bin/bash -c "\
    source /testbed/testbed/bin/activate && \
    poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi && \
    python -m pip install -e . \
"

# Configure bash to auto-activate the virtual environment when starting shells
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

# Use bash shell for subsequent commands
SHELL ["/bin/bash", "-c"]

# Default working directory
WORKDIR /testbed/
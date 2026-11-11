# Use Ubuntu 22.04 base with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies including git, curl, wget, build tools, Python 3.10, nodejs, npm
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3-distutils \
    python3-pip \
    nodejs \
    npm \
    locales \
    locales-all \
    tzdata \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 and pip point to python3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10

# Install bun globally with official installer
RUN curl -fsSL https://bun.sh/install | bash

# Add bun to PATH
ENV BUN_INSTALL="/root/.bun"
ENV PATH="$BUN_INSTALL/bin:$PATH"

# Install uv task runner globally with npm
RUN npm install -g uv

# Set work directory
WORKDIR /testbed/

# Clone the repository and checkout the specified commit
ARG COMMIT_SHA=0e4b1ffbc3a9d2ac3a4d0d381766b9d929e42dad
RUN git clone https://github.com/ValueCell-ai/valuecell.git . && \
    git reset --hard ${COMMIT_SHA} && git clean -fdx

# Copy example environment file (so user can override at runtime if needed)
RUN cp .env.example .env

# Setup python virtual environment named testbed using python3.10
RUN python3 -m venv /opt/testbed

# Activate venv and upgrade pip
RUN /bin/bash -c "source /opt/testbed/bin/activate && pip install --upgrade pip"

# Install python dependencies and project package itself in development mode via uv
RUN /bin/bash -c "source /opt/testbed/bin/activate && uv sync --locked --all-extras --dev"

# Install frontend dependencies with bun inside python folder
RUN /bin/bash -c "cd ./python && bun install"

# Initialize backend environment preparation script
RUN /bin/bash -c "source /opt/testbed/bin/activate && bash scripts/prepare_envs.sh"

# Initialize database schemas
RUN /bin/bash -c "source /opt/testbed/bin/activate && uv run valuecell/server/db/init_db.py"

# Auto activate virtual environment for interactive shell sessions
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Set default working directory explicitly for test execution clarity
WORKDIR /testbed/python/

# Default shell environment to bash
ENV SHELL=/bin/bash
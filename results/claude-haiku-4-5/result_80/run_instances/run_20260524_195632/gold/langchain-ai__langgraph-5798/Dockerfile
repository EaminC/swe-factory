# Base image specification. Defines the foundation OS and architecture for the container
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation. Installs essential tools and libraries required for development and runtime
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    libtiff-dev \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip \
    curl \
    locales \
    locales-all \
    tzdata \
    ca-certificates \
    pkg-config \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default python3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Upgrade pip and install UV package manager
RUN python3.11 -m pip install --upgrade pip setuptools wheel && \
    python3.11 -m pip install uv

# Set default workdir to testbed
WORKDIR /testbed/

# Target Project setup. Clones source code, checkouts to the target version
RUN git clone https://github.com/langchain-ai/langgraph /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard 220314b53a960964a82657451b846f3a7cb2f348 && \
    git remote remove origin

# Set up environment to use the virtual environment by default
ENV VIRTUAL_ENV=/testbed/.venv
ENV PATH="/testbed/.venv/bin:$PATH"

# Create a virtual environment and install all dependencies in one RUN command
# Install monorepo packages first, then core dependencies, then dev dependencies, finally langgraph itself
RUN /bin/bash -c " \
    set -e && \
    python3.11 -m uv venv /testbed/.venv --python python3.11 && \
    . /testbed/.venv/bin/activate && \
    uv pip install 'langchain-core>=0.1' && \
    uv pip install -e /testbed/libs/checkpoint && \
    uv pip install -e /testbed/libs/checkpoint-sqlite && \
    uv pip install -e /testbed/libs/checkpoint-postgres && \
    uv pip install -e /testbed/libs/prebuilt && \
    uv pip install -e /testbed/libs/sdk-py && \
    uv pip install -e /testbed/libs/cli && \
    uv pip install \
    'xxhash>=3.5.0' \
    'pydantic>=2.7.4' \
    'pytest' \
    'pytest-cov' \
    'pytest-dotenv' \
    'pytest-mock' \
    'syrupy' \
    'httpx' \
    'pytest-watcher' \
    'mypy' \
    'ruff' \
    'jupyter' \
    'pytest-xdist[psutil]' \
    'pytest-repeat' \
    'psycopg[binary]' \
    'uvloop==0.21.0b1' \
    'pyperf' \
    'py-spy' \
    'types-requests' \
    'pycryptodome' \
    'pytest-anyio' && \
    uv pip install -e /testbed/libs/langgraph && \
    echo 'Installation completed successfully' \
    "

# Configure shell to activate venv on startup
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]
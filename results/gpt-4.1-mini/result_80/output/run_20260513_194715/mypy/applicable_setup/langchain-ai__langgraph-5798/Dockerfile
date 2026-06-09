# Base image specification, using Ubuntu 22.04 with bash and Python 3.10 support
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies for Python development, git, curl, bash, and build tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Setup python3 pointing to python3.10 explicitly
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Upgrade pip, setuptools, wheel
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install 'uv' environment management tool as required by the project
RUN python3 -m pip install uv

# Set workdir to /testbed
WORKDIR /testbed/

# Clone the repository and checkout the specified commit SHA
ARG COMMIT_SHA=220314b53a960964a82657451b846f3a7cb2f348
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed && \
    cd /testbed && \
    git reset --hard ${COMMIT_SHA} && \
    git remote remove origin

# Set environment variables so that uv commands run correctly
ENV UV_VENV_DIR=/testbed/.venv

# Create and activate virtual environment using uv and install dependencies
# Use uv sync --frozen --group dev in the libs/langgraph directory to install all dependencies including the langgraph package itself,
# respecting the project's build system and dev dependencies as defined in pyproject.toml (using hatchling)
RUN /bin/bash -c "\
    uv venv && \
    source /testbed/.venv/bin/activate && \
    cd /testbed/libs/langgraph && \
    uv sync --frozen --group dev"

# Ensure that the virtual environment is activated automatically in interactive bash sessions
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Final working directory as required
WORKDIR /testbed/
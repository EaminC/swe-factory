# Use Ubuntu 22.04 LTS base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies including libpq-dev for psycopg support,
# along with git, curl, wget, build-essential, python3.10 and related tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libpq-dev \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry latest version using official install script
RUN curl -sSL https://install.python-poetry.org | python3.10 -

# Add poetry to PATH
ENV PATH="/root/.local/bin:${PATH}"

# Install 'uv' tool globally via pip (uv is used in Makefile for venv and pip management)
RUN python3.10 -m pip install --upgrade pip setuptools wheel uv

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout specific commit SHA
ARG COMMIT_SHA=18887e9f86a6d8675a2b4aed03a1c190ef6e1581
RUN git clone https://github.com/langchain-ai/langgraph.git . && \
    git reset --hard ${COMMIT_SHA}

# Run make install; this will use 'uv' to create and manage the virtual environment, install dependencies
RUN make install

# Install the langgraph package in development mode to ensure tests run against local code
RUN uv pip install -e libs/langgraph

# Add poetry bin to bashrc for interactive usage (optional, for docs environment)
RUN echo 'export PATH="/root/.local/bin:$PATH"' >> /root/.bashrc

# Set default shell to bash and default working directory
ENV SHELL=/bin/bash
WORKDIR /testbed/

# Notes:
# - Do not run tests inside the Dockerfile.
# - Poetry is only for docs and is not used for main package dependencies here.
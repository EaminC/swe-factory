# Use a stable Ubuntu base image with bash and updated packages
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install required system dependencies for development, Python 3.11, libpq-dev (needed by psycopg), and Docker CLI and docker-compose
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    curl \
    ca-certificates \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    python3.11-dev \
    libpq-dev \
    locales \
    tzdata \
    apt-transport-https \
    software-properties-common \
    lsb-release \
    gnupg-agent \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI and docker-compose plugin
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Upgrade pip, setuptools, wheel to latest versions
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install 'uv' for dependency management (using pip installed latest version)
RUN python3 -m pip install uv

# Set working directory
WORKDIR /testbed/

# Accept commit SHA as build argument, default to target commit
ARG COMMIT_SHA=69dd20e523c4c392d751034384afab275dcf305f

# Clone the repository, fetch, and checkout specific commit securely
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed/ && \
    cd /testbed && \
    git fetch origin $COMMIT_SHA --depth=1 && \
    git checkout $COMMIT_SHA && \
    chmod -R 777 /testbed

# Create a python virtual environment inside /testbed/testbed
RUN python3 -m venv /testbed/testbed

# Activate the venv and install all dependencies using uv from the libs/langgraph directory
# Install development group and install editable local libs/langgraph package to ensure local source usage
# Explicitly install psycopg[binary] to ensure availability
RUN /bin/bash -c "source /testbed/testbed/bin/activate && \
    cd libs/langgraph && \
    uv sync --frozen --group dev && \
    uv pip install -e . && \
    pip install psycopg[binary]"

# Add activation of virtual environment to root's bashrc for interactive convenience
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

# Add virtual environment's bin directory to PATH by default
ENV PATH="/testbed/testbed/bin:$PATH"

# Set working directory explicitly for test execution or interactive use
WORKDIR /testbed

# Note: To enable Docker commands inside container, the host's Docker daemon socket must be mounted at runtime:
# docker run -v /var/run/docker.sock:/var/run/docker.sock ...
# This cannot be done in Dockerfile, and must be handled externally.

# No ENTRYPOINT or CMD to keep the container neutral for later test execution
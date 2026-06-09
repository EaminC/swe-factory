# Base image specification - Ubuntu 22.04 as stable base with bash support and recent lib support
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies including git, curl, build essentials, python3.10+, nodejs 22.12 LTS, npm 10.9 and uv python package manager dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    curl \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    ca-certificates \
    locales \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Set up locales to avoid locale related warnings
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install Node.js 22.12 LTS and npm 10.9 from official NodeSource setup script
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@10.9.0 && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip and install uv python package manager globally
RUN python3.10 -m pip install --upgrade pip setuptools wheel
RUN python3.10 -m pip install uv>=0.4

# Create working directory for the repo
WORKDIR /testbed/

# Clone the repository and checkout the specific commit SHA (to be injected by build args)
ARG REPO=https://github.com/langflow-ai/langflow.git
ARG COMMIT_SHA=4ef4c93baccf30fc18936941ec9110b5f2fc2a59

RUN git clone $REPO . && \
    git reset --hard $COMMIT_SHA && \
    # Remove origin to break git link for reproducibility
    git remote remove origin

# Install python dependencies and build project using make init (which installs deps and builds)
# Use python3.10 venv to isolate environment
RUN python3.10 -m venv /testbed/testbed_venv && \
    source /testbed/testbed_venv/bin/activate && \
    pip install --upgrade pip && \
    # Install poetry or rely on make init installing dependencies as designed
    make init

# Install the project in development mode to ensure local code is used
RUN source /testbed/testbed_venv/bin/activate && \
    pip install -e .

# Ensure bash starts in the virtual environment by default when entering container
RUN echo "source /testbed/testbed_venv/bin/activate" >> /root/.bashrc
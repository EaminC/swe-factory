# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# System dependencies installation. Installs essential tools and libraries required for development and runtime (Required)
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    curl \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN python3.11 -m pip install --upgrade pip

# Install UV (UV dependency manager)
RUN python3.11 -m pip install uv

# Create working directory
WORKDIR /testbed/

# Clone target repository and checkout specific commit
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed \
    && cd /testbed \
    && git reset --hard 3878daffd68d14ee0379d11c19bef63c4dc02edc

# Clean previous build artifacts and ensure no virtual environment directory inside /testbed that can pollute build
RUN rm -rf /testbed/dist /testbed/build /testbed/*.egg-info

# Create Python virtual environment outside of /testbed to avoid inclusion in source distribution
RUN python3.11 -m venv /venv_testbed

# Activate venv and install dependencies with uv commands, build project isolated from venv directory
RUN source /venv_testbed/bin/activate \
    && cd /testbed \
    && uv lock \
    && uv sync \
    && uv build \
    && uv venv \
    && pip install dist/*.tar.gz \
    && pip install -e . \
    && pip install 'crewai[tools]'

# Ensure venv activation on login shells
RUN echo "source /venv_testbed/bin/activate" >> /root/.bashrc

# Set working directory and PATH env variable for runtime
WORKDIR /testbed
ENV PATH="/venv_testbed/bin:$PATH"

# Note: Testing commands or ENTRYPOINT not included per requirements
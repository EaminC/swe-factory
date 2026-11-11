# Base image specification. Ubuntu 22.04 with bash
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Update and install system dependencies including python3.10 and related packages (Ubuntu 22.04 default)
RUN apt update && \
    apt install -y \
    git \
    curl \
    build-essential \
    locales \
    locales-all \
    tzdata \
    ca-certificates \
    wget \
    python3 \
    python3-venv \
    python3-dev \
    python3-distutils \
    python3-pip \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit SHA (passed during build)
ARG COMMIT_SHA=ca4141564f86dd1b7dee3082959042dc05d5d471
RUN git clone https://github.com/Aider-AI/aider.git . &&\
    git reset --hard $COMMIT_SHA &&\
    git remote remove origin

# Create and activate virtual environment, upgrade pip inside it and install dependencies and project in editable mode
RUN python3 -m venv ./testbed-venv && \
    source ./testbed-venv/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt && \
    pip install -r requirements/requirements-dev.txt && \
    pip install -e .

# Add virtualenv activation to bashrc for convenience
RUN echo "source /testbed/testbed-venv/bin/activate" >> /root/.bashrc

# Default workdir and shell are already set
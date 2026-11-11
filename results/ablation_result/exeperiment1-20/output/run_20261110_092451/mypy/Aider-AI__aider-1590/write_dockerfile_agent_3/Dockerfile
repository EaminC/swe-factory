# Base image with bash and standard tools
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies essential for building and running Python projects, git for cloning, and wget for downloading
# Use python3.10 and matching venv and distutils packages available in Ubuntu 22.04 official repos
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3-distutils \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and ensure pip corresponds to python3.10
RUN python3.10 -m pip install --upgrade pip setuptools wheel

# Set working directory to /testbed
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/Aider-AI/aider.git /testbed && \
    git checkout ca4141564f86dd1b7dee3082959042dc05d5d471 && \
    git remote remove origin

# Create a Python virtual environment named testbed and activate it
RUN python3.10 -m venv /testbed/testbed-venv

# Install dependencies inside the virtual environment
RUN source /testbed/testbed-venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip install -e .

# Update bashrc to activate venv by default in container interactive shell sessions
RUN echo "source /testbed/testbed-venv/bin/activate" >> /root/.bashrc
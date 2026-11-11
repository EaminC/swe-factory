# Base image with bash and standard tools
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Add deadsnakes PPA to get Python 3.12 packages because Ubuntu 22.04 does not include python3.12 by default
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3.12 \
    python3.12-venv \
    python3.12-distutils \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip for python3.12 and ensure it's used
RUN python3.12 -m pip install --upgrade pip setuptools wheel

# Set working directory to /testbed
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/Aider-AI/aider.git /testbed && \
    git checkout ca4141564f86dd1b7dee3082959042dc05d5d471 && \
    git remote remove origin

# Create a Python virtual environment named testbed and activate it
RUN python3.12 -m venv /testbed/testbed-venv

# Install dependencies inside the virtual environment
RUN source /testbed/testbed-venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip install -e .

# Update bashrc to activate venv by default in container interactive shell sessions
RUN echo "source /testbed/testbed-venv/bin/activate" >> /root/.bashrc
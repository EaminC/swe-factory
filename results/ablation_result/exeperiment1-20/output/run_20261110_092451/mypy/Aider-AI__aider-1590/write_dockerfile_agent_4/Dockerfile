# Base image with bash and standard tools
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install dependencies for adding PPA and general tools
RUN apt-get update && apt-get install -y software-properties-common

# Add deadsnakes PPA for Python 3.11
RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update

# Install Python 3.11, venv, distutils, pip and other essentials
RUN apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3-distutils \
    python3-pip \
    git \
    wget \
    curl \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip for Python 3.11
RUN python3.11 -m pip install --upgrade pip setuptools wheel

# Set working directory to /testbed
WORKDIR /testbed/

# Clone repo and checkout to specified commit SHA
RUN git clone https://github.com/Aider-AI/aider.git /testbed && \
    git checkout ca4141564f86dd1b7dee3082959042dc05d5d471 && \
    git remote remove origin

# Create Python 3.11 virtual environment
RUN python3.11 -m venv /testbed/testbed-venv

# Install dependencies inside the virtual environment
RUN source /testbed/testbed-venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip install -e .

# Add virtual environment activation to bashrc for interactive shell sessions
RUN echo "source /testbed/testbed-venv/bin/activate" >> /root/.bashrc
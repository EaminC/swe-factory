# Use official Python 3.12 slim image to ensure Python 3.12 availability without relying on unreleased Ubuntu versions
FROM --platform=linux/x86_64 python:3.12-slim
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies for compilation, git, and common tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout specific commit
RUN git clone https://github.com/Aider-AI/aider.git /testbed && \
    git checkout ca4141564f86dd1b7dee3082959042dc05d5d471 && \
    git remote remove origin

# Create and activate Python virtual environment
RUN python3 -m venv /testbed/testbed-venv

# Upgrade pip and install project dependencies inside the virtual environment
RUN /bin/bash -c "source /testbed/testbed-venv/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt && \
    pip install -e ."

# Add virtual environment activation to bashrc for interactive shell sessions
RUN echo "source /testbed/testbed-venv/bin/activate" >> /root/.bashrc
# Use official Python 3.11 slim image as base to avoid PPA issues and reduce complexity
FROM --platform=linux/x86_64 python:3.11-slim
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies for build, git and tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory to /testbed
WORKDIR /testbed/

# Clone the repository and checkout specific commit
RUN git clone https://github.com/Aider-AI/aider.git /testbed && \
    git checkout ca4141564f86dd1b7dee3082959042dc05d5d471 && \
    git remote remove origin

# Create and activate python virtual environment
RUN python3 -m venv /testbed/testbed-venv

# Upgrade pip and install dependencies inside the virtual environment
RUN /bin/bash -c "source /testbed/testbed-venv/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt && \
    pip install -e ."

# Add virtual environment activation to bashrc for interactive shell sessions
RUN echo "source /testbed/testbed-venv/bin/activate" >> /root/.bashrc
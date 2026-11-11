FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PYTHONUNBUFFERED=1
SHELL ["/bin/bash", "-c"]

# Install system dependencies with python3.10 (default in Ubuntu 22.04) and generic package names for venv and distutils
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3 \
    python3-venv \
    python3-distutils \
    python3-pip \
    locales \
    tzdata \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN python3 -m pip install --upgrade pip setuptools wheel

# Create testbed directory and set workdir
WORKDIR /testbed/

# Clone the repository and checkout specific commit (passed as build arg)
ARG COMMIT_SHA=384f5ee08b6defef2adfb22274283e8bd0ef4314
RUN git clone https://github.com/FoundationAgents/MetaGPT.git . \
 && git checkout ${COMMIT_SHA}

# Install dependencies from requirements.txt with fixed valid lancedb version and then install repo editable.
# This bypasses the pinned incompatible lancedb==0.1.16 from requirements.txt by editing it temporarily.
RUN python3 -m venv /opt/testbed \
 && source /opt/testbed/bin/activate \
 && pip install --upgrade pip setuptools wheel \
 && sed -i 's/lancedb==0.1.16/lancedb>=0.14.0/g' requirements.txt \
 && pip install -r requirements.txt \
 && pip install -e .

# Add virtualenv activation to bashrc for convenience
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

ENV PATH="/opt/testbed/bin:$PATH"

# Set working directory as final step
WORKDIR /testbed/
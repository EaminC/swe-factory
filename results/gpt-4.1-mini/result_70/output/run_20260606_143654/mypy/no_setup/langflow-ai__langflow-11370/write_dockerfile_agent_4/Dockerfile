# Use a stable Ubuntu base image with bash shell
FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies including git, curl, python3.10 and build essentials, nodejs and npm, and locales
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    nodejs \
    npm \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Ensure python points to python3.10
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# Upgrade pip and related utilities
RUN python -m pip install --upgrade pip setuptools wheel

# Install 'uv' CLI tool (as recommended in the README)
RUN pip install uv

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout specific commit (in separate steps)
ARG REPO=langflow-ai/langflow
ARG COMMIT_SHA=1529f56bf4fb392bb27ae65442b519f1eff744b7
RUN git clone https://github.com/${REPO}.git /testbed/
RUN cd /testbed/ && git reset --hard ${COMMIT_SHA} && git remote remove origin

# Install project in development mode without extras (since dev extra is not present in this version)
RUN cd /testbed/ && python -m pip install --no-cache-dir -e .

# Optional: add uv activation to bashrc for convenience
RUN echo 'source <(uv activate)' >> /root/.bashrc

# Set working directory for subsequent container commands
WORKDIR /testbed/
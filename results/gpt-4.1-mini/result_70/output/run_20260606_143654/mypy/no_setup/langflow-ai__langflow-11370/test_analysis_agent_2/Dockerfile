# Use a robust Ubuntu base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, curl, Python 3.10 and its packaging tools, Node.js, npm, and build essentials
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    npm \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Update alternatives so python points to python3.10
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# Upgrade pip
RUN python -m pip install --upgrade pip setuptools wheel

# Install 'uv' CLI as recommended by README (using pip) to follow recommendation 'uv pip install langflow -U'
RUN pip install uv

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specified commit SHA
ARG REPO=langflow-ai/langflow
ARG COMMIT_SHA=1529f56bf4fb392bb27ae65442b519f1eff744b7
RUN git clone https://github.com/${REPO}.git /testbed/ \
    && cd /testbed/ \
    && git reset --hard ${COMMIT_SHA} \
    && git remote remove origin

# Install the project in development mode along with main dependencies
# The pyproject.toml specifies 'langflow-base[complete]~=0.8.0' for main dependencies
# and dev dependencies including pytest. We'll install the project with dev dependencies using pip.
RUN python -m pip install .[dev]

# Expose bashrc customization to activate uv environment quickly (optional)
RUN echo 'source <(uv activate)' >> /root/.bashrc

# Set default shell to bash and workdir to /testbed as requested
WORKDIR /testbed/
# Use Ubuntu 22.04 base image ensuring bash shell availability and wide compatibility
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Update and install essential system packages, Python, git, curl, and build tools
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to latest stable version for Python 3.10
RUN python3.10 -m pip install --upgrade pip

# Clone the repository and checkout the fixed commit
RUN git clone https://github.com/AntonOsika/gpt-engineer /testbed

WORKDIR /testbed

RUN git reset --hard 2b8e056d5d4d14665b88a01c41356253c94b9259

# Create Python virtual environment named testbed
RUN python3.10 -m venv /testbed/testbed

# Activate virtual environment and install dependencies from pyproject.toml using pip inside editable mode
RUN /bin/bash -c "\
    source /testbed/testbed/bin/activate && \
    pip install --upgrade pip setuptools wheel poetry && \
    poetry export -f requirements.txt --without-hashes -o requirements.txt && \
    pip install -r requirements.txt && \
    pip install -e ."

# Expose environment variable placeholder for OPENAI_API_KEY (can be set at runtime)
ENV OPENAI_API_KEY=""

# Ensure bash is the default shell
SHELL ["/bin/bash", "-c"]

# Working directory is already set to /testbed
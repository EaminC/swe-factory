# Use Ubuntu 22.04 as base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies: git, curl, python3.10 and related tools, build essentials, and locales
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set python3 to point to python3.10 binary for convenience
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Upgrade pip, setuptools, and wheel
RUN python3 -m pip install --upgrade pip setuptools wheel

# Create virtual environment
RUN python3 -m venv /opt/testbed-env

ENV VIRTUAL_ENV=/opt/testbed-env
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Set working directory
WORKDIR /testbed

# Clone repository, checkout commit, and install dependencies in one layer to ensure files persist
RUN /bin/bash -c "\
    git clone https://github.com/agentscope-ai/agentscope /testbed && \
    cd /testbed && \
    git checkout f44b10fcf8d88b2be1cb4474598bf5875242d21d && \
    pip install --no-cache-dir -e .[dev] \
"

# Use bash as default shell
SHELL ["/bin/bash", "-c"]

# Enable virtual environment activation on container start for convenience
RUN echo "source /opt/testbed-env/bin/activate" >> /root/.bashrc
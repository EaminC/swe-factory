# Use Ubuntu 22.04 base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install essential system dependencies, Python 3.12, git, curl, and build tools
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    curl \
    ca-certificates \
    locales-all \
    python3.12 \
    python3.12-distutils \
    python3.12-venv \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.12 and install pip for python3.12
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3

# Set working directory to /testbed
WORKDIR /testbed/

# Clone the repository, checkout the specified commit, and set up the virtual environment and dependencies
ARG COMMIT_SHA=0fe5247d4c8aa9ceff28f65c6e7fc04b4ce53ec4

RUN git clone https://github.com/Aider-AI/aider.git /testbed/ && \
    cd /testbed && \
    git checkout ${COMMIT_SHA} && \
    python3 -m venv testbed && \
    /bin/bash -c "source testbed/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install -e . && \
    pip install -r requirements.txt && \
    pip install -r requirements/requirements-dev.txt"

# Add virtual environment activation to bashrc for convenience
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

# Use bash as default shell
SHELL ["/bin/bash", "-c"]
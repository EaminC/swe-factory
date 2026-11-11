# Base image specification. Use Ubuntu 22.04 for a stable, bash-enabled environment
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies including git, python3.10 and pip, build essentials, curl, locales
RUN apt-get update && apt-get install -y \
    git \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    curl \
    build-essential \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 command points to python3.10, and pip is up to date
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    python3 -m pip install --upgrade pip setuptools wheel

# Create and activate virtual environment "testbed"
RUN python3 -m venv /opt/testbed

# Upgrade pip inside virtual environment and install mandatory python dependencies for building and testing
RUN /bin/bash -c "source /opt/testbed/bin/activate && pip install --upgrade pip setuptools"

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the given commit SHA
# Then install the project in editable mode and install test dependencies
ARG COMMIT_SHA=ba00896c5673990923abd0e99dba147938871512
RUN git clone https://github.com/AntonOsika/gpt-engineer /testbed && \
    cd /testbed && \
    git reset --hard ${COMMIT_SHA} && \
    /bin/bash -c "source /opt/testbed/bin/activate && pip install -e . && pip install pytest pytest-cov"

# Make sure the virtual environment is activated by default in interactive shells
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

SHELL ["/bin/bash", "-c"]
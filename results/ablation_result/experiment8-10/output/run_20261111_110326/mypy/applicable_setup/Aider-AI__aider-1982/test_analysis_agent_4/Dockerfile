# Use Ubuntu 22.04 base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install prerequisites for adding PPAs, build tools, git and curl
RUN apt-get update && apt-get install -y \
    software-properties-common \
    build-essential \
    curl \
    git \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA and install Python 3.11 and necessary python packages
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set locales and timezone
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Use python3.11 explicitly for pip installs and venv creation
RUN python3.11 -m pip install --upgrade pip setuptools>=68 setuptools_scm[toml]>=8 wheel

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/Aider-AI/aider.git /testbed && \
    git reset --hard 0fe5247d4c8aa9ceff28f65c6e7fc04b4ce53ec4

# Setup Python virtual environment using Python 3.11
RUN python3.11 -m venv /testbed/venv

# Install repository dependencies inside virtual environment:
# - Install pinned dependencies from requirements.txt (including litellm==1.47.0)
# - Install pinned dev dependencies from requirements/requirements-dev.txt
# - Install the repository itself in editable mode (-e .)
RUN /bin/bash -c " \
    source /testbed/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip install -r requirements/requirements-dev.txt && \
    pip install -e . \
"

# Add virtual environment activation in bashrc for convenience
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc

# Set default shell to bash
ENV SHELL=/bin/bash
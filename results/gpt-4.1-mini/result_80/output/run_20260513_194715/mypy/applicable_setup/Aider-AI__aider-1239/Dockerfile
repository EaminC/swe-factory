# Use a stable Ubuntu base with bash and python support
FROM --platform=linux/x86_64 ubuntu:22.04

# Avoid interactive prompts during package installation
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, curl, wget, bash, python3.10, python3.10-venv, python3-pip, build essentials
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    bash \
    python3.10 \
    python3.10-venv \
    python3-pip \
    python-is-python3 \
    build-essential \
    libffi-dev \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set locale environment variables
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Create the working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit, then create and activate python virtual environment,
# Install runtime and development dependencies, and install the project in editable mode
RUN git clone https://github.com/Aider-AI/aider.git /testbed/ \
    && cd /testbed/ \
    && git reset --hard 301c4265b76a5b8c4a939acb59314e091cacebec \
    && python3 -m venv testbed \
    && source testbed/bin/activate \
    && pip install --upgrade pip setuptools wheel \
    && pip install -r requirements.txt \
    && pip install -r requirements/requirements-dev.txt \
    && pip install -e . \
    && chmod -R a+rw /testbed/

# Add virtual environment activation to bashrc so it is enabled by default on interactive shell
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

# Set the default shell for container and environment
ENV PATH="/testbed/testbed/bin:$PATH"

# Set working directory explicitly again (optional)
WORKDIR /testbed/
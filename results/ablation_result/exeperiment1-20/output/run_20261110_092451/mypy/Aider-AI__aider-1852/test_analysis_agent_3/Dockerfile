# Use an official Ubuntu base image with bash and broad compatibility
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies for Python development, git, and build tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3.11 \
    python3.11-venv \
    python3-pip \
    python3.11-distutils \
    ca-certificates \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Configure locale separately to avoid potential build issues
RUN locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create a Python virtual environment named "testbed"
RUN python3.11 -m venv /opt/testbed

# Add virtual environment binaries to PATH
ENV PATH="/opt/testbed/bin:$PATH"

# Upgrade pip, setuptools, and wheel inside the virtual environment only
RUN /opt/testbed/bin/pip install --upgrade pip setuptools wheel

# Clone the repository and checkout the specified commit
RUN git clone https://github.com/paul-gauthier/aider.git /testbed \
    && cd /testbed \
    && git reset --hard 9789668ca4d14d3b6c24e56f3fe956147ea78039

# Install project dependencies and the project itself in editable mode inside the virtual environment
RUN /opt/testbed/bin/pip install -r /testbed/requirements.txt \
    && /opt/testbed/bin/pip install -r /testbed/requirements/requirements-dev.txt \
    && /opt/testbed/bin/pip install -e /testbed

# Set the working directory
WORKDIR /testbed/

# Configure bash to auto-activate the virtual environment on shell login (optional)
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc
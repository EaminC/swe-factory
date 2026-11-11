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

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create a Python virtual environment named "testbed"
RUN python3.11 -m venv /opt/testbed
ENV PATH="/opt/testbed/bin:$PATH"

# Upgrade pip, setuptools, and wheel inside the venv only
RUN /opt/testbed/bin/pip install --upgrade pip setuptools wheel

# Clone the repository and checkout the specific commit
# Then install dependencies and the repo itself in editable mode inside the virtual environment
RUN git clone https://github.com/paul-gauthier/aider.git /testbed \
    && cd /testbed \
    && git reset --hard 9789668ca4d14d3b6c24e56f3fe956147ea78039 \
    && /opt/testbed/bin/pip install -r requirements.txt \
    && /opt/testbed/bin/pip install -r requirements/requirements-dev.txt \
    && /opt/testbed/bin/pip install -e .

# Set working directory
WORKDIR /testbed/

# Ensure environment activation on bash login (optional, helpful for interactive use)
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc
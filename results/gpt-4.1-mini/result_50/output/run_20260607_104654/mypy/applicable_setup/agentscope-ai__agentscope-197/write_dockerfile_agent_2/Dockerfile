# Use Ubuntu 22.04 base image with bash shell available
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install essential system dependencies: git, wget, curl, build tools, python3 (3.10 in jammy), python3-venv, python3-distutils, and tzdata
RUN apt update && apt install -y \
    git \
    wget \
    curl \
    build-essential \
    python3 \
    python3-venv \
    python3-distutils \
    python3-pip \
    python3-setuptools \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Make sure python3 and pip3 point to installed python3.10 versions
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3 1 \
 && update-alternatives --install /usr/bin/pip3 pip3 /usr/bin/pip3 1

# Install virtualenv package via pip3 for environment management convenience (optional)
RUN pip3 install --no-cache-dir virtualenv

# Create virtual environment "testbed"
RUN python3 -m venv /opt/testbed

# Set working directory
WORKDIR /testbed/

# Clone project repo and checkout specific commit SHA
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    git reset --hard be8db4cc484b77d0d3bc60a012e9035c4395bee3

# Inside the virtual environment, upgrade pip, setuptools, and wheel; install the project with [full] extras and coverage
RUN /bin/bash -c "source /opt/testbed/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install -e .[full] && \
    pip install coverage"

# Add virtual environment activation to root user's bashrc for interactive convenience
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Default working directory for container
WORKDIR /testbed/

# Set bash as default shell for RUN commands
SHELL ["/bin/bash", "-c"]
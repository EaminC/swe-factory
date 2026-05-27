# Base image specification with bash and Python 3 default (3.10) on Ubuntu 22.04 LTS
FROM --platform=linux/x86_64 ubuntu:22.04

# Avoid user interaction during package installation
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system tools and libraries for Python environment and git
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3 \
    python3-venv \
    python3-distutils \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set locale to ensure proper unicode support
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Upgrade pip to latest stable version for default python3 (3.10)
RUN python3 -m pip install --upgrade pip

# Create and activate virtual environment named testbed
RUN python3 -m venv /opt/testbed
ENV PATH="/opt/testbed/bin:$PATH"

# Install dependencies inside virtual environment
# We will clone and install the project itself in editable mode later
RUN pip install --upgrade setuptools wheel coverage

# Clone the target repository and checkout the specified commit inside /testbed
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    cd /testbed && \
    git reset --hard 6c823a955c7be783a2a34c64d13b74aee8c552bf

# Set working directory
WORKDIR /testbed

# Install the project and its optional dependencies in editable mode with full extras
# Install coverage separately is allowed; 'full' includes optional dependencies
RUN pip install -e .[full]

# Setup bashrc to activate the virtual environment by default for convenience
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Environment variables OPENAI_API_KEY and OPENAI_ORGANIZATION should be set externally at runtime

# Note:
# - Tests are NOT run in this Dockerfile per requirements.
# - model_configs.json or other config files should be mounted or provided at runtime since not handled here.
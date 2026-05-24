# Use Ubuntu 22.04 LTS as base for compatibility and stability
FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
# Set /bin/bash as default shell explicitly for RUN commands
SHELL ["/bin/bash", "-c"]

# Install system dependencies for Python 3.10+ and build tools
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    rustc \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to latest stable release using python3.10 executable to avoid relying on venv before created
RUN python3.10 -m pip install --upgrade pip

# Create virtual environment named 'testbed'
RUN python3.10 -m venv /opt/testbed

# Check if venv pip exists before upgrading and upgrade pip using absolute python from venv
RUN test -f /opt/testbed/bin/pip && /opt/testbed/bin/python -m pip install --upgrade pip

# Set environment variables for shell inside container
ENV PATH="/opt/testbed/bin:$PATH"
ENV SHELL=/bin/bash

# Clone the repository and checkout the specific commit SHA as provided
RUN git clone https://github.com/crewAIInc/crewAI /testbed && \
    cd /testbed && \
    git reset --hard a548463faebd22aa3167a13ad417b4ab89776478 && \
    git remote remove origin

WORKDIR /testbed

# Install required dependencies in the virtual environment:
#   - Install tiktoken wheel first (requires rust)
#   - Install local 'crewai' package in editable mode to ensure code modifications are reflected
#   - Install pytest explicitly as testing framework
RUN pip install tiktoken --prefer-binary && \
    pip install -e . && \
    pip install pytest

# Set environment variable to disable telemetry opt-out for CrewAI as recommended
ENV OTEL_SDK_DISABLED=true

# Add a helper in /root/.bashrc to activate the virtual environment by default on container start
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc
# Use a stable Ubuntu base image with bash shell support
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies and tools
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    ca-certificates \
    locales-all \
    python3.11 \
    python3.11-venv \
    python3-pip \
    python3.11-distutils \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install setuptools and wheel with required versions
RUN python3.11 -m pip install --upgrade pip
RUN python3.11 -m pip install setuptools==78.1.1 wheel==0.45.1

# Create a Python virtual environment named testbed
RUN python3.11 -m venv /opt/testbed

# Activate virtual environment and install dependencies
# Install dev dependencies and coverage, pytest per the context instructions
RUN source /opt/testbed/bin/activate && \
    pip install --upgrade pip && \
    pip install -e .[dev] coverage pytest

# Set working directory where the repo will be cloned
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone -b main https://github.com/agentscope-ai/agentscope.git /testbed && \
    git reset --hard 8faa353e579591f99f3322a1aab3f35f2abafdf8

# Install the package in editable mode with development dependencies inside the virtual environment
RUN /bin/bash -c "source /opt/testbed/bin/activate && pip install -e .[dev] && pip install coverage pytest"

# Set environment variables required (empty defaults, can be overridden at runtime)
ENV DASHSCOPE_API_KEY=""
ENV GAODE_API_KEY=""

# Set the virtual environment to activate by default for convenience
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Set working directory to /testbed for subsequent commands/scripts
WORKDIR /testbed
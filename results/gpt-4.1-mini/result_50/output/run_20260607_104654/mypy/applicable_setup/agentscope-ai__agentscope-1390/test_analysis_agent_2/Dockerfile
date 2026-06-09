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

# Upgrade pip and install specific setuptools and wheel versions globally
RUN python3.11 -m pip install --upgrade pip
RUN python3.11 -m pip install setuptools==78.1.1 wheel==0.45.1

# Set working directory where the repo will be cloned
WORKDIR /testbed/

# Clone the repository and checkout the specific commit before installing anything
RUN git clone -b main https://github.com/agentscope-ai/agentscope.git /testbed && \
    git reset --hard 8faa353e579591f99f3322a1aab3f35f2abafdf8

# Create a Python virtual environment named testbed
RUN python3.11 -m venv /opt/testbed

# Activate virtual environment and install dependencies inside the cloned repo folder
RUN /bin/bash -c "source /opt/testbed/bin/activate && \
    pip install --upgrade pip && \
    pip install setuptools==78.1.1 wheel==0.45.1 && \
    pip install -e .[dev] coverage pytest"

# Set environment variables required (empty defaults, can be overridden at runtime)
ENV DASHSCOPE_API_KEY=""
ENV GAODE_API_KEY=""

# Set the virtual environment to activate by default for interactive use
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Final working directory for container usage
WORKDIR /testbed/
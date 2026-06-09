# Use Ubuntu 22.04 base image with explicit bash shell
FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential dependencies including python3.11, git, curl, and others
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    build-essential \
    locales \
    locales-all \
    tzdata \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x from NodeSource for compatibility with npm and frontend deps
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Verify node and npm versions (optional)
RUN node --version && npm --version

# Set python3 alternative to python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Upgrade pip to the latest stable release
RUN python3 -m pip install --upgrade pip

# Install uv environment manager (version >=0.4)
RUN python3 -m pip install "uv>=0.4"

# Set working directory to /testbed/
WORKDIR /testbed/

# Clone langflow repository and checkout specific commit SHA
RUN git clone https://github.com/langflow-ai/langflow.git /testbed/ && \
    cd /testbed/ && \
    git reset --hard 58efe809d4dad3decc833afd2f29b9a1038f6d5c

# Install frontend dependencies inside correct frontend directory
RUN cd /testbed/src/frontend && npm install --legacy-peer-deps

# Set environment PATH for uv usage in bash sessions
RUN echo "export PATH=$PATH" >> /root/.bashrc

# Expose commonly used ports (frontend/backend)
EXPOSE 7860 3000

# Note: Backend Python dependency installation via 'uv sync' and testing
# should be performed externally, not inside the Dockerfile.
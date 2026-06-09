# Use Ubuntu 22.04 as the base image to ensure bash availability and stable package manager behavior
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Update system and remove potential conflicting Node.js packages before fresh Node.js install
RUN apt-get update && apt-get remove -y libnode-dev nodejs npm || true

# Install essential tools and libraries including Python 3.10, git, curl, wget, build tools, locales, ca-certificates
RUN apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    locales \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Setup alternatives for python and pip to point to python3.10 explicitly
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Install Node.js 20.x to avoid npm engine compatibility issues with Node.js 21
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs

# Install pipx for uv package manager installation later
RUN pip install --no-cache-dir pipx
ENV PATH="/root/.local/bin:$PATH"

# Clone the repository & checkout target commit
RUN git clone https://github.com/langflow-ai/langflow /testbed

WORKDIR /testbed

RUN git checkout 3131c0ce083e157f5188cea833592c6cf4aad9d2

# Create and activate python virtual environment in /testbed/.venv
RUN python -m venv /testbed/.venv

ENV VIRTUAL_ENV=/testbed/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Upgrade pip in the virtual environment
RUN pip install --upgrade pip setuptools wheel

# Install hatch build system and build the package, then install with dependencies resolved by hatch
RUN pip install hatch
RUN hatch build
RUN pip install dist/*.whl

# Install the uv package manager globally via pipx
RUN pipx install uv

# Frontend setup: install dependencies and build frontend assets using npm in src/frontend
RUN cd src/frontend && npm install && npm run build

# Set the working directory explicitly
WORKDIR /testbed

# Default shell for container sessions
CMD ["/bin/bash"]
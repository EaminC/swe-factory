# Use Ubuntu 22.04 LTS as base image, includes /bin/bash and good package availability
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install essential system dependencies including git, python3.10 and build tools
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    ca-certificates \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and packaging tools
RUN python3.10 -m pip install --upgrade pip setuptools wheel

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit SHA
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    git reset --hard 811fb28a3dfd8c514e1b3f9fc10585069b35950d

# Create and activate python virtual environment inside container
RUN python3.10 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install the package in editable mode with dev extras (includes test dependencies) and required coverage & pytest
RUN /bin/bash -c "pip install --upgrade pip setuptools wheel && \
    pip install -e .[dev] coverage pytest"

# Use bash as default shell
SHELL ["/bin/bash", "-c"]

# Environment variables placeholder (can be used for runtime secrets and keys)
ENV OPENAI_API_KEY=""
ENV OPENAI_ORGANIZATION=""

# Explicitly set the working directory again, safe and clear
WORKDIR /testbed/
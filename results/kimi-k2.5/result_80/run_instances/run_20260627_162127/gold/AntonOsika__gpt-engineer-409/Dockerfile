FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies including Python 3.10
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    curl \
    wget \
    software-properties-common \
    python3.10 \
    python3.10-dev \
    python3.10-venv \
    python3-pip \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user to ensure permission-based tests work correctly
RUN useradd -m testuser

# Set working directory
WORKDIR /testbed/

# Clone repository and checkout specific commit, then change ownership to non-root user
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed/ && \
    git reset --hard 0596b07a39c2c99c46509c17660f5c8aef4b2114 && \
    git remote remove origin && \
    chown -R testuser:testuser /testbed

# Create virtual environment with Python 3.10 and set ownership
RUN python3.10 -m venv /opt/venv/testbed && \
    chown -R testuser:testuser /opt/venv/testbed

# Switch to non-root user for subsequent operations
USER testuser

# Install dependencies and project in editable mode
RUN /bin/bash -c "source /opt/venv/testbed/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install pytest pytest-cov && \
    pip install -e ."

# Set environment variables
ENV PATH="/opt/venv/testbed/bin:$PATH"
ENV OPENAI_API_KEY="dummy_key_for_testing"

# Configure bash to activate environment on login
RUN echo "source /opt/venv/testbed/bin/activate" >> /home/testuser/.bashrc

# Set shell to bash explicitly for subsequent commands
SHELL ["/bin/bash", "-c"]
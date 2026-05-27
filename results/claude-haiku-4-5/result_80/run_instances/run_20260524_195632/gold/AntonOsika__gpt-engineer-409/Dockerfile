# Base image specification
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    python3-pip \
    curl \
    jq \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Upgrade pip and install wheel
RUN python -m pip install --upgrade pip wheel setuptools

# Set working directory
WORKDIR /testbed/

# Clone the repository and setup the project
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard 0596b07a39c2c99c46509c17660f5c8aef4b2114 && \
    git remote remove origin

# Create virtual environment
RUN python -m venv /testbed/testbed_venv

# Install dependencies using the virtual environment
RUN /bin/bash -c "source /testbed/testbed_venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -e . && \
    pip install pytest==7.3.1 pytest-cov"

# Set up bash profile to activate virtual environment
RUN echo "source /testbed/testbed_venv/bin/activate" >> /root/.bashrc

# Set environment variables for testing
ENV PYTHONUNBUFFERED=1
ENV PATH=/testbed/testbed_venv/bin:$PATH

# Verify installation
RUN /bin/bash -c "source /testbed/testbed_venv/bin/activate && \
    python --version && \
    pip list | grep -E 'pytest|openai|click|typer' && \
    python -c 'import gpt_engineer; print(\"gpt-engineer imported successfully\")'"
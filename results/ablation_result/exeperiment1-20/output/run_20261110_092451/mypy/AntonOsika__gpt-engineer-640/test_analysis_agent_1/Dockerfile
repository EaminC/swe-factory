FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and tools
RUN apt update && apt install -y \
    git \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    curl \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install pip for python3.10
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 -

# Setup locale to avoid locale warnings
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Create and activate virtual environment, install dependencies
RUN python3.10 -m venv /testbed/testbed

ENV VIRTUAL_ENV=/testbed/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Clone repository and checkout specific commit
RUN git clone https://github.com/AntonOsika/gpt-engineer /testbed/
WORKDIR /testbed/
RUN git checkout dc7a2bd0f546ea29929faa57b8e618c413c86bb2

# Upgrade pip and install dependencies in editable mode including test dependencies
RUN pip install --upgrade pip setuptools wheel
RUN pip install -e . pytest pytest-cov

# Export environment variable placeholder for OPENAI_API_KEY (required for tests)
ENV OPENAI_API_KEY=""

# Fix permissions for all files so non-root users can access if needed
RUN chmod -R 777 /testbed/

# Default shell
SHELL ["/bin/bash", "-c"]

WORKDIR /testbed/
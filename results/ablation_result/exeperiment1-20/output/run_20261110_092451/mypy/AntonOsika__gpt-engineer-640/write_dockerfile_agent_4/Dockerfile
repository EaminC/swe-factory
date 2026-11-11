FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and tools including full locales-all package for better locale support
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

# Setup locale environment variables
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Generate locale
RUN locale-gen en_US.UTF-8

# Install pip for python3.10
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 -

# Remove /testbed if it exists to avoid cloning error, then clone repository and checkout specific commit SHA
RUN rm -rf /testbed
RUN git clone https://github.com/AntonOsika/gpt-engineer /testbed/
WORKDIR /testbed/
RUN git checkout dc7a2bd0f546ea29929faa57b8e618c413c86bb2

# Create and activate virtual environment inside the cloned repo directory, then install dependencies
RUN python3.10 -m venv /testbed/testbed

ENV VIRTUAL_ENV=/testbed/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Upgrade pip and install dependencies in editable mode including test dependencies
RUN pip install --upgrade pip setuptools wheel
RUN pip install -e . pytest pytest-cov

# Export environment variable placeholder for OPENAI_API_KEY (required for tests)
ENV OPENAI_API_KEY=""

# Fix permissions for all files so non-root users can access if needed
RUN chmod -R 777 /testbed/

WORKDIR /testbed/
SHELL ["/bin/bash", "-c"]
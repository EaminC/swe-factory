# Use official Ubuntu 22.04 image with bash available
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies and essential tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    python3-setuptools \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set locale to avoid locale warnings
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Symlink python to python3.11 explicitly
RUN ln -sf /usr/bin/python3.11 /usr/bin/python

# Upgrade pip to latest for better dependency resolution
RUN python -m pip install --upgrade pip

# Install Poetry (dependency manager) as required by the project
RUN curl -sSL https://install.python-poetry.org | python3 -

# Add Poetry to PATH
ENV PATH="/root/.local/bin:${PATH}"

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specified commit
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed && \
    cd /testbed && \
    git checkout 96dae2cc72a93f98a93331b29c6869580b93cf0

# Disable Poetry virtualenv creation and install dependencies including the package itself in development mode
RUN poetry config virtualenvs.create false && \
    cd /testbed && \
    poetry install --no-interaction --no-ansi

# Default shell to bash explicitly
SHELL ["/bin/bash", "-c"]
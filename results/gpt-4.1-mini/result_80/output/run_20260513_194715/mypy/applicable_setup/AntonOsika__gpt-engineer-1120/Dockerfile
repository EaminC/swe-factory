# Use Ubuntu 22.04 as base image with bash shell and reliable package management
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential tools and dependencies including python3.11, git, curl, build tools, and unzip
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    python3-setuptools \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.11 and pip is available for python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
 && python3 -m pip install --upgrade pip setuptools

# Install Poetry for dependency and virtual environment management
RUN curl -sSL https://install.python-poetry.org | python3 -

ENV PATH="/root/.local/bin:$PATH"

# Clone the gpt-engineer repo, checkout specific commit, install dependencies with Poetry in virtual env
WORKDIR /testbed/

RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed && \
    git reset --hard 04c71d7d297447479d897b6803206210ed589d53

# Install project dependencies including dev dependencies via Poetry in isolated virtual env (Poetry default)
RUN poetry config virtualenvs.create true && \
    poetry config virtualenvs.in-project true && \
    poetry install --no-interaction --no-ansi --with dev

# Expose environment variable key reminder (will need to be set at test runtime)
ENV OPENAI_API_KEY=""

# Add Poetry shell activation to .bashrc for convenience
RUN echo "source /root/.local/share/pypoetry/virtualenvs/gpt-engineer-*/bin/activate 2>/dev/null || true" >> ~/.bashrc

WORKDIR /testbed/
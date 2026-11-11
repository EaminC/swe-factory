# Use official Python 3.12 slim image to avoid PPA issues and provide required Python version
FROM --platform=linux/x86_64 python:3.12-slim-bullseye
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    locales \
    tzdata \
    gcc \
    g++ \
    pkg-config \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set locale and timezone
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Upgrade pip to latest version
RUN pip install --upgrade pip

# Install Poetry pinned to version 1.8.3
RUN curl -sSL https://install.python-poetry.org | POETRY_VERSION=1.8.3 python3 -

ENV PATH="/root/.local/bin:$PATH"

WORKDIR /testbed/

# Clone the repository and checkout the specified commit
ARG COMMIT_SHA
RUN git clone https://github.com/Canner/WrenAI.git /testbed && \
    git -C /testbed reset --hard $COMMIT_SHA && \
    ls -la /testbed

# Switch to python project directory where pyproject.toml exists
WORKDIR /testbed/wren-ai-service

# Configure Poetry to create virtualenvs inside project folder
RUN poetry config virtualenvs.in-project true

# Install dependencies without eval group and install the package in editable mode
RUN poetry install --without eval && \
    /bin/bash -c "source .venv/bin/activate && pip install -e ."

# Enable auto activation of poetry virtualenv on bash login
RUN echo "source /testbed/wren-ai-service/.venv/bin/activate" >> /root/.bashrc

WORKDIR /testbed/
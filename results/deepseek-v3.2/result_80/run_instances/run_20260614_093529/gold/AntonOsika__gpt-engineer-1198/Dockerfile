# Base image with Python 3.10 (matching the lower bound from pyproject.toml and avoiding ForwardRef issues)
FROM --platform=linux/x86_64 python:3.10-slim-bookworm

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    PYTHONUNBUFFERED=1 \
    POETRY_VERSION=1.8.2 \
    POETRY_HOME=/opt/poetry \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_NO_INTERACTION=1

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        build-essential \
        && \
    rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 - && \
    ln -s /opt/poetry/bin/poetry /usr/local/bin/poetry

# Set working directory
WORKDIR /testbed

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/gpt-engineer-org/gpt-engineer.git /testbed && \
    git reset --hard c1f4a9da5dd0abed15b91f6d1c60464cad84ce6c

# Install dependencies using Poetry (including development dependencies)
# --with dev installs all dev dependencies (pytest, pytest-cov, etc.)
RUN poetry install --no-root --with dev

# Install the package in development mode to ensure local code is referenced
RUN pip install -e .

# Clean up to reduce image size
RUN apt-get purge -y --auto-remove build-essential && \
    rm -rf /root/.cache

# Set default command to bash
CMD ["/bin/bash"]
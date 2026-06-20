# Base image specification. Use official Python 3.12 slim image for compatibility
FROM --platform=linux/x86_64 python:3.12-slim

# System dependencies installation. Installs essential tools and libraries required for development and runtime
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    curl \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set timezone and locale
ENV TZ=Etc/UTC
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Poetry (version 1.8.3) as the package manager for the project
RUN curl -sSL https://install.python-poetry.org | python3 - --version 1.8.3
ENV PATH="/root/.local/bin:$PATH"

# Set default workdir to testbed. (Required)
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/gpt-engineer-org/gpt-engineer.git /testbed && \
    git remote remove origin && \
    git reset --hard 04c71d7d297447479d897b6803206210ed589d53

# Configure Poetry to create virtual environments in the project directory
RUN poetry config virtualenvs.create true && \
    poetry config virtualenvs.in-project true

# Install project dependencies using Poetry (including test dependencies)
# According to pyproject.toml, test dependencies are in 'dev' group and 'test' extra
RUN poetry install --with dev --extras test --no-interaction

# Set up environment variable for tests (placeholder, actual value will be provided at runtime)
ENV OPENAI_API_KEY="dummy_key_for_testing"
ENV ANTHROPIC_API_KEY="dummy_key_for_testing"

# Ensure the testbed directory is writable
RUN chmod -R 777 /testbed

# Set the default shell to bash for compatibility
SHELL ["/bin/bash", "-c"]

# Add poetry virtualenv to PATH and activate it in bashrc for interactive sessions
RUN echo 'source /testbed/.venv/bin/activate' >> /root/.bashrc
ENV PATH="/testbed/.venv/bin:$PATH"
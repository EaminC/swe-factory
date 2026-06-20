# Base image with Python 3.12 (within the required range)
FROM --platform=linux/x86_64 python:3.12-slim

# Set environment variables to prevent interactive prompts
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    git \
    curl \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install UV - the project's dependency manager
# Using pip install as a reliable method
RUN pip install uv==0.4.25

# Verify UV installation
RUN uv --version

# Set default working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed/ \
    && git remote remove origin \
    && git reset --hard 4f6054d439c602f93283eda351fe6b67133b9a84

# Create a virtual environment using UV
RUN uv venv /testbed/.venv
ENV PATH="/testbed/.venv/bin:${PATH}"

# Install project with all dependencies (development and extras)
RUN uv sync --dev --all-extras

# Install the project in development mode
RUN uv pip install -e .

# Set environment variables for testing
ENV OTEL_SDK_DISABLED=true
ENV OPENAI_API_KEY="dummy-key-for-testing"
ENV SERPER_API_KEY="dummy-key-for-testing"

# Create a script to activate the environment
RUN echo 'source /testbed/.venv/bin/activate' >> /root/.bashrc

# Set the working directory to the testbed
WORKDIR /testbed/
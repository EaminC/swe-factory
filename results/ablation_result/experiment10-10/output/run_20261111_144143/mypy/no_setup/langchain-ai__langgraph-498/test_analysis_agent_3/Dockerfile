FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Update and install essential system dependencies
RUN apt update && apt install -y \
    git \
    curl \
    wget \
    build-essential \
    libffi-dev \
    python3 \
    python3-pip \
    python-is-python3 \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry (version 1.7.1 per context)
RUN curl -sSL https://install.python-poetry.org | POETRY_VERSION=1.7.1 python3 -

ENV PATH="/root/.local/bin:$PATH"

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/langchain-ai/langgraph /testbed/
WORKDIR /testbed/
RUN git reset --hard d63b15dc4721d48cb8368fe9011398df417fbc32

# Install Python dependencies including test dependencies via Poetry
RUN poetry config virtualenvs.create false && poetry install --with test

# Set default shell initialization for bash (useful later)
RUN echo 'export PATH="/root/.local/bin:$PATH"' >> /root/.bashrc

# Set working directory
WORKDIR /testbed/
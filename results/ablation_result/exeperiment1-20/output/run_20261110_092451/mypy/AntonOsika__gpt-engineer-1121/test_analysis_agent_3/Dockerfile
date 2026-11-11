# Use Ubuntu 22.04 as base image with bash shell support
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system utilities and dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    python3-setuptools \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry for dependency and environment management
RUN curl -sSL https://install.python-poetry.org | python3.11 - \
    && ln -s /root/.local/bin/poetry /usr/local/bin/poetry

# Add Poetry to PATH for subsequent RUN steps and container runtime
ENV PATH="/root/.local/bin:$PATH"

# Create and set working directory to /testbed before cloning
RUN mkdir -p /testbed
WORKDIR /testbed

# Clone the target repository and checkout the specific commit SHA
ARG REPO=https://github.com/AntonOsika/gpt-engineer.git
ARG COMMIT_SHA=04c71d7d297447479d897b6803206210ed589d53

RUN git clone ${REPO} . \
    && git checkout ${COMMIT_SHA}

# Install project dependencies using Poetry without virtualenv creation to use system python environment
RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi --no-root \
    && poetry install --no-interaction --no-ansi --with dev

# Environment variable placeholder for API key; expected to be set at runtime
ENV OPENAI_API_KEY=""

# Default shell
CMD ["/bin/bash"]
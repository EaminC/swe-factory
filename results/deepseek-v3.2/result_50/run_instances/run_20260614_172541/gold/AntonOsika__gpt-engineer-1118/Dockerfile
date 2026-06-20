# Base image specification. Defines the foundation OS and architecture for the container
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation. Installs essential tools and libraries required for development and runtime
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    curl \
    locales \
    tzdata \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.10 (since the project requires >=3.10,<3.13 and we want a specific version)
RUN apt-get update && apt-get install -y software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y python3.10 python3.10-dev python3.10-venv \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry (package manager used by the project)
RUN curl -sSL https://install.python-poetry.org | python3.10 -
ENV PATH="/root/.local/bin:$PATH"

# Set default workdir
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/gpt-engineer-org/gpt-engineer.git /testbed \
    && chmod -R 777 /testbed

WORKDIR /testbed
RUN git reset --hard 96dae2cc72a93f98a93331b29c6869580b93cf0c

# Install project dependencies using Poetry with Python 3.10
# First, configure Poetry to use the correct Python version
RUN poetry env use python3.10
# Install dependencies (including development dependencies for tests)
RUN poetry install --with dev

# Set up environment variables (OPENAI_API_KEY is required for tests, but we'll set a dummy value)
ENV OPENAI_API_KEY="dummy-key-for-testing"

# Create a script to activate the Poetry environment for easier use in eval script
RUN echo '#!/bin/bash\nsource $(poetry env info --path)/bin/activate' > /activate_poetry_env.sh \
    && chmod +x /activate_poetry_env.sh

# Add activation to bashrc for convenience
RUN echo 'source /activate_poetry_env.sh' >> /root/.bashrc
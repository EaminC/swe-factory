# Use Ubuntu 22.04 LTS as base image with bash and stable dependencies
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies, git, curl, wget, python3.10, python3.10-venv, and build essentials
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Fix update-alternatives to point to actual pip3.10 binary instead of /usr/bin/pip3 itself
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
 && update-alternatives --install /usr/bin/pip3 pip3 /usr/bin/pip3.10 1

# Upgrade pip and install poetry globally
RUN python3 -m pip install --upgrade pip \
 && python3 -m pip install poetry

# Set workdir to /testbed
WORKDIR /testbed/

# Clone the repo and checkout to the specified commit (passed as build-arg)
ARG COMMIT_SHA=c1f4a9da5dd0abed15b91f6d1c60464cad84ce6c
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed/ \
    && git reset --hard ${COMMIT_SHA}

# Install dependencies using poetry in a virtual environment (default poetry venv inside project)
# Install with --no-root first to install dependencies (including dev dependencies for tests)
RUN poetry config virtualenvs.in-project true \
    && poetry install --no-root --no-interaction --no-ansi

# Install the package itself in editable mode to ensure local code is used
RUN poetry run pip install -e .

# To ensure bash loads poetry's venv automatically on container start
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Export environment variables to inform user (OPENAI_API_KEY must be provided externally)
ENV OPENAI_API_KEY=""

# Default shell for subsequent instructions and runtime
CMD ["/bin/bash"]
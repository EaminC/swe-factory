# Use Ubuntu 22.04 base image with bash available
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and essential tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    locales \
    locales-all \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set python3 alternative to python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Set pip3 alternative to the correct binary installed by python3-pip package
RUN update-alternatives --install /usr/bin/pip3 pip3 /usr/bin/pip3.11 1 || true

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install uv tool globally (as referenced in docs for environment setup)
RUN pip3 install uv

# Create and activate virtual environment named testbed and add it to PATH
ENV VIRTUAL_ENV=/opt/testbed
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Clone repository and checkout specific commit SHA
RUN git clone https://github.com/crewAIInc/crewAI /testbed \
    && cd /testbed \
    && git reset --hard e655412aca3f7acb9852473b9d336372e635f8ce

WORKDIR /testbed

# Sync all dependencies including dev and extras using uv tool
RUN uv sync --dev --all-extras

# Install the local repository in editable mode to ensure local code is used
RUN pip install -e .

# Install optional tools extra as suggested, no pre-install of crewai from PyPI to avoid conflicts
RUN pip install "crewai[tools]"

# Add activation of virtual environment at shell login for convenience
RUN echo "source $VIRTUAL_ENV/bin/activate" >> /root/.bashrc

# Environment variables placeholders (to be set externally when running container or testing)
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""

# Set working directory for test execution and further usage
WORKDIR /testbed

# No test executions inside Dockerfile per instructions
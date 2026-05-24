# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# System dependencies installation. Installs essential tools and libraries required for development and runtime (Required)
RUN apt update && apt install -y \
    git \
    wget \
    curl \
    build-essential \
    libffi-dev \
    libssl-dev \
    locales-all \
    tzdata \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    python3 -m pip install --upgrade pip && \
    rm -rf /var/lib/apt/lists/*

# Install Hatchling (build system) globally for environment since repo uses hatchling build system
RUN python3 -m pip install hatchling

# Setup working directory
WORKDIR /testbed/

# Clone target repository and checkout specific commit SHA and install in development mode
ARG COMMIT_SHA=fbf87327841dd7b92bb04a23fd1575881a3ad3fa
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed && \
    cd /testbed && \
    git reset --hard ${COMMIT_SHA} && \
    git remote remove origin

# Create and activate Python virtual environment, install dependencies, then install the package in editable mode
RUN python3 -m venv testbed_venv && \
    source testbed_venv/bin/activate && \
    python -m pip install --upgrade pip && \
    # Install main dependencies explicitly since no requirements file, using constraints from context retrieval
    pip install "pydantic>=2.4.2" \
                "openai>=1.13.3" \
                "litellm==1.60.2" \
                "instructor>=1.3.3" \
                "pdfplumber>=0.11.4" \
                "regex>=2024.9.11" \
                "opentelemetry-api>=1.22.0" \
                "opentelemetry-sdk>=1.22.0" \
                "chromadb>=0.5.23" \
                "auth0-python>=4.7.1" \
                "python-dotenv>=1.0.0" \
                "uv>=0.4.25" && \
    # Install the project in editable mode to ensure local source is referenced
    pip install -e . && \
    deactivate

# Add activation command to bashrc for convenience
RUN echo "source /testbed/testbed_venv/bin/activate" >> /root/.bashrc

# Default workdir set and no entrypoint, no CMD as tests are run separately
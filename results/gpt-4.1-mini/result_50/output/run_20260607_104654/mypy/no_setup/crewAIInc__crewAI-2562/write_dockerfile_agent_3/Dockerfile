# Use Ubuntu 22.04 for stability and compatibility
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system tools and libraries:
# git, curl, wget for downloads; build-essential and cmake for compilation;
# rustc and cargo for Rust; python3.11 and related tools for Python environment;
# locales and tzdata for localization support
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    cmake \
    rustc \
    cargo \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    python3-setuptools \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Generate locale
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Upgrade pip to latest version
RUN python3.11 -m pip install --upgrade pip

# Create and set working directory inside container
RUN mkdir /testbed
WORKDIR /testbed

# Clone the repository and checkout the specific commit provided via build argument
ARG COMMIT_SHA=5780c3147afd2db9be5cd7eb88450a0f04f12977
RUN git clone https://github.com/crewAIInc/crewAI.git . \
    && git reset --hard ${COMMIT_SHA} \
    && git remote remove origin

# Create virtual environment OUTSIDE the /testbed directory to prevent it from being included in packaging/build
RUN python3.11 -m venv /venv

# Update PATH to use created venv
ENV PATH="/venv/bin:$PATH"

# Upgrade pip inside virtual environment
RUN pip install --upgrade pip setuptools

# Install UV package manager in the virtual environment
RUN pip install uv

# Use uv commands from venv to create uv virtual environment and sync dependencies
RUN uv venv && uv sync

# Install the repository itself in editable mode and install required extras
RUN pip install -e . \
    && pip install 'crewai[tools]' \
    && pip install 'crewai[embeddings]' \
    && pip install tiktoken --prefer-binary

# Build the project using uv
RUN uv build

# Install pre-commit hooks if available; do not fail if pre-commit is missing
RUN pre-commit install || echo "Skipping pre-commit install if not available"

# Set environment variables placeholders to be overridden at runtime
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED=""

# Set default shell command to bash for compatibility
CMD ["/bin/bash"]
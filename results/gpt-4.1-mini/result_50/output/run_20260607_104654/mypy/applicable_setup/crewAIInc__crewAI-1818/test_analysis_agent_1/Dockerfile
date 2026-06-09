# Use Ubuntu 22.04 as base image for stability and compatibility
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system tools and libraries:
# git for cloning, curl and wget for downloads,
# build-essential and Visual C++ Build Tools equivalent (build-essential, cmake) for compiling,
# rustc and cargo for Rust compiler,
# python3.11, python3.11-venv, python3.11-distutils for Python environment,
# locales and tzdata for environment localization
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

# Set locale to UTF-8
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Upgrade pip to latest version
RUN python3.11 -m pip install --upgrade pip

# Create work directory
RUN mkdir /testbed
WORKDIR /testbed

# Clone the repository and checkout the specific commit provided via build argument
ARG COMMIT_SHA=a548463faebd22aa3167a13ad417b4ab89776478
RUN git clone https://github.com/crewAIInc/crewAI.git . \
    && git reset --hard ${COMMIT_SHA} \
    && git remote remove origin

# Create and activate python virtual environment using 'uv' (UV package manager) commands:
# We will install 'uv' via pip in this environment for creating and managing the venv, locks and syncing dependencies
RUN python3.11 -m venv /testbed/venv
ENV PATH="/testbed/venv/bin:$PATH"

# Upgrade pip inside virtual environment
RUN pip install --upgrade pip

# Install UV package manager (assuming it's installable by pip as 'uv')
RUN pip install uv

# Create UV virtual environment (runs `uv venv`)
RUN uv venv

# Install repository and dependencies in development mode:
# First, install the repository itself in editable mode to ensure local source is referenced
# Then install dependencies as per instructions (crewai, crewai[tools], crewai[embeddings], tiktoken)
RUN pip install -e . \
    && pip install crewai \
    && pip install 'crewai[tools]' \
    && pip install 'crewai[embeddings]' \
    && pip install tiktoken --prefer-binary

# Build the project (using uv build)
RUN uv build

# Install pre-commit hooks for development
RUN pre-commit install || echo "Skipping pre-commit install if not available"

# Export environment variables placeholders (keys must be set externally at container runtime)
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""

# Set default shell to bash explicitly
CMD ["/bin/bash"]
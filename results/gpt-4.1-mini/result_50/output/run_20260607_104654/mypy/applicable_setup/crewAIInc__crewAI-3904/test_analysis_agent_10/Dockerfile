# Base image specification. Defines the foundation OS and architecture for the container
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system tools and libraries:
# - git for cloning the repo
# - curl and wget for downloading
# - build-essential, cmake for building packages
# - rustc and cargo as some Python packages require Rust compiler for wheel builds
# - python3.11 and related packages to satisfy python version requirement (>=3.10,<3.14)
# - python3-pip and python3.11-venv for virtual environment and pip usage
# - locales and tzdata for consistent locale settings
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

# Configure locale to en_US.UTF-8
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Symlink python3 to python3.11
RUN ln -sf /usr/bin/python3.11 /usr/bin/python3

# Upgrade pip globally
RUN python3 -m pip install --upgrade pip

# Create and set working directory
RUN mkdir /testbed
WORKDIR /testbed

# Clone the repository and checkout the provided commit (build argument)
ARG REPO=https://github.com/crewAIInc/crewAI.git
ARG COMMIT_SHA=528d81226361be0f87c9e077ed0d3eb28243120f
RUN git clone "$REPO" . \
    && git reset --hard "$COMMIT_SHA" \
    && git remote remove origin

# Create a Python virtual environment outside the repo directory to avoid packaging conflicts
RUN python3 -m venv /venv

# Add virtual environment binaries to PATH
ENV PATH="/venv/bin:$PATH"

# Upgrade pip inside the virtual environment
RUN pip install --upgrade pip

# Install 'uv' tool (dependency manager) and pre-commit in the virtual environment
RUN pip install uv pre-commit

# Use uv to create and synchronize the uv-managed virtual environment for the project
RUN uv venv

# Install project dependencies and extras inside uv virtual environment using a single RUN command to preserve env:
# - 'crewai[tools]' and 'crewai[embeddings]' as per README
# - 'qdrant-client' explicitly required by tests
# - 'tiktoken' with preferred binary wheels
# Then install the project in editable mode.
# Note: 'mem0' is internal module included in repo source code, no separate installation needed.
RUN /bin/bash -c "source .venv/bin/activate && \
    pip install 'crewai[tools]' 'crewai[embeddings]' qdrant-client tiktoken --prefer-binary && \
    pip install -e ."

# Build the project artifacts using uv
RUN uv build

# Install pre-commit hooks quietly; continue even if no config present
RUN /bin/bash -c "source .venv/bin/activate && pre-commit install" || echo "No pre-commit hooks installed"

# Set environment variable placeholders, to be assigned at runtime
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""

# Disable OpenTelemetry telemetry as recommended
ENV OTEL_SDK_DISABLED=true

# Add auto-activation of uv-managed virtual environment on bash shell startup
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Set the working directory
WORKDIR /testbed/
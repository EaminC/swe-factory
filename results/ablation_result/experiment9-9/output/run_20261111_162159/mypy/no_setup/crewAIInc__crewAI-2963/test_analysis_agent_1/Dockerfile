# Use Ubuntu 22.04 as base image for good compatibility and bash support
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies, Python 3.11 (within 3.10 to 3.14 range), Rust compiler, git, build tools, curl, wget, and locales
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    python3.11 \
    python3.11-distutils \
    python3.11-venv \
    python3-pip \
    rustc \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Configure locales and timezone properly
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Upgrade pip for the chosen python
RUN python3.11 -m pip install --upgrade pip

# Set up a Python virtual environment named 'testbed' and install dependencies inside it
RUN python3.11 -m venv /opt/testbed
ENV PATH="/opt/testbed/bin:$PATH"

# Clone the target repository and checkout the specific commit
WORKDIR /testbed/
RUN git clone https://github.com/crewAIInc/crewAI . && \
    git reset --hard b0d89698fdd3eb5aced8e659f2241f0648b8a40b

# Install runtime dependencies and extras as per context:
# - install core library in editable mode
# - install extra dependencies with [tools] (which implies embedchain etc.)
# - install embeddings extra in case tiktoken is missing (also requires rust)
# Using pip inside the virtual environment

RUN /bin/bash -c "\
    source /opt/testbed/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -e . && \
    pip install --no-cache-dir 'crewai[tools]' 'crewai[embeddings]'"

# Ensure /bin/bash is default shell
SHELL ["/bin/bash", "-c"]

# Add a bashrc line to source the virtualenv automatically for interactive runs
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Set working directory (redundant but explicit)
WORKDIR /testbed/
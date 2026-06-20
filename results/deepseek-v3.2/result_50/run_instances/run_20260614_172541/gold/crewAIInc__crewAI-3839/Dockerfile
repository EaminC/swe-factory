# Base image specification. Use Ubuntu 22.04 for stability and bash compatibility
FROM --platform=linux/x86_64 ubuntu:22.04

# Set environment variables for non-interactive installation
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation. Installs essential tools and libraries required for development and runtime
RUN apt-get update && apt-get install -y \
    wget \
    git \
    curl \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    pkg-config \
    libssl-dev \
    libffi-dev \
    libtiff-dev \
    libjpeg-dev \
    libopenjp2-7-dev \
    zlib1g-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    tcl-dev \
    tk-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libxcb1-dev \
    && rm -rf /var/lib/apt/lists/*

# Install UV (the project's dependency manager) from official source
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Set PATH to include uv for subsequent commands
ENV PATH="/root/.local/bin:$PATH"

# Install a specific Python version within the supported range (>=3.10, <3.14)
RUN uv python install 3.12.8

# Set default workdir to testbed
WORKDIR /testbed

# Clone the repository
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed \
    && chmod -R 777 /testbed

# Checkout the specific commit SHA provided
RUN cd /testbed && git reset --hard 7e6171d5bc35da485e119fef9442faa02fcd0984 \
    && git remote remove origin

# Verify uv and Python versions
RUN which uv && uv --version && python3 --version && uv python list

# Create virtual environment using UV with the installed Python 3.12.8
RUN cd /testbed && uv venv --python 3.12.8

# Install all dependencies (including dev and extras) using uv sync
RUN cd /testbed && uv sync --dev --all-extras

# Install the crewai package from the workspace in editable mode
# The actual package is in lib/crewai directory, not the root workspace
RUN cd /testbed && uv pip install -e ./lib/crewai && uv pip install -e ./lib/crewai-tools

# Set up environment variables for testing (required by tests)
ENV OPENAI_API_KEY="fake-api-key"
ENV SERPER_API_KEY="fake-serper-key"
ENV OPEN_ROUTER_API_KEY="fake-openrouter-key"

# Disable telemetry by default
ENV OTEL_SDK_DISABLED="true"

# Add UV's virtual environment to PATH for easier access
ENV PATH="/testbed/.venv/bin:$PATH"

# Create a wrapper script to activate the virtual environment and run commands
RUN echo '#!/bin/bash\nsource /testbed/.venv/bin/activate\n"$@"' > /usr/local/bin/run-in-venv \
    && chmod +x /usr/local/bin/run-in-venv

# Set up the shell to automatically activate the virtual environment
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Verify Python version in virtual environment matches project requirements
RUN python --version

# Display installed crewai packages for debugging
RUN uv pip list | grep -E "(crewai|Name)" | head -20

# Verify the crewai module can be imported
RUN python -c "import crewai; print(f'Successfully imported crewai version {crewai.__version__}')" || echo "Failed to import crewai"
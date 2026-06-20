# Base image specification. Defines the foundation OS and architecture for the container
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation. Installs essential tools and libraries required for development and runtime
RUN apt update && apt install -y \
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
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA for Python 3.12 installation on Ubuntu 22.04
RUN add-apt-repository ppa:deadsnakes/ppa \
    && apt update

# Install Python 3.12 from deadsnakes PPA (matches the project's Python version requirements)
RUN apt install -y python3.12 python3.12-dev python3.12-venv \
    && rm -rf /var/lib/apt/lists/*

# Verify Python 3.12 installation and set it as the default python3
RUN python3.12 --version \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 3 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 2 \
    && update-alternatives --set python3 /usr/bin/python3.12

# Install pip for Python 3.12
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

# Install UV for dependency management (as specified in the project)
RUN pip3 install uv>=0.4.25

# Ensure uv is in PATH for subsequent commands
ENV PATH="/root/.local/bin:${PATH}"

# Verify Python and uv installation
RUN python3 --version && uv --version

# Set default workdir to testbed
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/crewAIInc/crewAI /testbed \
    && chmod -R 777 /testbed \
    && cd /testbed \
    && git reset --hard 1dc4f2e8977eb68b54dc3184a9548dfe10e57f3e

# Set up the environment using UV with Python 3.12 explicitly
RUN cd /testbed \
    # Create virtual environment with Python 3.12 explicitly
    && uv venv --python python3.12 \
    # Activate the virtual environment
    && . .venv/bin/activate \
    # Verify Python version in virtual environment
    && python --version \
    # Sync all dependencies including dev and extras (as per CI setup)
    && uv sync --dev --all-extras

# Install the package in development mode to ensure local code is referenced
RUN cd /testbed \
    && . .venv/bin/activate \
    # Install the package in development mode (this will install crewai from local source)
    && uv pip install -e . \
    # Install optional dependencies needed for tests (tools and embeddings)
    && uv pip install 'crewai[tools,embeddings]'

# Install additional test dependencies that might not be covered by uv sync
RUN cd /testbed \
    && . .venv/bin/activate \
    && uv pip install pytest-vcr

# Set up environment variables for testing (as specified in the project)
ENV OTEL_SDK_DISABLED=true
ENV OPENAI_API_KEY="dummy-key-for-testing"
ENV SERPER_API_KEY="dummy-key-for-testing"
ENV CREWAI_DISABLE_TELEMETRY="true"
ENV CREWAI_TESTING="true"

# Set pytest configuration to avoid deprecation warnings
ENV PYTEST_ASYNCIO_DEFAULT_FIXTURE_LOOP_SCOPE="function"

# Activate the virtual environment by default for interactive shells
RUN echo ". /testbed/.venv/bin/activate" >> /root/.bashrc

# Final verification of Python version and installed packages
RUN . /testbed/.venv/bin/activate \
    && echo "Final Python version check:" && python --version \
    && echo "UV version:" && uv --version \
    && echo "Installed packages:" && uv pip list | head -30
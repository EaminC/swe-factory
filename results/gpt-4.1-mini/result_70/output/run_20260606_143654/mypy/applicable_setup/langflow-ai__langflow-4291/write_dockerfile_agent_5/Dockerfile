# Base image with bash, suitable for Python environment and node setup
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Remove any preinstalled nodejs or npm to avoid conflicts
RUN apt-get purge -y nodejs npm || true

# Install system dependencies required for building, git, python 3.10, pip, curl, locales, tzdata, build-essential
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set python3.10 and pip3 as default python and pip
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Install Node.js v20 from NodeSource for best npm compatibility
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    node -v && npm -v

# Upgrade pip, setuptools, wheel
RUN python3 -m pip install --upgrade pip setuptools wheel

# Set working directory
WORKDIR /testbed/

# Clone the target repository and checkout the specific commit
RUN git clone https://github.com/langflow-ai/langflow.git /testbed && \
    git -C /testbed reset --hard 3131c0ce083e157f5188cea833592c6cf4aad9d2

# Install pipx for uv tool installation (uv is required and installed via pipx)
RUN python3 -m pip install pipx && \
    python3 -m pipx ensurepath

# Install main Python dependencies from pyproject.toml using pip and hatchling build system
# Install hatch build backend first
RUN python3 -m pip install 'hatchling>=1.0.0'

# Install the project in editable/development mode, including main dependencies
# Install dev dependencies separately for tests (not mandatory here, tests run later)
RUN python3 -m pip install -e .[dev]

# Install frontend dependencies
RUN cd src/frontend && npm install && npm run build

# Synchronize and configure backend dependencies using uv tool installed via pipx
RUN uv sync --frozen

# Add pipx bin dir to PATH for uv tool accessibility
ENV PATH="/root/.local/bin:$PATH"

# Optionally source .bashrc for default shell environment
RUN echo "source ~/.bashrc" >> /root/.bashrc

# Set default shell to bash for runtime and scripts
ENV SHELL=/bin/bash
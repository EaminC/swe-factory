# Base image with Python 3.10+ and full system support
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3 \
    python3-pip \
    python3-dev \
    python-is-python3 \
    curl \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install uv for faster package management (mentioned in README)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Set up working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed
RUN git reset --hard b35c1652c7b46a0af2785f988925d9910e3b7b70
RUN git remote remove origin

# Install the package in development mode with dev dependencies
# Using pip (fallback if uv has issues)
RUN pip install --upgrade pip setuptools wheel
RUN pip install -e ".[dev]"

# Also install with uv as alternative (faster)
RUN uv pip install --system -e ".[dev]"

# Set environment variables for test files (empty values for safety)
ENV DASHSCOPE_API_KEY=""
ENV GAODE_API_KEY=""
ENV OPENAI_API_KEY=""
ENV ANTHROPIC_API_KEY=""

# Create a script to activate environment (for bash sessions)
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'cd /testbed' >> /entrypoint.sh && \
    echo 'exec "$@"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set default command
CMD ["/bin/bash"]
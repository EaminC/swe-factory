# Base image specification. Defines the foundation OS and architecture for the container
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation. Installs essential tools and libraries required for development and runtime
RUN apt update && apt install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    libssl-dev \
    ca-certificates \
    curl \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install uv and Python 3.12.8 in a single RUN step to ensure uv is in PATH
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    /root/.local/bin/uv python install 3.12.8

# Set up PATH to include uv and Python binaries
ENV PATH=/root/.local/bin:$PATH

# Set default workdir to testbed
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/crewAIInc/crewAI /testbed && \
    cd /testbed && \
    git remote remove origin && \
    git reset --hard a548463faebd22aa3167a13ad417b4ab89776478

# Set up virtual environment and install all dependencies including development extras
RUN uv venv && \
    . .venv/bin/activate && \
    uv sync --dev --all-extras

# Install the project in development mode using uv pip (not pip directly)
RUN uv pip install -e .

# Set up environment variables required for tests
ENV OPENAI_API_KEY=fake-api-key
ENV SERPER_API_KEY=test-key
ENV OTEL_SDK_DISABLED=true

# Activate virtual environment by default for interactive shells
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Ensure proper permissions
RUN chmod -R 755 /testbed
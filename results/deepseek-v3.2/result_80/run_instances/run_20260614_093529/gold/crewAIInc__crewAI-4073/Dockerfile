# Base image with Python 3.12 (within the required range 3.9-3.13)
FROM --platform=linux/x86_64 python:3.12-slim-bookworm

# Set environment variables for testing
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    OTEL_SDK_DISABLED=true \
    UV_HOME=/root/.local/share/uv \
    UV_PROJECT_ENVIRONMENT=/testbed/.venv \
    CREWAI_TESTING=true \
    CREWAI_DISABLE_TELEMETRY=true \
    CREWAI_STORAGE_DIR=/tmp/crewai_storage \
    PYTEST_BLOCK_NETWORK=true \
    PYTEST_VCR_RECORD_MODE=none \
    # Dummy API keys as used in .env.test file
    OPENAI_API_KEY=fake-api-key \
    ANTHROPIC_API_KEY=fake-anthropic-key \
    GEMINI_API_KEY=fake-gemini-key \
    AZURE_API_KEY=fake-azure-key \
    OPENROUTER_API_KEY=fake-openrouter-key \
    AWS_ACCESS_KEY_ID=fake-aws-access-key \
    AWS_SECRET_ACCESS_KEY=fake-aws-secret-key \
    AWS_DEFAULT_REGION=us-east-1 \
    SERPER_API_KEY=fake-serper-key \
    EXA_API_KEY=fake-exa-key \
    TAVILY_API_KEY=fake-tavily-key \
    SINGLESTOREDB_URL=mysql://fake:fake@localhost:3306/fake \
    WEAVIATE_URL=http://localhost:8080 \
    MONGODB_URI=mongodb://fake:fake@localhost:27017/fake \
    CREWAI_TRACING_ENABLED=false

# Install system dependencies (only required packages based on CI configuration)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    pkg-config \
    libffi-dev \
    libssl-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install UV package manager (as in CI configuration)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add UV to PATH
ENV PATH="/root/.local/bin:$PATH"

# Set default work directory
WORKDIR /testbed

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed \
    && cd /testbed \
    && git reset --hard e43c7debbd444486df77c83fc604641e18f1cd8a \
    && git config --global --add safe.directory /testbed

# Create virtual environment with UV using Python 3.12
RUN uv venv --python 3.12

# Install all dependencies including dev groups and extras (as in CI configuration)
RUN uv sync \
    --frozen \
    --group dev \
    --all-extras

# Install the main crewai package in development mode from the workspace
# Navigate to the lib/crewai directory and install it
RUN cd /testbed/lib/crewai && uv pip install -e .

# Create storage directory for tests
RUN mkdir -p /tmp/crewai_storage && chmod 777 /tmp/crewai_storage

# Set up the bashrc to automatically activate the virtual environment
RUN echo 'source /testbed/.venv/bin/activate' >> /root/.bashrc

# Create a test environment setup script
RUN echo '#!/bin/bash\n\
source /testbed/.venv/bin/activate\n\
# Set required environment variables for testing\n\
export CREWAI_STORAGE_DIR="/tmp/crewai_storage"\n\
export CREWAI_TESTING="true"\n\
export CREWAI_DISABLE_TELEMETRY="true"\n\
export OTEL_SDK_DISABLED="true"\n\
export PYTEST_VCR_RECORD_MODE="none"\n\
export PYTHONUNBUFFERED="1"\n\
export PYTEST_BLOCK_NETWORK="true"\n\
# Create storage directory if it doesn'\''t exist\n\
mkdir -p "$CREWAI_STORAGE_DIR"\n\
# Run the command passed as arguments\n\
exec "$@"' > /testbed/setup_test_env.sh \
    && chmod +x /testbed/setup_test_env.sh

# Add the test environment setup to bashrc
RUN echo 'source /testbed/setup_test_env.sh' >> /root/.bashrc

# Clean up to reduce image size
RUN apt-get clean \
    && rm -rf /tmp/* /var/tmp/* \
    && find /usr -depth -name '__pycache__' -type d -exec rm -rf {} + \
    && find /usr -name '*.pyc' -delete \
    && uv cache clean

# Verify Python and UV versions
RUN python --version && uv --version

# Default command (optional, can be overridden)
CMD ["/bin/bash"]
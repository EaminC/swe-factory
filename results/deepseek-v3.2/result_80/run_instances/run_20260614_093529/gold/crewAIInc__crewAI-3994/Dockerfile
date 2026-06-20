# Base image with Python and bash
FROM --platform=linux/x86_64 python:3.13-slim-bookworm

# Set environment variables for testing
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    OTEL_SDK_DISABLED=true \
    UV_PROJECT_ENVIRONMENT=/testbed/.venv \
    CREWAI_TESTING=true \
    CREWAI_DISABLE_TELEMETRY=true \
    CREWAI_STORAGE_DIR=/tmp/crewai_storage \
    # Dummy API keys as used in CI tests
    OPENAI_API_KEY="sk-dummy-openai-api-key-for-test" \
    OPENAI_ORGANIZATION="org-dummy" \
    ANTHROPIC_API_KEY="dummy-anthropic-api-key" \
    AZURE_OPENAI_API_KEY="dummy-azure-openai-api-key" \
    AZURE_OPENAI_ENDPOINT="https://dummy-endpoint.openai.azure.com/" \
    BRAVE_API_KEY="dummy-brave-api-key" \
    SERPER_API_KEY="dummy-serper-api-key" \
    SNOWFLAKE_ACCOUNT="dummy-account" \
    SNOWFLAKE_USER="dummy-user" \
    SNOWFLAKE_PASSWORD="dummy-password" \
    SNOWFLAKE_WAREHOUSE="dummy-warehouse" \
    SNOWFLAKE_DATABASE="dummy-database" \
    SNOWFLAKE_SCHEMA="dummy-schema" \
    EMBEDCHAIN_DB_URI="sqlite:///:memory:" \
    MODEL_API_KEY="dummy-model-api-key" \
    BROWSERBASE_API_KEY="dummy-browserbase-api-key" \
    BROWSERBASE_PROJECT_ID="dummy-project-id" \
    # Network blocking for tests
    PYTEST_BLOCK_NETWORK=true

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install UV to /root/.local/bin
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add UV to PATH
ENV PATH="/root/.local/bin:$PATH"

# Set default work directory
WORKDIR /testbed

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed \
    && git remote remove origin \
    && git reset --hard 4d8eec96e8432eda570207a601655ec29e9d1d6e \
    && chmod -R 755 /testbed

# Configure UV to use system Python and create virtual environment
RUN uv python install 3.13 \
    && uv venv --python 3.13 \
    && echo 'source /testbed/.venv/bin/activate' >> /root/.bashrc

# Install all dependencies including dev groups and extras
RUN uv sync \
    --frozen \
    --group dev \
    --all-extras

# Install litellm for fallback LLM functionality
RUN uv pip install litellm>=1.0.0

# Install the project in development mode
RUN uv run pip install -e .

# Set up environment for tests (without running them)
ENV PATH="/testbed/.venv/bin:$PATH"

# Create storage directory for tests
RUN mkdir -p /tmp/crewai_storage && chmod 777 /tmp/crewai_storage

# Verify Python and UV versions
RUN python --version && uv --version

# Clean up to reduce image size
RUN apt-get clean \
    && rm -rf /tmp/* /var/tmp/* \
    && find /usr -name '*.pyc' -delete

# Default command (optional, can be overridden)
CMD ["/bin/bash"]
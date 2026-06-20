# Base image with optimized size
FROM --platform=linux/x86_64 ubuntu:22.04

# Set environment variables to avoid interactive prompts
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Clean up APT cache and install only essential system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    git \
    curl \
    ca-certificates \
    build-essential \
    libffi-dev \
    libssl-dev \
    libpq-dev \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    python-is-python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install pipx for Poetry installation (minimal dependencies)
RUN python3 -m pip install --no-cache-dir pipx \
    && python3 -m pipx ensurepath

# Install Poetry using pipx
ENV PATH="/root/.local/bin:$PATH"
RUN pipx install poetry==1.4.0

# Install Node.js from NodeSource (LTS version) with minimal dependencies
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set up working directory
WORKDIR /testbed

# Clone the repository (full clone to ensure all commits are available)
RUN git clone https://github.com/langflow-ai/langflow.git /testbed

# Checkout the specific commit
RUN cd /testbed && git checkout 667713f6c04fbc208fb7eefba70f101562070c9e

# Configure Poetry to create virtual environment in project
RUN cd /testbed && poetry config virtualenvs.create true \
    && poetry config virtualenvs.in-project true

# Install Python dependencies using Poetry (main + dev dependencies)
# This installs langflow and langflow-base as per pyproject.toml configuration
RUN cd /testbed && poetry install --no-interaction --with dev

# Install frontend dependencies (clean cache after installation)
RUN cd /testbed/src/frontend \
    && npm ci --no-audit --prefer-offline \
    && npm cache clean --force

# Install Playwright browsers with minimal dependencies (chromium only)
RUN cd /testbed/src/frontend \
    && npx playwright install chromium \
    && npx playwright install-deps chromium

# Set up environment variables for testing
ENV LANGFLOW_DATABASE_URL="sqlite:///./langflow.db"
ENV LANGFLOW_HOST="127.0.0.1"
ENV LANGFLOW_PORT="7860"
ENV LANGFLOW_CACHE_TYPE="memory"
ENV BACKEND_URL="http://localhost:7860/"
ENV PYTHONPATH="/testbed/src/backend:$PYTHONPATH"
ENV PATH="/testbed/.venv/bin:$PATH"

# Create .env file with default values
RUN cd /testbed && echo "LANGFLOW_DATABASE_URL=sqlite:///./langflow.db" > .env \
    && echo "LANGFLOW_HOST=127.0.0.1" >> .env \
    && echo "LANGFLOW_PORT=7860" >> .env \
    && echo "LANGFLOW_CACHE_TYPE=memory" >> .env \
    && echo "BACKEND_URL=http://localhost:7860/" >> .env

# Set up bashrc to activate virtual environment
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Clean up unnecessary files to reduce image size
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && find /usr -name '*.pyc' -delete \
    && find /usr -name '__pycache__' -delete

# Ensure proper permissions
RUN chmod -R 755 /testbed

# Default command (can be overridden)
CMD ["/bin/bash"]
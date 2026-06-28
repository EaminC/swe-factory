FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Use bash as default shell to ensure compatibility
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, curl, build tools, and ca-certificates
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install UV (version 0.8.4 as specified in CI) - installs to /root/.local/bin by default
RUN curl -LsSf https://astral.sh/uv/0.8.4/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Set working directory
WORKDIR /testbed/

# Clone repository and checkout specific commit
ARG COMMIT_SHA=4d8eec96e8432eda570207a601655ec29e9d1d6e
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed && \
    cd /testbed && \
    git reset --hard ${COMMIT_SHA} && \
    git remote remove origin && \
    chmod -R 777 /testbed

# Set required environment variables for test execution
ENV OPENAI_API_KEY=fake-api-key
ENV PYTHONUNBUFFERED=1
ENV BRAVE_API_KEY=fake-brave-key
ENV SNOWFLAKE_USER=fake-snowflake-user
ENV SNOWFLAKE_PASSWORD=fake-snowflake-password
ENV SNOWFLAKE_ACCOUNT=fake-snowflake-account
ENV SNOWFLAKE_WAREHOUSE=fake-snowflake-warehouse
ENV SNOWFLAKE_DATABASE=fake-snowflake-database
ENV SNOWFLAKE_SCHEMA=fake-snowflake-schema
ENV EMBEDCHAIN_DB_URI=sqlite:///test.db

# Install Python 3.11 (within required range >=3.10,<3.14) and setup workspace environment
# UV will manage the Python version and virtual environment
RUN uv python install 3.11
RUN uv venv --python 3.11

# Sync all dependencies including dev dependencies and extras
# This installs all workspace members (lib/crewai, lib/crewai-tools, lib/devtools) in editable mode
RUN uv sync --all-groups --all-extras

# Ensure UV is available in PATH for interactive shells
RUN echo 'export PATH="/root/.local/bin:$PATH"' >> /root/.bashrc
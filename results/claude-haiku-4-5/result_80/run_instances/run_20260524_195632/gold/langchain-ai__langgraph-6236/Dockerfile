# Base image specification
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    libpq-dev \
    python3 \
    python3-pip \
    python-is-python3 \
    curl \
    locales \
    locales-all \
    tzdata \
    jq \
    pkg-config \
    ca-certificates \
    postgresql-client \
    postgresql \
    postgresql-contrib \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default (satisfies >=3.9 requirement)
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    && rm -rf /var/lib/apt/lists/*

# Install uv package manager using pip (more reliable than curl script)
RUN python3.11 -m pip install --upgrade pip setuptools wheel && \
    python3.11 -m pip install uv

# Set work directory
WORKDIR /testbed/

# Clone the LangGraph repository
RUN git clone https://github.com/langchain-ai/langgraph /testbed && \
    chmod -R 777 /testbed

# Checkout specific commit
RUN cd /testbed && \
    git reset --hard b0958115c1887d93bfd25229b307406920038cc4 && \
    git remote remove origin

# Create virtual environment and install all dependencies in one RUN command
# This preserves PATH and environment variables throughout the installation
# Install local monorepo packages first, then other dependencies
RUN /bin/bash -c "cd /testbed && \
    python3.11 -m uv venv /testbed/.venv --python python3.11 && \
    source /testbed/.venv/bin/activate && \
    uv pip install 'langchain-core>=0.1' && \
    uv pip install -e libs/checkpoint && \
    uv pip install -e 'libs/checkpoint-postgres[dev]' && \
    uv pip install \
    'xxhash>=3.5.0' \
    'pydantic>=2.7.4' \
    pytest \
    pytest-asyncio \
    pytest-cov \
    pytest-dotenv \
    pytest-mock \
    pytest-watcher \
    mypy \
    ruff \
    codespell \
    'pytest-xdist[psutil]' \
    pytest-repeat \
    'psycopg[binary]>=3.2.0' \
    anyio \
    types-requests \
    pycryptodome \
    typing-extensions"

# Set up environment variables for the virtual environment
ENV VIRTUAL_ENV=/testbed/.venv
ENV PATH="/testbed/.venv/bin:$PATH"

# Configure PostgreSQL data directory and permissions
RUN mkdir -p /var/run/postgresql && \
    chmod 777 /var/run/postgresql && \
    mkdir -p /var/lib/postgresql/data && \
    chmod 777 /var/lib/postgresql/data && \
    mkdir -p /var/lib/postgresql && \
    chmod 777 /var/lib/postgresql

# Find the PostgreSQL version and configure it
RUN /bin/bash -c "PG_VERSION=\$(ls /etc/postgresql/ | head -1); \
    if [ -n \"\$PG_VERSION\" ]; then \
        echo \"port = 5441\" >> /etc/postgresql/\$PG_VERSION/main/postgresql.conf; \
        echo \"listen_addresses = 'localhost'\" >> /etc/postgresql/\$PG_VERSION/main/postgresql.conf; \
        echo \"max_connections = 200\" >> /etc/postgresql/\$PG_VERSION/main/postgresql.conf; \
        echo \"shared_buffers = 256MB\" >> /etc/postgresql/\$PG_VERSION/main/postgresql.conf; \
        echo \"local   all     postgres     trust\" > /etc/postgresql/\$PG_VERSION/main/pg_hba.conf; \
        echo \"local   all     all          trust\" >> /etc/postgresql/\$PG_VERSION/main/pg_hba.conf; \
        echo \"host    all     all     127.0.0.1/32    trust\" >> /etc/postgresql/\$PG_VERSION/main/pg_hba.conf; \
        echo \"host    all     all     0.0.0.0/0       trust\" >> /etc/postgresql/\$PG_VERSION/main/pg_hba.conf; \
        echo \"host    all     all     ::1/128         trust\" >> /etc/postgresql/\$PG_VERSION/main/pg_hba.conf; \
    fi"

# Create setup_postgres.sh script using printf (avoids heredoc parsing issues)
RUN printf '%s\n' \
    '#!/bin/bash' \
    'set -e' \
    'echo "Setting up PostgreSQL..."' \
    'if [ ! -d /var/lib/postgresql/data/base ]; then' \
    '    echo "Initializing PostgreSQL cluster..."' \
    '    PG_VERSION=$(ls /etc/postgresql/ | head -1)' \
    '    sudo -u postgres /usr/lib/postgresql/$PG_VERSION/bin/initdb -D /var/lib/postgresql/data -A trust --no-locale' \
    'fi' \
    'echo "Starting PostgreSQL service..."' \
    'sudo service postgresql start' \
    'echo "Waiting for PostgreSQL to be ready..."' \
    'max_attempts=30' \
    'attempt=0' \
    'while [ $attempt -lt $max_attempts ]; do' \
    '    if sudo -u postgres psql -p 5441 -c "SELECT 1" >/dev/null 2>&1; then' \
    '        echo "PostgreSQL is ready on port 5441"' \
    '        break' \
    '    fi' \
    '    attempt=$((attempt + 1))' \
    '    echo "Waiting for PostgreSQL... ($attempt/$max_attempts)"' \
    '    sleep 1' \
    'done' \
    'if [ $attempt -eq $max_attempts ]; then' \
    '    echo "PostgreSQL failed to start after $max_attempts attempts"' \
    '    exit 1' \
    'fi' \
    'echo "PostgreSQL setup complete"' \
    > /testbed/setup_postgres.sh && \
    chmod +x /testbed/setup_postgres.sh

# Allow postgres user to work with the data directory
RUN chown -R postgres:postgres /var/lib/postgresql || true && \
    chown -R postgres:postgres /var/run/postgresql || true

# Configure sudoers to allow necessary PostgreSQL operations without password
RUN /bin/bash -c "echo 'root ALL=(postgres) NOPASSWD: /usr/lib/postgresql/*/bin/initdb' >> /etc/sudoers.d/postgres && \
    echo 'root ALL=(postgres) NOPASSWD: /usr/lib/postgresql/*/bin/psql' >> /etc/sudoers.d/postgres && \
    echo 'root ALL=(root) NOPASSWD: /usr/sbin/service' >> /etc/sudoers.d/postgres && \
    chmod 0440 /etc/sudoers.d/postgres"

# Configure shell to activate venv on startup
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Set shell to bash
SHELL ["/bin/bash", "-c"]

# Expose PostgreSQL port
EXPOSE 5441
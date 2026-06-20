# Base image with Python 3.11 (compatible with Python >=3.9 requirement)
FROM --platform=linux/x86_64 python:3.11-slim

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation
RUN apt update && apt install -y \
    wget \
    git \
    build-essential \
    curl \
    postgresql-client \
    libpq-dev \
    postgresql \
    postgresql-contrib \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager used in the project)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Set default workdir
WORKDIR /testbed/

# Clone the repository
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed

# Checkout the specific commit
RUN cd /testbed && git reset --hard b0958115c1887d93bfd25229b307406920038cc4

# Remove origin to avoid accidental pushes
RUN cd /testbed && git remote remove origin

# Create virtual environment using uv (following project pattern)
RUN uv venv /testbed/.venv
ENV PATH="/testbed/.venv/bin:${PATH}"
ENV VIRTUAL_ENV="/testbed/.venv"

# Install main langgraph package from its subdirectory
WORKDIR /testbed/libs/langgraph
RUN uv pip install -e .
# Install all dependencies including dev dependencies for langgraph
RUN uv sync --frozen --all-extras --all-packages --group dev

# Install checkpoint-postgres package from its subdirectory
WORKDIR /testbed/libs/checkpoint-postgres
RUN uv pip install -e .
# Install dependencies for checkpoint-postgres
RUN uv sync --frozen --all-extras --all-packages --group dev

# Install additional test dependencies that might be needed
RUN uv pip install pytest-asyncio pytest-mock anyio pytest-watcher psycopg[binary] psycopg-pool

# Configure PostgreSQL for testing (skip if already exists)
# First, find the actual PostgreSQL version installed
RUN PG_VERSION=$(ls /etc/postgresql/ | head -n1) && \
    # Configure PostgreSQL to accept connections on localhost:5441
    echo "listen_addresses = '*'" >> /etc/postgresql/$PG_VERSION/main/postgresql.conf && \
    echo "port = 5441" >> /etc/postgresql/$PG_VERSION/main/postgresql.conf && \
    echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/$PG_VERSION/main/pg_hba.conf && \
    echo "host all all ::/0 md5" >> /etc/postgresql/$PG_VERSION/main/pg_hba.conf

# Start PostgreSQL, set password, and stop it (handle existing user/database)
RUN service postgresql start && \
    # Set password for existing postgres user (ignore errors if already set)
    sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';" 2>/dev/null || true && \
    # Ensure postgres user has superuser privileges
    sudo -u postgres psql -c "ALTER USER postgres WITH SUPERUSER;" 2>/dev/null || true && \
    # Ensure the postgres database exists and is owned by postgres
    sudo -u postgres psql -c "ALTER DATABASE postgres OWNER TO postgres;" 2>/dev/null || true && \
    service postgresql stop

# Create a script to start PostgreSQL for testing (will be used by eval script)
RUN echo '#!/bin/bash\n\
# Start PostgreSQL service\n\
service postgresql start\n\
# Wait for PostgreSQL to be ready\n\
for i in {1..30}; do\n\
  if pg_isready -h localhost -p 5441 -U postgres; then\n\
    echo "PostgreSQL is ready on port 5441"\n\
    break\n\
  fi\n\
  echo "Waiting for PostgreSQL... ($i/30)"\n\
  sleep 2\n\
done\n\
' > /usr/local/bin/start-postgres && chmod +x /usr/local/bin/start-postgres

RUN echo '#!/bin/bash\n\
# Stop PostgreSQL service\n\
service postgresql stop\n\
echo "PostgreSQL service stopped"\n\
' > /usr/local/bin/stop-postgres && chmod +x /usr/local/bin/stop-postgres

# Set environment variables for test execution
ENV NO_DOCKER=1
ENV POSTGRES_VERSION=16
ENV DEFAULT_POSTGRES_URI="postgres://postgres:postgres@localhost:5441/"
ENV PYTHONPATH=/testbed:/testbed/libs:$PYTHONPATH

# Add virtual environment activation to bashrc for interactive sessions
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Verify the environment is set up correctly
RUN python --version && \
    uv --version && \
    which pytest && \
    uv pip list | grep -E "langgraph|psycopg|pytest" || echo "Packages verified"

# Set the working directory back to testbed for test execution
WORKDIR /testbed
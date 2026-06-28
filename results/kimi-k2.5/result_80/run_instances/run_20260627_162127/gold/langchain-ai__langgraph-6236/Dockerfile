FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies and tools required for building and running PostgreSQL
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3 \
    python3-dev \
    python-is-python3 \
    libpq-dev \
    ca-certificates \
    wget \
    gnupg \
    lsb-release \
    make \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Generate locale required for PostgreSQL initialization
RUN locale-gen en_US.UTF-8

# Add PostgreSQL 16 official repository (PGDG) and install PostgreSQL with pgvector extension
RUN echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update \
    && apt-get install -y postgresql-16 postgresql-16-pgvector \
    && rm -rf /var/lib/apt/lists/*

# Configure PostgreSQL as postgres user
USER postgres

# Remove any existing data and initialize fresh database cluster
RUN rm -rf /var/lib/postgresql/data/* \
    && /usr/lib/postgresql/16/bin/initdb -D /var/lib/postgresql/data --auth=trust --locale=en_US.UTF-8

# Configure PostgreSQL to listen on port 5441 (as expected by tests) and all interfaces
# Also preload the vector extension library
RUN echo "port = 5441" >> /var/lib/postgresql/data/postgresql.conf \
    && echo "listen_addresses = '*'" >> /var/lib/postgresql/data/postgresql.conf \
    && echo "shared_preload_libraries = 'vector'" >> /var/lib/postgresql/data/postgresql.conf

# Configure pg_hba.conf to allow trust authentication for local connections
RUN echo "host all all 127.0.0.1/32 trust" >> /var/lib/postgresql/data/pg_hba.conf \
    && echo "host all all ::1/128 trust" >> /var/lib/postgresql/data/pg_hba.conf \
    && echo "local all all trust" >> /var/lib/postgresql/data/pg_hba.conf

# Start PostgreSQL temporarily to set password and create pgvector extension, then stop
RUN /usr/lib/postgresql/16/bin/pg_ctl -D /var/lib/postgresql/data -l /var/lib/postgresql/logfile start \
    && sleep 3 \
    && psql -p 5441 -c "ALTER USER postgres WITH PASSWORD 'postgres';" \
    && psql -p 5441 -c "CREATE EXTENSION IF NOT EXISTS vector;" \
    && /usr/lib/postgresql/16/bin/pg_ctl -D /var/lib/postgresql/data stop

# Switch back to root for remaining setup
USER root

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout to the specific commit
ARG COMMIT_SHA=b0958115c1887d93bfd25229b307406920038cc4
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed/ && \
    git reset --hard ${COMMIT_SHA} && \
    git remote remove origin

# Install dependencies for checkpoint-postgres using uv
# This installs the package in editable mode with all dev dependencies
RUN cd /testbed/libs/checkpoint-postgres && \
    uv sync --frozen --group dev

# Ensure the virtual environment is activated by default
ENV PATH="/testbed/libs/checkpoint-postgres/.venv/bin:$PATH"
ENV PGDATA=/var/lib/postgresql/data

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]
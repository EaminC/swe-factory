# Base image: Ubuntu 22.04 with bash
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    curl \
    locales \
    tzdata \
    ca-certificates \
    python3 \
    python3-pip \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

# Install uv and Python 3.12.8 (within Python 3.10-3.13 range)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && export PATH="/root/.local/bin:$PATH" \
    && uv python install 3.12.8

# Set PATH for uv and Python (uv installs to ~/.local/bin)
ENV PATH="/root/.local/bin:$PATH"

# Verify installations
RUN uv --version && python3 --version

# Set default workdir
WORKDIR /testbed/

# Clone repository and checkout target commit
RUN git clone https://github.com/crewAIInc/crewAI /testbed \
    && cd /testbed \
    && git reset --hard 528d81226361be0f87c9e077ed0d3eb28243120f \
    && git remote remove origin

# Create virtual environment using uv (as shown in reference Dockerfile)
RUN uv venv /testbed/.venv
ENV PATH="/testbed/.venv/bin:$PATH"

# Install all workspace dependencies (including dev and all extras)
# This handles all workspace members: lib/crewai, lib/crewai-tools, lib/devtools
RUN cd /testbed && uv sync --dev --all-extras --all-groups

# Verify the crewai package is importable after sync using uv run
RUN cd /testbed && uv run python -c "import crewai; print(f'Successfully imported crewai version: {crewai.__version__ if hasattr(crewai, \"__version__\") else \"unknown\"}')"

# Set environment variables for testing (as per README and CI)
ENV OPENAI_API_KEY=fake-api-key
ENV SERPER_API_KEY=fake-api-key
ENV OTEL_SDK_DISABLED=true
ENV PYTHONUNBUFFERED=1
ENV BRAVE_API_KEY=fake-brave-key
ENV SNOWFLAKE_USER=fake-snowflake-user
ENV SNOWFLAKE_PASSWORD=fake-snowflake-password
ENV SNOWFLAKE_ACCOUNT=fake-snowflake-account
ENV SNOWFLAKE_WAREHOUSE=fake-snowflake-warehouse
ENV SNOWFLAKE_DATABASE=fake-snowflake-database
ENV SNOWFLAKE_SCHEMA=fake-snowflake-schema
ENV EMBEDCHAIN_DB_URI=sqlite:///test.db

# Set up bashrc to persist environment
RUN echo 'source /testbed/.venv/bin/activate' >> /root/.bashrc
RUN echo 'export PATH="/root/.local/bin:$PATH"' >> /root/.bashrc

# Ensure testbed is writable
RUN chmod -R 777 /testbed
# Base image with Python 3.12 pre-installed
FROM --platform=linux/x86_64 python:3.12-slim

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install essential system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    make \
    jq \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install uv package manager
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Set working directory
WORKDIR /testbed/

# Clone the langgraph repository
RUN git clone https://github.com/langchain-ai/langgraph /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard d68bac386564054cf6a572064f46c55186219041 && \
    git remote remove origin

# Create virtual environment using uv
RUN uv venv /testbed/.venv

# Install core dependencies from PyPI that are required by langgraph
RUN /bin/bash -c "source /testbed/.venv/bin/activate && \
    uv pip install \
    'langchain-core>=0.1' \
    'pydantic>=2.7.4' \
    'pytest' \
    'pytest-asyncio' \
    'pytest-cov' \
    'pytest-dotenv' \
    'pytest-mock' \
    'pytest-xdist[psutil]' \
    'pytest-repeat' \
    'syrupy' \
    'httpx' \
    'mypy' \
    'ruff' \
    'types-requests' \
    'uvloop==0.21.0b1' \
    'pyperf' \
    'py-spy' \
    'pycryptodome' \
    'psycopg[binary]' \
    'hatchling'"

# Install local editable dependencies in correct order
# Install checkpoint packages first (they are dependencies of langgraph)
RUN /bin/bash -c "source /testbed/.venv/bin/activate && \
    cd /testbed && \
    uv pip install -e ./libs/checkpoint && \
    uv pip install -e './libs/checkpoint-sqlite' && \
    uv pip install -e './libs/checkpoint-postgres'"

# Install SDK packages
RUN /bin/bash -c "source /testbed/.venv/bin/activate && \
    cd /testbed && \
    uv pip install -e './libs/sdk-py'"

# Install prebuilt package
RUN /bin/bash -c "source /testbed/.venv/bin/activate && \
    cd /testbed && \
    uv pip install -e './libs/prebuilt'"

# Install CLI package
RUN /bin/bash -c "source /testbed/.venv/bin/activate && \
    cd /testbed && \
    uv pip install -e './libs/cli[inmem]'"

# Install the main langgraph package in editable mode
# This will install langgraph and pull in its declared dependencies from pyproject.toml
RUN /bin/bash -c "source /testbed/.venv/bin/activate && \
    cd /testbed && \
    uv pip install -e './libs/langgraph'"

# Setup bash profile to activate venv
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Set default shell to bash
SHELL ["/bin/bash", "-c"]

# Default command to keep container running
CMD ["/bin/bash"]
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies including git, curl, build tools, and Python development headers
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3 \
    python3-dev \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Astral's Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Set default shell to bash for compatibility
SHELL ["/bin/bash", "-c"]

# Clone repository and checkout specific commit
WORKDIR /testbed/
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed && \
    git reset --hard 220314b53a960964a82657451b846f3a7cb2f348 && \
    git remote remove origin && \
    chmod -R 777 /testbed

# Install project dependencies using uv
# The langgraph package is located in libs/langgraph with local editable dependencies in sibling directories
WORKDIR /testbed/libs/langgraph
RUN uv sync --frozen --all-extras --all-packages --group dev

# Set final workdir to testbed root as required
WORKDIR /testbed/
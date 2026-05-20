# Base image with bash and general utilities
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Set default shell to bash explicitly
SHELL ["/bin/bash", "-c"]

# Install system dependencies including docker CLI for tests that require docker commands
RUN apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    curl \
    ca-certificates \
    locales \
    tzdata \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# Make python3 point to python3.11 explicitly and install pip for python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install uv tool (uv cli for venv and dependency sync) using pip globally
RUN pip install uv

# Create working directory
WORKDIR /testbed/

# Clone the repository and checkout specific commit
ARG COMMIT_SHA=d68bac386564054cf6a572064f46c55186219041
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed && \
    git reset --hard $COMMIT_SHA

# Setup Python virtual environment using uv venv and install dependencies via uv sync and poetry
RUN /bin/bash -c " \
    uv venv -p python3 && \
    source .venv/bin/activate && \
    cd libs/langgraph && \
    uv sync --frozen --group dev && \
    pip install -e . && \
    cd ../.. \
"

# Configure bash to activate the virtual environment when opening the container shell
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Set workdir as requested
WORKDIR /testbed/

# No CMD or ENTRYPOINT because tests are run later by the eval script
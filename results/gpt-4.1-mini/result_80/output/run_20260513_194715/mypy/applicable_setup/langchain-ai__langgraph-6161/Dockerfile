# Use a stable Ubuntu base image with bash
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies needed for development, runtime, and PostgreSQL server
RUN apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    libffi-dev \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    curl \
    locales \
    locales-all \
    tzdata \
    postgresql \
    postgresql-contrib \
    && rm -rf /var/lib/apt/lists/*

# Initialize PostgreSQL database cluster (required for the first use)
RUN service postgresql start && \
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';" && \
    service postgresql stop

# Upgrade pip to the latest version using system pip3 
RUN pip3 install --upgrade pip

# Create virtual environment named 'testbed'
RUN python3.10 -m venv /opt/testbed

# Remove old /testbed directory if exists
RUN rm -rf /testbed

# Clone repository into /testbed
RUN git clone https://github.com/langchain-ai/langgraph /testbed

# Checkout specific commit
RUN cd /testbed && git reset --hard 328129e5bd01805ed9a2c925df4d02d065e9ac15

# List files in libs/langgraph to confirm presence of project files
RUN ls -la /testbed/libs/langgraph

# Set working directory to libs/langgraph where pyproject.toml is located
WORKDIR /testbed/libs/langgraph

# Install 'uv' tool first to be able to run uv sync for dependencies
RUN /bin/bash -c "source /opt/testbed/bin/activate && pip install uv"

# Sync dependencies with uv and install all dev dependencies inside libs/langgraph
RUN /bin/bash -c "source /opt/testbed/bin/activate && uv sync --frozen --group dev"

# Install the langgraph package itself in editable mode inside libs/langgraph
RUN /bin/bash -c "source /opt/testbed/bin/activate && pip install -e ."

# Ensure bash autoloads the virtual environment by default
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

ENV VIRTUAL_ENV=/opt/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
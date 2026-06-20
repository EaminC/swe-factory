# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation. Installs essential tools and libraries required for development and runtime (Required)
RUN apt update && apt install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    libtiff-dev \
    python3 \
    python3-pip \
    python-is-python3 \
    jq \
    curl \
    locales \
    locales-all \
    tzdata \
    docker.io \
    docker-compose \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager) as per project requirements - install via pip
RUN pip install uv

# Create a Python virtual environment using uv (as per project's development setup)
RUN uv venv /testbed_venv --python 3.11
ENV PATH="/testbed_venv/bin:${PATH}"

# Set default workdir to testbed. (Required)
WORKDIR /testbed/

# Target Project setup. Clones source code, checkouts to the target version
RUN git clone https://github.com/langchain-ai/langgraph /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard 5212369bd0791806083f183cb19ccce024db8790 && \
    git remote remove origin

# Install project dependencies using uv (as per project's development setup)
RUN cd /testbed && \
    # Install dependencies for all libs/* projects that have pyproject.toml
    for dir in libs/*; do \
        if [ -f "${dir}/pyproject.toml" ]; then \
            echo "Installing dependencies for ${dir}"; \
            cd "${dir}" && uv pip install -e . && cd /testbed; \
        fi; \
    done

# Install test dependencies for the prebuilt library specifically
RUN cd /testbed/libs/prebuilt && \
    # Install test dependencies using uv
    uv pip install -e .[test]

# Set up environment variables for test execution
ENV LANGGRAPH_TEST_FAST=0
ENV PYTHONPATH="/testbed:${PYTHONPATH}"

# Add uv virtual environment activation to bashrc for interactive sessions
RUN echo "source /testbed_venv/bin/activate" >> /root/.bashrc
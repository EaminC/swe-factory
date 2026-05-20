FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies required for python development, git, and build tools
RUN apt-get update && apt-get install -y \
    git \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    curl \
    build-essential \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 and pip point to python3.10 and corresponding pip
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10

# Create the work directory
WORKDIR /testbed/

# Clone repository and checkout the specific commit
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    git reset --hard c29bdded396eff9a47aa36643ce1169b2ebf5318

# Create and activate python virtual environment, install dependencies in editable mode
RUN python3.10 -m venv testbed && \
    source testbed/bin/activate && \
    pip install --upgrade pip wheel setuptools && \
    pip install -e . && \
    pip install pytest pytest-forked

# Add the virtual environment activate script to bashrc for convenience
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc
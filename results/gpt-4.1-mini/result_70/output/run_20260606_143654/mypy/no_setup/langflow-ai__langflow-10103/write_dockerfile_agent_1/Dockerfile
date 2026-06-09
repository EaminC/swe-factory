# Use Ubuntu 22.04 as base image for stability and bash shell availability
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies, git, curl, python3.10+, pip, nodejs 22.x, npm 10.x, and build tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    wget \
    ca-certificates \
    locales \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Setup locales to avoid locale warnings/errors
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install pip for python3.10
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10

# Install Node.js 22.12 LTS and npm 10.9 from NodeSource official repository
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@10.9.0 \
    && rm -rf /var/lib/apt/lists/*

# Install uv (uvicorn) as a standalone tool using npm as per context
RUN npm install -g uv@^0.4

# Create working directory and clone the target repository
WORKDIR /testbed/

RUN git clone https://github.com/langflow-ai/langflow.git /testbed/ \
    && git reset --hard 58efe809d4dad3decc833afd2f29b9a1038f6d5c

# Create Python virtual environment named "testbed"
RUN python3.10 -m venv /testbed/testbed

# Upgrade pip and setuptools inside the virtual environment
RUN /testbed/testbed/bin/pip install --upgrade pip setuptools

# Install repository dependencies and dev dependencies via pip inside virtual environment:
# - Install the repo itself in editable mode (development mode)
# - Also run "make init" as per context initialization command, which may install dependencies
# As no direct requirements files are copied, run `make init` should take care of deps,
# so run it under the venv with environment activated.
RUN /bin/bash -c "source /testbed/testbed/bin/activate \
    && make init \
    && pip install -e ."

# Install development tools and hooks specified in context (pre-commit)
RUN /bin/bash -c "source /testbed/testbed/bin/activate \
    && uv sync \
    && uv run pre-commit install"

# Set environment variables so bash shell activates venv automatically when running container interactively
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

ENV PATH="/testbed/testbed/bin:$PATH"

# Ready to run tests via `uv run pytest <test_file>` as per testing commands in context,
# no entrypoint or CMD set per instructions
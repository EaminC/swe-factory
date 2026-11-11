# Use a stable Ubuntu base image with bash available
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install essential system packages and tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3-pip \
    python3.10-distutils \
    locales \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Ensure python points to python3.10
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# Upgrade pip
RUN python -m pip install --upgrade pip

# Create workdir
WORKDIR /testbed/

# Clone the repository and checkout the specified commit
ARG COMMIT_SHA=2b8e056d5d4d14665b88a01c41356253c94b9259
RUN git clone https://github.com/AntonOsika/gpt-engineer /testbed/ && \
    git reset --hard $COMMIT_SHA && \
    chmod -R a+rwx /testbed/

# Setup virtual environment named `testbed`
RUN python -m venv /testbed/venv

# Activate virtualenv and install project dependencies and dev dependencies
# Using bash to source the virtualenv activate script
RUN /bin/bash -c "\
    source /testbed/venv/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install -e . && \
    pip install pytest pytest-cov black==23.3.0 click mypy==1.3.0 openai==0.27.8 pre-commit==3.3.3 ruff==0.0.272 termcolor==2.3.0 typer rudder-sdk-python==2.0.2 dataclasses-json==0.5.7 tabulate==0.9.0 \
    "

# Set environment variables for bash shell sessions in container
ENV VIRTUAL_ENV=/testbed/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Default shell to bash
SHELL ["/bin/bash", "-c"]

# Set workdir explicitly again
WORKDIR /testbed/

# Do not run tests here, tests will be run separately by eval script

# Container is ready with environment and project installed in editable mode
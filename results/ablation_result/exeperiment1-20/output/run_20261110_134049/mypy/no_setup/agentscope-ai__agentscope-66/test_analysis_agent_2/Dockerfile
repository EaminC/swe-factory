# Use ubuntu 22.04 as base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies including default python3, git, pip, and other essential tools
RUN apt-get update && apt-get install -y \
    python3 python3-venv python3-pip python3-distutils \
    git wget build-essential curl locales locales-all tzdata \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN python3 -m pip install --upgrade pip setuptools wheel

# Create working directory
WORKDIR /testbed/

# Clone the repository and checkout specified commit (use ARG for commit SHA)
ARG COMMIT_SHA=0b4bf85481d3cde1f4a5f16d6faeb6e9c9d2a49c

# Clone repo, checkout commit
RUN git clone https://github.com/agentscope-ai/agentscope /testbed && \
    cd /testbed && \
    git reset --hard ${COMMIT_SHA}

# Create and activate virtual environment, install the repository in editable mode with full extras and test dependencies
RUN python3 -m venv testbed-venv && \
    source testbed-venv/bin/activate && \
    pip install -q -e ".[full]" && \
    pip install coverage pytest pytest-cov pre-commit

# Add virtual environment activation to bashrc for default shell sessions
RUN echo "source /testbed/testbed-venv/bin/activate" >> /root/.bashrc

# Default workdir as requested
WORKDIR /testbed/

# Do not run tests or add entrypoint as per instructions
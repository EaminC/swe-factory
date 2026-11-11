# Use Ubuntu 22.04 as base image for compatibility and stability
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Update and install git, curl, build essentials, and Python 3.10 with venv and pip in smaller steps
RUN apt-get update && apt-get install -y git curl build-essential
RUN apt-get install -y python3.10 python3.10-venv python3-pip python3-distutils
RUN rm -rf /var/lib/apt/lists/*

# Upgrade pip in system python
RUN python3.10 -m pip install --upgrade pip setuptools wheel

# Install Rust toolchain using official Rust installation script for stability
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Create workdir and clone target repo
WORKDIR /testbed
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed

# Checkout the specific commit SHA via build argument
ARG COMMIT_SHA=99133104dd1a3f77a8558aa882243d702893a1ca
RUN cd /testbed && git reset --hard ${COMMIT_SHA}

# Ensure the directory for virtual environment exists before creating venv
RUN mkdir -p /testbed/testbed

# Setup python virtual environment named "testbed" using python3.10 venv
RUN python3.10 -m venv /testbed/testbed

# Upgrade pip inside venv, install 'uv' package (the correct package for uv tool), then use uv commands
RUN /testbed/testbed/bin/pip install --upgrade pip setuptools wheel uv

RUN source /testbed/testbed/bin/activate && \
    uv lock && \
    uv sync && \
    uv venv

# Install crewai package extras inside venv (without installing base crewai from PyPI as repo installed later)
RUN /testbed/testbed/bin/pip install 'crewai[tools]' --use-feature=fast-deps || true

# Install tiktoken with pre-built binary wheel (Rust is installed already)
RUN /testbed/testbed/bin/pip install --prefer-binary tiktoken

# Install the cloned repo in editable mode to ensure local source is used
RUN source /testbed/testbed/bin/activate && \
    pip install -e .

# Append virtual environment activation to root bashrc for convenience
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

# Final working directory
WORKDIR /testbed

# No ENTRYPOINT or CMD: testing is done after build
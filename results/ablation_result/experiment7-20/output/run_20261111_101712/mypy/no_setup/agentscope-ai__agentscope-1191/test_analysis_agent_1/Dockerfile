# Use Ubuntu 22.04 as base image for stability and bash support
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies including git, python3.10, python3-pip, build tools
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install pip for python3.10 explicitly (in case default pip points to other python)
RUN python3.10 -m pip install --upgrade pip

# Create a python virtual environment named testbed and activate it
RUN python3.10 -m venv /opt/testbed

ENV VIRTUAL_ENV=/opt/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Upgrade pip and setuptools inside the virtualenv and install dev dependencies for the repo
RUN pip install --upgrade pip setuptools wheel

# Set workdir to /testbed as required
WORKDIR /testbed

# Clone the repository, checkout the specific commit, remove origin remote for safety
ARG COMMIT_SHA=9745c308740712f2734c0b3d04e27dd02ceaead3
RUN git clone https://github.com/agentscope-ai/agentscope.git . && \
    git reset --hard $COMMIT_SHA && \
    git remote remove origin

# Install the repository in editable mode with dev extras which include pytest and coverage
RUN pip install -e ".[dev]"

# Install pre-commit separately as test instructions require it for precommit hooks usage
RUN pip install pre-commit

# Print environment variable instructions for users to know which env vars are expected
ENV DASHSCOPE_API_KEY=""
ENV GAODE_API_KEY=""

# Add bashrc line to activate virtual environment on container launch (interactive)
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Default shell is bash
SHELL ["/bin/bash", "-c"]
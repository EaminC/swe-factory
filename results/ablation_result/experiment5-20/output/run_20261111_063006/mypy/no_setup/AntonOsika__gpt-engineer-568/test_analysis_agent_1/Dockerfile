FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies, essential tools and python 3.10
RUN apt update && apt install -y \
    wget \
    git \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    python3-pip \
    python3-distutils \
    curl \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip for python3.10
RUN python3.10 -m pip install --upgrade pip setuptools wheel

WORKDIR /testbed/

# Clone the target repo and checkout to specific commit SHA ARG
ARG COMMIT_SHA=f84754d54ee311146c4f52b5e3ceb0fa8d0b731b
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed && \
    git reset --hard $COMMIT_SHA && \
    git remote remove origin

# Create Python virtual environment with python3.10 and activate it
RUN python3.10 -m venv /testbed/testbed
ENV PATH="/testbed/testbed/bin:$PATH"

# Install project dependencies:
# 1) Install package itself in editable mode to link local code
# 2) Install testing dependencies pytest and pytest-cov as requested
RUN pip install --upgrade pip setuptools wheel && \
    pip install -e . && \
    pip install pytest pytest-cov

# Add environment variable note that OPENAI_API_KEY must be set at runtime
ENV OPENAI_API_KEY=""

# Ensure bash rc activates the environment for interactive sessions
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

# Set workdir
WORKDIR /testbed/
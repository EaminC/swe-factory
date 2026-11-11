FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies, essential tools, and python 3.10
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

# Upgrade pip, setuptools, and wheel for python3.10
RUN python3.10 -m pip install --upgrade pip setuptools wheel

WORKDIR /testbed/

# Clone the target repo and checkout the specific commit SHA ARG
ARG COMMIT_SHA=f84754d54ee311146c4f52b5e3ceb0fa8d0b731b
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed && \
    git reset --hard $COMMIT_SHA && \
    git remote remove origin

# Create Python virtual environment and activate it
RUN python3.10 -m venv /testbed/testbed
ENV PATH="/testbed/testbed/bin:$PATH"

# Install project dependencies:
# - Install the package itself in editable mode to link local code
# - Explicitly install runtime dependencies like langchain (due to ModuleNotFoundError)
# - Install testing dependencies pytest and pytest-cov
RUN pip install --upgrade pip setuptools wheel && \
    pip install -e . && \
    pip install langchain pytest pytest-cov

# Add environment variable placeholder for runtime (to be set when container runs)
ENV OPENAI_API_KEY=""

# Ensure bashrc activates the virtual environment for interactive shells
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

# Set working directory
WORKDIR /testbed/
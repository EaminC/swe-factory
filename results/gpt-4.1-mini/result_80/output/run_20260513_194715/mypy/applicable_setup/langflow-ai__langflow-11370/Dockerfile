FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and essential tools, but remove conflicting older node packages first
RUN apt-get update && apt-get remove -y libnode-dev npm nodejs-doc nodejs \
    && apt-get install -y \
    git \
    make \
    curl \
    wget \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set locale to avoid potential locale warnings
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Node.js 22.12 LTS and npm 10.9 via Nodesource after removing old packages to avoid file conflicts
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@10.9.0 \
    && node -v && npm -v

# Alias python to python3.11 explicitly
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Upgrade pip and install uv command line tool globally with pip for python3.11
RUN python -m pip install --upgrade pip setuptools wheel
RUN python -m pip install uv>=0.4

# Set working directory
WORKDIR /testbed/

# Clone the repository, checkout specific commit and install dependencies
RUN git clone https://github.com/langflow-ai/langflow /testbed \
    && cd /testbed \
    && git reset --hard 1529f56bf4fb392bb27ae65442b519f1eff744b7

# Create and activate Python virtual environment
RUN python -m venv /testbed/.venv
ENV PATH="/testbed/.venv/bin:$PATH"

# Install project dependencies and initialize environment using make and uv
RUN make init \
    && uv sync \
    && uv run pre-commit install

# Export environment variable for testing development mode
ENV LFX_DEV=1

# Install the local repository in development mode
RUN pip install -e .

# Final working directory is /testbed
WORKDIR /testbed/
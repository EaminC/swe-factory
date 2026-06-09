# Use a stable Ubuntu base image to avoid issues with base image corruption
FROM --platform=linux/x86_64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies including git, python3, pip, chromium-browser, fonts, and build tools needed for complex dependencies
# Do NOT install nodejs or npm here to avoid conflicts with NodeSource installation later
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    curl \
    ca-certificates \
    locales \
    locales-all \
    tzdata \
    chromium-browser \
    fonts-liberation \
    libgomp1 \
    libxss1 \
    python3 \
    python3-venv \
    python3-distutils \
    python3-pip \
    build-essential \
    gcc \
    libffi-dev \
    libssl-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, wheel, and virtualenv to latest compatible versions
RUN python3 -m pip install --upgrade pip setuptools wheel virtualenv

# Remove any existing nodejs, npm, libnode-dev packages if present (precautionary)
RUN apt-get remove -y nodejs npm libnode-dev || true

# Install Node.js 20 from NodeSource to ensure correct version without conflicts
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g @mermaid-js/mermaid-cli \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set environment variables for Chromium needed by MetaGPT
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Set working directory for repository clone
WORKDIR /testbed/

# Clone the repository and checkout the specified commit
ARG REPO=https://github.com/FoundationAgents/MetaGPT.git
ARG COMMIT_SHA=22e100912839965231144ae25790d643180ddc57

RUN git clone ${REPO} . \
    && git reset --hard ${COMMIT_SHA}

# Create Python virtual environment in /opt/testbed
RUN python3 -m venv /opt/testbed

# Install python dependencies inside the virtual environment:
# First install based on requirements.txt if present, then install the package in editable mode
RUN source /opt/testbed/bin/activate \
    && pip install --upgrade pip \
    && if [ -f requirements.txt ]; then pip install --use-feature=fast-deps -r requirements.txt; fi \
    && pip install -e .

# Add activation of virtual environment to root bashrc
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Default working directory
WORKDIR /testbed/
# Base image specification
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    libtiff-dev \
    libssl-dev \
    libffi-dev \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    python-is-python3 \
    jq \
    curl \
    locales \
    locales-all \
    tzdata \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set up Python 3.11 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Upgrade pip, setuptools, and wheel
RUN python -m pip install --upgrade pip setuptools wheel

# Set default workdir to testbed
WORKDIR /testbed/

# Target Project setup - Clone and checkout to specific commit
RUN git clone https://github.com/strands-agents/sdk-python /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard 776fd93751cc26e3d535776b17612c2e3068cc2b && \
    git remote remove origin

# Install core dependencies explicitly with verbose output
RUN python -m pip install --verbose \
    anthropic \
    openai \
    'pydantic>=2.0' \
    pydantic-settings \
    litellm \
    python-dotenv \
    httpx

# Install the project in development mode with all dev dependencies
RUN python -m pip install --verbose -e ".[dev]"

# Set bash as default shell
RUN echo "#!/bin/bash" > /root/.bashrc && \
    echo "cd /testbed" >> /root/.bashrc

CMD ["/bin/bash"]
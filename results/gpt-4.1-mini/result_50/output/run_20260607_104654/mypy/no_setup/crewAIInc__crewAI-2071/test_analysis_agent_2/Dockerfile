# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# System dependencies installation. Installs essential tools and libraries required for development and runtime (Required)
RUN apt update && apt install -y \
    git \
    curl \
    build-essential \
    libffi-dev \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    wget \
    locales \
    locales-all \
    tzdata \
    pkg-config \
    ca-certificates \
    gcc \
    musl-dev \
    rustc \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.11, pip is installed for python3.11, and upgrade pip
RUN ln -sf /usr/bin/python3.11 /usr/bin/python3 \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3 \
    && python3 -m pip install --upgrade pip wheel setuptools

# Install UV environment manager (using official install script) and add uv to PATH immediately
RUN curl -fsSL https://raw.githubusercontent.com/Astral-sh/uv/main/install.sh | bash && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> /root/.bashrc && \
    export PATH="$HOME/.local/bin:$PATH" && uv --version

# Set working directory
WORKDIR /testbed/

# Clone repository and checkout specific commit
RUN git clone https://github.com/crewAIInc/crewAI /testbed \
    && git reset --hard b6d668fc664c5f376626f06acdf48f9f462884e2 \
    && git remote remove origin

# Create and activate UV virtual environment named 'testbed', install dependencies, and install repo in editable mode.
RUN export PATH="$HOME/.local/bin:$PATH" && \
    uv venv create testbed && \
    echo 'source ~/.bashrc' >> ~/.bash_profile && \
    uv activate testbed && \
    pip install --prefer-binary tiktoken && \
    pip install 'crewai[tools]' && \
    pip install -e .

# Append command to .bashrc to activate uv venv 'testbed' on new shell sessions
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> /root/.bashrc && \
    echo 'source ~/.bashrc && uv activate testbed' >> /root/.bashrc

# Set default shell to bash
ENV SHELL=/bin/bash
FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
SHELL ["/bin/bash", "-c"]

# Install essential system packages and dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    locales \
    tzdata \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    make \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Setup python3 alias to python3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Install Poetry 1.8.2 using the official installer
RUN curl -sSL https://install.python-poetry.org | python3.10 - --version 1.8.2
ENV PATH="/root/.local/bin:$PATH"

# Install Node.js 22.12 LTS and npm 10.9.0
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y nodejs \
 && npm install -g npm@10.9.0 \
 && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/langflow-ai/langflow.git /testbed/ \
 && git reset --hard 2a95b52e06769d70fd9f0671cfcc6734ee41f0ef \
 && git remote remove origin

# Setup python virtual environment inside /testbed, upgrade tooling, and install dependencies
RUN python3.10 -m venv venv \
 && . venv/bin/activate \
 && pip install --upgrade pip setuptools wheel \
 && poetry config virtualenvs.create false \
 && poetry install --no-interaction --no-ansi \
 && pip install -e .

# Install uv CLI tool used by developer setup
RUN . /testbed/venv/bin/activate && pip install "uv>=0.4"

# Install frontend dependencies
RUN . /testbed/venv/bin/activate && cd src/frontend && npm install

# Ensure virtual environment is activated on shell startup
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc

# Use bash as default shell
ENV SHELL=/bin/bash
ENV PATH="/testbed/venv/bin:$PATH"
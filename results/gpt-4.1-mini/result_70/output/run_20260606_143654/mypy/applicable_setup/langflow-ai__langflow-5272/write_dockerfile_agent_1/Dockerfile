FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system packages and dependencies
RUN apt update && apt install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Setup python3 alias to python3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Upgrade pip and install virtualenv
RUN python3 -m pip install --upgrade pip setuptools wheel virtualenv

# Create and activate virtual environment
RUN python3 -m virtualenv /testbed/venv

ENV VIRTUAL_ENV=/testbed/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/langflow-ai/langflow.git /testbed/
WORKDIR /testbed/
RUN git reset --hard 2a95b52e06769d70fd9f0671cfcc6734ee41f0ef

# Install project dependencies from pyproject.toml / setup environment
# Because the context notes a variety of dependencies and a Poetry version,
# install Poetry to manage dependencies properly
RUN python3 -m pip install "poetry==1.8.2"

# Configure Poetry to create virtual envs inside the project to keep isolated but we use the global venv 
RUN poetry config virtualenvs.create false

# Install python dependencies
RUN poetry install --no-interaction --no-ansi --no-root

# Install the repository in editable mode and dependencies via poetry
# Then explicitly install the repo itself in development mode to ensure local code usage
RUN pip install -e .

# Install uv for CLI commands (required by developer setup)
RUN pip install "uv>=0.4"

# Install nodejs 22.12 LTS and npm 10.9 as required by developer setup
# Using NodeSource for Node 22.x
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
  && apt-get install -y nodejs \
  && npm install -g npm@10.9.0

# Install make utility
RUN apt-get update && apt-get install -y make && rm -rf /var/lib/apt/lists/*

# Use bash as default shell and ensure environment activates virtualenv on startup
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc

WORKDIR /testbed/
# Use Ubuntu 22.04 as a base image with bash shell and default architecture
FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, curl, build-essential, python3.10, python3.10-venv, python3.10-distutils, python3-pip, and other essentials
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    wget \
    ca-certificates \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set python3 and pip3 alternatives to python3.10 and pip3 accordingly
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
    && python3 -m pip install --upgrade pip setuptools wheel

# Install poetry via official installer (recommended approach) with PATH set to include poetry binaries
ENV POETRY_HOME=/opt/poetry
ENV PATH="$POETRY_HOME/bin:$PATH"
RUN curl -sSL https://install.python-poetry.org | python3 - \
    && ln -s $POETRY_HOME/bin/poetry /usr/local/bin/poetry

# Clone the target repository and checkout the specified commit SHA (build argument) BEFORE switching user
ARG REPO=https://github.com/langflow-ai/langflow.git
ARG COMMIT_SHA=4c43b4cc82e02dd0dd2d58992618195521bdc865
RUN git clone ${REPO} /testbed \
    && cd /testbed \
    && git reset --hard ${COMMIT_SHA} \
    && chown -R 1000:1000 /testbed

# Create a dedicated user for safer operations (optional but good practice)
RUN useradd -m testuser
USER testuser
ENV HOME=/home/testuser
WORKDIR /testbed/

# Ensure that poetry is in PATH for testuser as well
ENV PATH="$POETRY_HOME/bin:$HOME/.local/bin:$PATH"

# Install dependencies using poetry in virtual environment
# Create virtual environment named 'testbed' in home directory, configure poetry to use this venv, then install project dependencies including dev packages
RUN python3 -m venv $HOME/testbed \
    && source $HOME/testbed/bin/activate \
    && poetry config virtualenvs.create false --local \
    && poetry install --no-interaction --no-ansi --with dev

# Expose environment variables instruction to set OPENAI_API_KEY etc at container runtime (no default value set here)
ENV PATH="$HOME/testbed/bin:$PATH"
ENV PYTHONPATH=/testbed

# Append environment variable setup and venv activation to bashrc for convenience when shell is opened interactively
RUN echo "source $HOME/testbed/bin/activate" >> $HOME/.bashrc

# Final working directory setup
WORKDIR /testbed/
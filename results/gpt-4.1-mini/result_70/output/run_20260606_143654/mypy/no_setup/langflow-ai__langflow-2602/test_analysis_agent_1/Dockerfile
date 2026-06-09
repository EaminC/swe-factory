# Use a stable Ubuntu base image with bash available by default
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, curl, build essentials, python3.10, python3.10-venv, python3.10-distutils, wget, and other tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    wget \
    ca-certificates \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install pip for python3.10
RUN curl -sS https://bootstrap.pypa.io/pip/3.10/get-pip.py | python3.10

# Install Poetry 1.8.2 via official install script and set PATH
RUN curl -sSL https://install.python-poetry.org | POETRY_VERSION=1.8.2 python3.10 - && \
    ln -s /root/.local/bin/poetry /usr/local/bin/poetry

# Create a python virtual environment named 'testbed'
RUN python3.10 -m venv /opt/testbed
ENV PATH="/opt/testbed/bin:$PATH"

# Configure locale (optional but recommended)
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Clone the target repository and checkout the given commit SHA
ARG REPO_COMMIT_SHA=4c43b4cc82e02dd0dd2d58992618195521bdc865
RUN git clone https://github.com/langflow-ai/langflow /testbed && \
    cd /testbed && \
    git reset --hard ${REPO_COMMIT_SHA} && \
    git remote remove origin

WORKDIR /testbed

# Install python dependencies using poetry in the virtual environment
# Configure poetry to not create virtualenv since we use system venv
RUN poetry config virtualenvs.create false

# Install project dependencies and the project itself in editable (development) mode
RUN poetry install --no-interaction --no-ansi --no-root && \
    pip install -e .

# Append poetry and venv environment activation in bashrc for convenience
RUN echo 'export PATH="/opt/testbed/bin:$PATH"' >> /root/.bashrc && \
    echo 'poetry config virtualenvs.create false' >> /root/.bashrc

# Set environment variable placeholder for OPENAI_API_KEY (to be injected at runtime)
ENV OPENAI_API_KEY=""

# Default shell is bash
CMD ["/bin/bash"]
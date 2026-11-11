# Use a stable Ubuntu base image with bash
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install essential system dependencies, git, curl, wget, python3.10 and build tools
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    python3.10-dev \
    locales \
    locales-all \
    tzdata \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Set default python alternative to python3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Install Poetry (dependency manager)
RUN curl -sSL https://install.python-poetry.org | python3 -

ENV PATH="/root/.local/bin:$PATH"

# Clone the repository, checkout the given commit, install dependencies with Poetry and install the local package in editable dev mode
WORKDIR /testbed/
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed && \
    git reset --hard 3e589bf1356024fb471a9d17738e4626f21a953b

# Install dependencies and dev dependencies via Poetry without running tests, install project in editable mode
RUN poetry config virtualenvs.create true && \
    poetry config virtualenvs.in-project true && \
    poetry install --no-root --only main,dev && \
    # Install the package in editable mode (linked)
    /bin/bash -c "source /testbed/.venv/bin/activate && pip install -e ."

# Set default shell as bash
SHELL ["/bin/bash", "-c"]

# Default workdir
WORKDIR /testbed/

# Expose HOME environment to ensure Poetry and virtual env works smoothly
ENV HOME=/root

# Provide a bashrc line to activate poetry shell (virtual env) automatically for convenience during interactive use
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc
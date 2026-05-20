FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Install essential system packages including git, curl, build tools, python3.11, and pip
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    git \
    build-essential \
    locales \
    tzdata \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Set timezone by linking; avoid setting TZ env variable during build to prevent image resolution issues
RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# Set locale environment variables without running locale-gen explicitly
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Python 3.11 from deadsnakes PPA for newest supported python version (3.11 in supported range)
RUN add-apt-repository ppa:deadsnakes/ppa -y && apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    && rm -rf /var/lib/apt/lists/*

# Install pip for python3.11
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

# Install poetry - official recommended installer, placing poetry in PATH
ENV POETRY_HOME="/opt/poetry"
ENV PATH="$POETRY_HOME/bin:$PATH"
RUN curl -sSL https://install.python-poetry.org | python3.11 -

# Create working directory and clone the repository
WORKDIR /testbed/
RUN git clone https://github.com/AntonOsika/gpt-engineer.git . && \
    git reset --hard 04c71d7d297447479d897b6803206210ed589d53

# Install project dependencies using poetry, disabling virtualenv creation to use system Python environment
RUN poetry config virtualenvs.create false && poetry install --no-interaction --no-ansi --no-root

# Set default shell to bash
ENV SHELL=/bin/bash

# Note: OPENAI_API_KEY must be provided at container runtime
# No tests are run at build time within this Dockerfile
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and essential tools
RUN apt update && apt install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set python3 to point to python3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install poetry (preferred for project dependency management)
RUN python3 -m pip install poetry

WORKDIR /testbed/

# Clone the target repository and checkout the specified commit
ARG REPO=https://github.com/AntonOsika/gpt-engineer.git
ARG COMMIT_SHA=c1f4a9da5dd0abed15b91f6d1c60464cad84ce6c
RUN git clone ${REPO} . && \
    git checkout ${COMMIT_SHA}

# Install project dependencies using poetry, then install the project itself in development mode
RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi && \
    python3 -m pip install -e .

# Set up bashrc to activate environment if needed (poetry without venv, so just shell)
RUN echo "export PATH=\"$(python3 -m site --user-base)/bin:\$PATH\"" >> /root/.bashrc

# Final working directory
WORKDIR /testbed/
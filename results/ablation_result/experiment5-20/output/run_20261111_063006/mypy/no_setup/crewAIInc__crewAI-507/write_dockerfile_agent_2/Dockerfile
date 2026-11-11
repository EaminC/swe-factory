FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# System dependencies installation.
RUN apt update && apt install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    curl \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install pip for python3.11
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

# Upgrade pip and install poetry (per repo instructions)
RUN python3.11 -m pip install --upgrade pip \
    && python3.11 -m pip install poetry==1.8.1

# Clone the repository and checkout specific commit
WORKDIR /testbed/
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed/ \
    && git reset --hard 3d5257592b440fca8c46b77471e1c34c901ee57f \
    && git remote remove origin

# Fix poetry.lock mismatch by updating the lock file without updating dependencies
RUN poetry lock --no-update

# Install dependencies and project in editable mode using Poetry, without virtualenvs
RUN poetry config virtualenvs.create false \
    && poetry install --no-root --no-interaction --no-ansi

# Install the local repo in editable mode to ensure tests run against local code
RUN python3.11 -m pip install -e .

# Set locale environment variables
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Set PATH including local user bin for poetry
ENV PATH="/root/.local/bin:${PATH}"

# Use bash by default
ENV SHELL=/bin/bash

WORKDIR /testbed/
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# System dependencies installation: essential tools and libraries
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 and pip point to python3.11 and its pip
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && python3 -m pip install --upgrade pip setuptools wheel

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specified commit SHA (to be replaced at build time by --build-arg)
ARG REPO_URL=https://github.com/crewAIInc/crewAI.git
ARG COMMIT_SHA=a6b729509222c1ad829630452b91685b224689e0

RUN git clone ${REPO_URL} /testbed/ \
    && cd /testbed/ \
    && git reset --hard ${COMMIT_SHA} \
    && git remote remove origin

# Create and activate virtual environment and install dependencies in editable mode
RUN python3 -m venv /testbed/testbed_venv

# Install dependencies inside the venv
RUN source /testbed/testbed_venv/bin/activate \
    && pip install --upgrade pip \
    && pip install 'pydantic>=2.4.2' 'langchain>=0.2.16' 'openai>=1.13.3' 'crewai-tools>=0.12.1' \
    && pip install --use-pep517 hatchling \
    && pip install -e . \
    && pip install 'crewai[tools]' \
    && pip install -r <(grep -E '^(ruff|mypy|pre-commit|pytest|pytest-asyncio|pytest-subprocess|pytest-vcr)' pyproject.toml || echo "") || true

# Add environment variable info and convenience activation for venv
RUN echo "source /testbed/testbed_venv/bin/activate" >> /root/.bashrc

# Note environment variables recommended:
# OPENAI_API_KEY, SERPER_API_KEY can be mounted/set at runtime or stored in .env

# Default shell
ENV SHELL=/bin/bash
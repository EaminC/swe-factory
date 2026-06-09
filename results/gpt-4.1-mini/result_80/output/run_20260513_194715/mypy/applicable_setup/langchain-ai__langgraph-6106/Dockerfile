FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install essential system dependencies including git, curl, build tools and python3.10+
RUN apt update && apt install -y \
    git \
    curl \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    wget \
    unzip \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set python3 to point to python3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
RUN python3 -m pip install --upgrade pip setuptools wheel hatch

# Create working directory
WORKDIR /testbed/

# Clone repository and checkout specific commit SHA in one RUN step, verify files exist
ARG REPO=https://github.com/langchain-ai/langgraph.git
ARG COMMIT_SHA=6fc5b3aeda2aaa89277c79dc3682e7c723e2abb6
RUN git clone ${REPO} /testbed/ && \
    cd /testbed && \
    git reset --hard ${COMMIT_SHA} && \
    git remote remove origin && \
    chmod -R 777 /testbed && \
    ls -l /testbed && \
    test -f /testbed/libs/langgraph/pyproject.toml

# Install local editable dependencies for development along with main dependencies using hatch
RUN cd /testbed/libs/langgraph && \
    hatch env create && \
    hatch run pip install --editable ../prebuilt && \
    hatch run pip install --editable ../checkpoint && \
    hatch run pip install --editable ../checkpoint-sqlite && \
    hatch run pip install --editable ../checkpoint-postgres && \
    hatch run pip install --editable ../sdk-py && \
    hatch run pip install --editable ../cli && \
    hatch run pip install --editable . && \
    hatch run pip install pytest pytest-cov pytest-dotenv pytest-mock syrupy httpx pytest-watcher mypy ruff jupyter pytest-xdist[psutil] pytest-repeat psycopg[binary] uvloop==0.21.0beta1 pyperf py-spy types-requests pycryptodome redis

# Add hatch to PATH and auto-activate the environment on container start in bash
RUN echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >> /root/.bashrc && \
    echo "cd /testbed/libs/langgraph/" >> /root/.bashrc && \
    echo "hatch shell" >> /root/.bashrc

SHELL ["/bin/bash", "-c"]
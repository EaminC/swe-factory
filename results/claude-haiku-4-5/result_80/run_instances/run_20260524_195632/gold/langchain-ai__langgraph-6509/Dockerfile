# Base image specification using Ubuntu with bash included
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation - essential tools and libraries for development and runtime
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    libtiff-dev \
    python3 \
    python3-pip \
    python-is-python3 \
    jq \
    curl \
    locales \
    locales-all \
    tzdata \
    postgresql-client \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install package and environment manager - Miniconda for Python environment management
RUN wget 'https://repo.anaconda.com/miniconda/Miniconda3-py310_23.11.0-2-Linux-x86_64.sh' -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

RUN conda init --all \
    && conda config --append channels conda-forge

# Sets up a dedicated testbed environment with Python 3.10 and required testing dependencies
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -n testbed python=3.10 -y && \
    conda activate testbed && \
    pip install --upgrade pip setuptools wheel"

# Set default workdir to testbed
WORKDIR /testbed/

# Target Project setup - Clone source code, checkout to target version, and install project-specific dependencies
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/langchain-ai/langgraph /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard 5212369bd0791806083f183cb19ccce024db8790 && \
    git remote remove origin"

# Install langgraph main library from libs/langgraph in development mode
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    cd /testbed/libs/langgraph && \
    pip install -e ."

# Install langgraph-checkpoint from libs/checkpoint in development mode
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    cd /testbed/libs/checkpoint && \
    pip install -e ."

# Install langgraph-checkpoint-postgres from libs/checkpoint-postgres in development mode
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    cd /testbed/libs/checkpoint-postgres && \
    pip install -e ."

# Install langgraph-checkpoint-sqlite from libs/checkpoint-sqlite in development mode
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    cd /testbed/libs/checkpoint-sqlite && \
    pip install -e ."

# Install langgraph-prebuilt library from libs/prebuilt in development mode
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    cd /testbed/libs/prebuilt && \
    pip install -e ."

# Install essential test dependencies
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    pip install pytest pytest-asyncio pytest-mock pytest-cov pytest-dotenv pytest-xdist[psutil] redis httpx uvloop==0.21.0b1 pyperf pycryptodome syrupy psycopg[binary]"

# Configure bash to activate testbed environment on container start
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc
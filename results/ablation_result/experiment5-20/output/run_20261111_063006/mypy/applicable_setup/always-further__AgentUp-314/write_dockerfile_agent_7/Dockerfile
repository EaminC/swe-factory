FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and essential tools
RUN apt update && apt install -y \
    git \
    wget \
    curl \
    build-essential \
    locales \
    locales-all \
    tzdata \
    bzip2 \
    libncursesw5 \
    libssl3 \
    libsqlite3-0 \
    libffi7 \
    liblzma5 \
    libreadline8 \
    libbz2-1.0 \
    && rm -rf /var/lib/apt/lists/*

# Install Mambaforge - Latest stable Linux x86_64 installer URL (as of 2024-06-01)
RUN wget https://github.com/conda-forge/miniforge/releases/download/23.9.1-0/Mambaforge-Linux-x86_64.sh -O mambaforge.sh \
    && bash mambaforge.sh -b -p /opt/mambaforge \
    && rm mambaforge.sh
ENV PATH=/opt/mambaforge/bin:$PATH

RUN conda config --append channels conda-forge

# Create conda environment with Python 3.11 using mamba for efficient installs
RUN mamba create -n testbed python=3.11 -y

# Install essential Python packages in separate conda run steps to mitigate memory issues
RUN conda run -n testbed pip install --upgrade pip setuptools wheel
RUN conda run -n testbed pip install pytest>=8.4.0 pytest-asyncio>=1.0.0 python-dotenv

# Set working directory
WORKDIR /testbed/

# Clone repo, checkout specific commit, install repo in editable mode using conda run
ARG REPO=https://github.com/always-further/AgentUp.git
ARG COMMIT_SHA=58b138c3e797a3bd39c04603ce3e50b866b7a299
RUN git clone ${REPO} /testbed && \
    cd /testbed && \
    git checkout ${COMMIT_SHA} && \
    conda run -n testbed pip install -e .

# Enable conda environment activation in interactive shells
RUN echo "source /opt/mambaforge/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc
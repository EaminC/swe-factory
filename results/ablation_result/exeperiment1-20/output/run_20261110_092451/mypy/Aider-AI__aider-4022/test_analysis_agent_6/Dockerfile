FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive

# Set timezone environment variable only to avoid Docker build issues
ENV TZ=Etc/UTC

# Install essential system dependencies in two steps to reduce memory footprint
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    locales \
    locales-all \
    tzdata && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    python3-distutils && \
    rm -rf /var/lib/apt/lists/*

# Ensure python3 is the default python
RUN ln -sf /usr/bin/python3 /usr/bin/python

# Install Miniconda silently
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-2-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p /opt/miniconda && \
    rm ~/miniconda.sh

ENV PATH="/opt/miniconda/bin:$PATH"

# Create and clean conda environment with Python 3.11
RUN /bin/bash -c "source /opt/miniconda/etc/profile.d/conda.sh && \
    conda create -y -n testbed python=3.11 && \
    conda clean -afy"

WORKDIR /testbed/

# Clone repository, checkout specific commit and install dependencies and project editable package.
RUN /bin/bash -c "source /opt/miniconda/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/Aider-AI/aider.git /testbed/ && \
    cd /testbed/ && \
    git checkout 17d40a62c931ac91fc9c31288310b37b62175c47 && \
    pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt && \
    if [ -f requirements/requirements-dev.txt ]; then pip install -r requirements/requirements-dev.txt; fi && \
    pip install -e . && \
    sync"

# Add conda environment activation to root bashrc for interactive use
RUN echo "source /opt/miniconda/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc

# Use bash as default shell
SHELL ["/bin/bash", "-c"]

WORKDIR /testbed/
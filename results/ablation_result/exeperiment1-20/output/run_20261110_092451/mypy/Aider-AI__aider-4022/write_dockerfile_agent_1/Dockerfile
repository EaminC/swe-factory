FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies and essential tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    python3-distutils \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set locale and python alias
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install Miniconda for environment management
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-2-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p /opt/miniconda && \
    rm ~/miniconda.sh
ENV PATH="/opt/miniconda/bin:$PATH"

# Initialize conda and create python environment with proper python version
# Python version range 3.9 to 3.12 is supported: choose 3.11 for compatibility
RUN /bin/bash -c "source /opt/miniconda/etc/profile.d/conda.sh && \
    conda create -y -n testbed python=3.11 && \
    conda clean -afy"

# Activate conda environment and install dependencies from repository
WORKDIR /testbed/

# Clone repo, checkout specific commit, and install dependencies
# Install main and dev requirements, install project in editable mode
# Use bash shell explicitly to run all necessary steps in conda environment
RUN /bin/bash -c "source /opt/miniconda/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/Aider-AI/aider.git /testbed/ && \
    cd /testbed/ && \
    git checkout 17d40a62c931ac91fc9c31288310b37b62175c47 && \
    pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt && \
    if [ -f requirements/requirements-dev.txt ]; then pip install -r requirements/requirements-dev.txt; fi && \
    pip install -e ."

# Add conda environment activation to bashrc for interactive use
RUN echo "source /opt/miniconda/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc

# Set default shell to bash to avoid any shell issues
SHELL ["/bin/bash", "-c"]

# Set working directory
WORKDIR /testbed/
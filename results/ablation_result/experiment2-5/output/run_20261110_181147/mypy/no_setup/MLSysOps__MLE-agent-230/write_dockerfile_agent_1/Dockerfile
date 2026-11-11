# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation. Installs essential tools and libraries required for development and runtime (Required)
RUN apt update && apt install -y \
    wget \
    git \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    curl \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install pip for Python 3.11
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

# Install Miniconda to manage Python environment efficiently
RUN wget 'https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-2-Linux-x86_64.sh' -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh
ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda and set channels
RUN /bin/bash -c "conda init bash && \
   conda config --append channels conda-forge"

# Create and setup conda environment 'testbed' with Python 3.11
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -y -n testbed python=3.11"

# Set working directory for the project
WORKDIR /testbed/

# Clone the repository, checkout the specific commit, and install dependencies in editable mode
ARG REPO=https://github.com/MLSysOps/MLE-agent.git
ARG COMMIT_SHA=985c24e1b2b8e9463aacfbeb2c8a47f27fa4523c

RUN /bin/bash -c " \
    source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed && \
    git clone $REPO /testbed && \
    cd /testbed && \
    git fetch --all && \
    git reset --hard $COMMIT_SHA && \
    pip install -r requirements.txt && \
    pip install -e . \
"

# Persist conda environment activation on bash login
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc

# Use bash as the default shell
SHELL ["/bin/bash", "-c"]
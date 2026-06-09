FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    python3-distutils \
    python3-setuptools \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda (lightweight conda installer)
RUN wget "https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-2-Linux-x86_64.sh" -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda and add conda-forge channel
RUN conda init bash \
    && conda config --append channels conda-forge

# Create conda environment "testbed" with Python 3.10 (meets >=3.8,<4.0)
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -n testbed python=3.10 -y"

# Activate conda env and upgrade pip, install pytest only (other deps installed via pip install -e .)
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    pip install --upgrade pip && \
    pip install pytest==7.3.1"

# Set working directory
WORKDIR /testbed/

# Clone the repository, checkout the specific commit, and install repo in editable mode (with all dependencies)
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/AntonOsika/gpt-engineer /testbed && \
    cd /testbed && \
    git reset --hard 7dac88a3f8e8c0610e9e3189c867b19d055dab2d && \
    pip install -e ."

# Enable automatic conda activation for interactive bash shells
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc
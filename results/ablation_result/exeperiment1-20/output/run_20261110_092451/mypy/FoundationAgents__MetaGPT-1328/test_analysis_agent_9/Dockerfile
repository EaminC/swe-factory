# Use official Miniconda3 base image to avoid filesystem permission issues during conda installation
FROM continuumio/miniconda3:latest

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Update and install necessary system dependencies for git, curl, build tools and Python system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    curl \
    build-essential \
    ca-certificates \
    libffi-dev \
    libssl-dev \
    locales \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Create conda environment named 'testbed' with python 3.10 and install setuptools explicitly to cover distutils functionality
RUN conda create -y -n testbed python=3.10 setuptools && conda clean -afy

# Ensure conda environment activation in bashrc for interactive shells
RUN echo "source /opt/conda/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc

ENV PATH=/opt/conda/envs/testbed/bin:$PATH

# Set working directory to /testbed before cloning repository to isolate git clone layer
WORKDIR /testbed/

# Clone repository and checkout the specified commit SHA in a separate step to reduce layer size and avoid potential docker commit issues
ARG COMMIT_SHA=5e8bd105177e08848990d32b9ea636daa639be19
RUN git clone https://github.com/geekan/MetaGPT . && git reset --hard ${COMMIT_SHA}

# Install dependencies from repo only (no pre-install from PyPI)
RUN /bin/bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate testbed && \
    pip install --upgrade pip wheel setuptools && \
    pip install -e . && \
    pip install -r requirements.txt"

# Use bash as default shell
SHELL ["/bin/bash", "-c"]

# Environment variable to disable openai calls during testing as per context hint
ENV ALLOW_OPENAI_API_CALL=0
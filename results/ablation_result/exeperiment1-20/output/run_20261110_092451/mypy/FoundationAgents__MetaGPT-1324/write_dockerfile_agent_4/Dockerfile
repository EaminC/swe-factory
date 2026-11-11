FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies, no system python installation to avoid conflicts
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    curl \
    locales \
    locales-all \
    tzdata \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda for environment management with python3.9 base
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_23.3.1-0-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/conda \
    && rm /tmp/miniconda.sh

ENV PATH=/opt/conda/bin:$PATH

# Initialize conda for bash shell
RUN conda init bash

ENV REPO_URL=https://github.com/geekan/MetaGPT
ENV REPO_COMMIT=5e8bd105177e08848990d32b9ea636daa639be19
ENV CONDA_ENV=testbed

# Create conda environment with python 3.9
RUN /bin/bash -c "source /opt/conda/etc/profile.d/conda.sh && conda create -n $CONDA_ENV python=3.9 -y"

# Clone repo, checkout commit
RUN git clone $REPO_URL /testbed
RUN /bin/bash -c "cd /testbed && git checkout $REPO_COMMIT"

# Install dependencies inside conda environment using conda run to ensure environment activation and avoid lost state
RUN /bin/bash -c "source /opt/conda/etc/profile.d/conda.sh && \
    conda run -n $CONDA_ENV pip install --upgrade pip setuptools wheel"

RUN /bin/bash -c "source /opt/conda/etc/profile.d/conda.sh && \
    conda run -n $CONDA_ENV pip install --upgrade aiohttp==3.8.6 channels==4.0.0 faiss_cpu==1.7.4 fire==0.4.0 typer==0.9.0 lancedb==0.4.0 loguru==0.6.0 meilisearch==0.21.0 'numpy>=1.24.3' 'openai>=1.6.1' beautifulsoup4==4.12.3 pandas==2.1.1 'pydantic>=2.5.3' PyYAML==6.0.1 tqdm==4.66.2"

# Install the metagpt package in development mode
RUN /bin/bash -c "source /opt/conda/etc/profile.d/conda.sh && conda run -n $CONDA_ENV pip install -e /testbed"

WORKDIR /testbed/

# Persist conda environment activation for interactive shells
RUN echo "source /opt/conda/etc/profile.d/conda.sh && conda activate $CONDA_ENV" >> /root/.bashrc
FROM --platform=linux/x86_64 continuumio/miniconda3:latest
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    bzip2 \
    build-essential \
    libffi-dev \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set environment path and locale
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH=/opt/conda/bin:$PATH

# Create conda environment with Python 3.9 (do not activate here to avoid layer caching issues)
RUN conda create -n testbed python=3.9 -y \
    && conda clean -afy

# Set working directory
WORKDIR /testbed/

# Clone repository, checkout specific commit, install dependencies in editable mode
RUN git clone https://github.com/FoundationAgents/MetaGPT.git /testbed && \
    cd /testbed && \
    git reset --hard 59afc5301f55037e7b379497767f4af62fd65b31

RUN /bin/bash -c "source /opt/conda/etc/profile.d/conda.sh && \
    conda activate testbed && \
    pip install --upgrade pip setuptools wheel && \
    pip install -r /testbed/requirements.txt && \
    pip install -e /testbed/"

# Ensure conda environment activates by default in bash
RUN echo "source /opt/conda/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc
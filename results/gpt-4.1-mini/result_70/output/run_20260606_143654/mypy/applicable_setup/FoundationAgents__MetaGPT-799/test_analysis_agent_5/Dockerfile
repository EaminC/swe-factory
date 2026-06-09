FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and Miniconda prerequisites
RUN apt-get update && apt-get install -y \
    git \
    curl \
    bzip2 \
    build-essential \
    libffi-dev \
    locales \
    locales-all \
    tzdata \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set locale environment variables
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV TZ=Etc/UTC

# Install Miniconda manually with a stable version
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_23.7.2-1-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/miniconda3 \
    && rm /tmp/miniconda.sh
ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda and create environment with Python 3.9
RUN conda init bash \
    && conda config --append channels conda-forge \
    && /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
       conda create -n testbed python=3.9 -y"

# Set working directory
WORKDIR /testbed/

# Clone repository and checkout specific commit
RUN git clone https://github.com/FoundationAgents/MetaGPT.git /testbed \
    && cd /testbed \
    && git reset --hard 59afc5301f55037e7b379497767f4af62fd65b31

# Install dependencies inside conda environment in editable mode
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    pip install --upgrade pip setuptools wheel && \
    pip install -r /testbed/requirements.txt && \
    pip install -e /testbed/"

# Ensure conda environment activates by default in bash
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc
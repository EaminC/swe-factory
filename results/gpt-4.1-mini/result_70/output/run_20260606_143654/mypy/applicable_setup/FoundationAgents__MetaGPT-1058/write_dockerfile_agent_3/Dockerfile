FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies and essential tools (no python3.9 packages)
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    python3-pip \
    python-is-python3 \
    curl \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda (Python environment and package manager)
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-2-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/miniconda3 \
    && rm /tmp/miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda and add conda-forge channel
RUN /bin/bash -c "conda init bash && conda config --append channels conda-forge"

# Create conda environment 'testbed' with Python 3.9
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -n testbed python=3.9 -y"

# Set working directory
WORKDIR /testbed/

# Clone repo, checkout commit, upgrade pip and setuptools, install required packages and local repo in editable mode inside conda env
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/FoundationAgents/MetaGPT.git /testbed && \
    cd /testbed && \
    git reset --hard adb42f44d65a3fd9468c2919a1557e1c3751759d && \
    pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt && \
    pip install -e ."

# Make conda environment activation persistent in bash shell
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc

# Use bash shell for RUN commands
SHELL ["/bin/bash", "-c"]
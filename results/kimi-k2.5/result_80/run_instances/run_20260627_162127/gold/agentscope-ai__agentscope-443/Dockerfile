FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies including git and build tools
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    wget \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda with Python 3.9
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_23.11.0-2-Linux-x86_64.sh -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda and configure channels
RUN conda init bash && conda config --append channels conda-forge

# Create the testbed environment with Python 3.9
RUN conda create -n testbed python=3.9 -y

# Set working directory
WORKDIR /testbed/

# Clone the repository, checkout specific commit, and install dependencies
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    cd /testbed && \
    git reset --hard 6c823a955c7be783a2a34c64d13b74aee8c552bf && \
    git remote remove origin && \
    pip install setuptools==68.2.2 wheel==0.41.2 && \
    pip install -e .[full]"

# Configure bash to automatically activate the testbed environment
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc

# Set bash as the default shell for all subsequent commands
SHELL ["/bin/bash", "-c"]
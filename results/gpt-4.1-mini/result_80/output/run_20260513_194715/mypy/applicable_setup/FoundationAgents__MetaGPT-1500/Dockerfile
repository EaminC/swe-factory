FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies including curl, git, build-essential,
# python3.11 and related packages, plus ca-certificates
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    libffi-dev \
    libssl-dev \
    python3.11 \
    python3-distutils \
    python3-venv \
    python3-pip \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Download the latest Miniconda installer (generic latest Python 3 version)
RUN wget --tries=5 --timeout=30 --retry-connrefused --waitretry=10 https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh

ENV PATH=/opt/conda/bin:$PATH

# Initialize conda for bash and add conda-forge channel
RUN conda init bash && \
    conda config --append channels conda-forge

# Create and activate conda environment named testbed with python 3.11
RUN /bin/bash -c "source /opt/conda/etc/profile.d/conda.sh && \
    conda create -y -n testbed python=3.11 && \
    conda clean -afy"

# Install Node.js 20.x and npm from NodeSource (to ensure compatibility with required npm packages)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g @mermaid-js/mermaid-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone the target repository, checkout specific commit, install python dependencies, playwright and test extras
ARG COMMIT_SHA=4c55a976c677202cdca6a51da8dbd326de650f9c

RUN /bin/bash -c "source /opt/conda/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/FoundationAgents/MetaGPT.git /testbed && \
    cd /testbed && \
    git checkout ${COMMIT_SHA} && \
    pip install --upgrade pip && \
    pip install playwright && \
    playwright install --with-deps && \
    pip install -e .[test] && \
    rm -rf ~/.cache/pip"

# Set working directory
WORKDIR /testbed

# Add conda environment activation on bash startup
RUN echo "source /opt/conda/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc
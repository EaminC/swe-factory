# Use Ubuntu 22.04 as base to get modern system packages with python3.10 support for paddlepaddle compatibility
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies including python3.10 and related dev packages, git, curl, wget, build tools, and utilities
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3.10 \
    python3.10-dev \
    python3-pip \
    python3.10-venv \
    locales \
    locales-all \
    tzdata \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set python3.10 as default python command
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Upgrade pip, setuptools, and wheel to latest versions for compatibility
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Install Miniconda with Python 3.10 to manage environments reliably and isolate from system Python
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py310_23.3.1-0-Linux-x86_64.sh -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda for bash and add conda-forge channel for wide package availability
RUN conda init bash \
    && conda config --append channels conda-forge

# Create conda environment named metagpt with python 3.10 to satisfy paddlepaddle 2.4.2 and dependencies
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -n metagpt python=3.10 -y"

# Set environment variables to activate conda environment by default
ENV CONDA_DEFAULT_ENV=metagpt
ENV CONDA_PREFIX=/opt/miniconda3/envs/metagpt
ENV PATH=$CONDA_PREFIX/bin:$PATH

# Set working directory for cloning the repository
WORKDIR /testbed/

# Clone the repository and checkout the specific commit SHA provided
RUN git clone https://github.com/FoundationAgents/MetaGPT.git /testbed/ && \
    git reset --hard ab846f65e481a655b791959eb0f89fb4b1c84128

# Install Node.js (LTS) and npm required for mermaid-cli global install
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Inside the conda environment, install python dependencies with editable install including test extras
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate metagpt && \
    pip install --no-cache-dir -e .[test]"

# Install mermaid-cli globally via npm
RUN npm install -g @mermaid-js/mermaid-cli

# Install Playwright and its dependencies inside conda environment including browsers
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate metagpt && \
    pip install --no-cache-dir playwright && \
    playwright install --with-deps"

# Set environment variable to prevent real OpenAI API calls during testing
ENV ALLOW_OPENAI_API_CALL=0

# Ensure conda environment activation on container start for interactive use
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate metagpt" >> /root/.bashrc
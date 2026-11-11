# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# System dependencies installation. Installs essential tools and libraries required for development and runtime (Required)
RUN apt update && apt install -y \
    git \
    wget \
    build-essential \
    curl \
    python3-pip \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda (latest py39 compatible) for more reliable env management
RUN wget "https://repo.anaconda.com/miniconda/Miniconda3-py39_23.3.1-0-Linux-x86_64.sh" -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh
ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda and create testbed environment with python 3.9
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda config --append channels conda-forge && \
    conda create -y -n testbed python=3.9 && \
    conda clean -afy"

# Set working directory
WORKDIR /testbed/

# Clone repository, checkout specific commit, install dependencies in editable mode in conda env
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/agentscope-ai/agentscope.git . && \
    git reset --hard 371d1680ab7f41c7d695559221956250ba048475 && \
    pip install -q -e .[full] && \
    pip install -q coverage"

# Enable conda environment activation on container start for bash shells
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc

# Default shell is bash
ENV SHELL=/bin/bash
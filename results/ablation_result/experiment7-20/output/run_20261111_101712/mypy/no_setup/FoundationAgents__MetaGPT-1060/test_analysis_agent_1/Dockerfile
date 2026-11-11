FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies including Python 3.9, git, curl, wget, and essential build tools
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    ca-certificates \
    locales \
    tzdata \
    bzip2 \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Set locale to UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV PATH=/opt/miniconda3/bin:$PATH

# Install Miniconda (with Python 3.9) to manage environment reliably
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py39_23.3.1-1-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/miniconda3 \
    && rm /tmp/miniconda.sh \
    && conda init bash \
    && conda config --system --prepend channels conda-forge \
    && conda config --system --set channel_priority strict

# Create and activate conda environment named "testbed" with Python 3.9
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -y -n testbed python=3.9 && \
    conda clean -afy"

# Clone the repository, checkout the specific commit, install dependencies in dev mode
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed && \
    git clone https://github.com/FoundationAgents/MetaGPT.git /testbed && \
    cd /testbed && \
    git reset --hard 0958cc333ee13d1ce5216ae0bdeaa53b5eacc6ea && \
    pip install --upgrade pip setuptools wheel && \
    pip install --upgrade git+https://github.com/geekan/MetaGPT.git && \
    pip install -r requirements.txt && \
    pip install -e . && \
    # Install test extras for pytest and related plugins
    pip install pytest pytest-asyncio pytest-cov pytest-mock pytest-html pytest-xdist pytest-timeout"

WORKDIR /testbed

# Append conda activate to bashrc so future shells activate environment by default
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc
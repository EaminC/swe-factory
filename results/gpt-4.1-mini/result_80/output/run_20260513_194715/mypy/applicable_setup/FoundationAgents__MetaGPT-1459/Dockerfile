FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies: git, curl, wget, build-essential, python3, python3-venv, python3-pip, python3-distutils, npm, and others
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    locales \
    locales-all \
    tzdata \
    python3 \
    python3-venv \
    python3-pip \
    python3-distutils \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Set up alternatives to ensure python points to python3 and pip to pip3
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
 && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Use curl with retry logic to download a verified latest Miniconda Python 3.11 installer URL
RUN curl -fsSL --retry 5 https://repo.anaconda.com/miniconda/Miniconda3-py311_23.7.3-0-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/miniconda3 \
    && rm /tmp/miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda shell integration
RUN /bin/bash -c "conda init bash"

SHELL ["/bin/bash", "-c"]

# Create conda environment named 'testbed' with python 3.11 to satisfy paddlepaddle requirements
RUN conda create -y -n testbed python=3.11

# Activate conda environment, upgrade pip, setuptools, and wheel for package installations
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    pip install --upgrade pip setuptools wheel"

# Set working directory
WORKDIR /testbed/

# Clone the MetaGPT repository and checkout the specified commit (ARG to pass commit SHA)
ARG COMMIT_SHA=ab846f65e481a655b791959eb0f89fb4b1c84128

RUN /bin/bash -c " \
    source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/FoundationAgents/MetaGPT /testbed && \
    cd /testbed && \
    git reset --hard ${COMMIT_SHA} && \
    git remote remove origin"

# Install the repository in editable mode with '[test]' extras that include test dependencies and core dependencies
RUN /bin/bash -c " \
    source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    cd /testbed && \
    pip install --upgrade pip && \
    pip install -e .[test]"

# Install globally the @mermaid-js/mermaid-cli for Node.js and playwright with dependencies
RUN /bin/bash -c " \
    source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    npm install -g @mermaid-js/mermaid-cli && \
    pip install playwright && \
    playwright install --with-deps"

# Set environment variable to disable external OpenAI calls during tests
ENV ALLOW_OPENAI_API_CALL=0

# Add conda activate to root bashrc so conda environment is activated by default on shell start
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc

# Default shell explicitly to bash to avoid sh/dash shell issues
SHELL ["/bin/bash", "-c"]
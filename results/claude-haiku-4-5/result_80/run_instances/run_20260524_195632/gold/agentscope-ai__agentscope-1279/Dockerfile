# Base image: Ubuntu 22.04 with bash and essential tools
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    libtiff-dev \
    python3 \
    python3-pip \
    python3-dev \
    python-is-python3 \
    jq \
    curl \
    locales \
    locales-all \
    tzdata \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda for environment management
RUN wget 'https://repo.anaconda.com/miniconda/Miniconda3-py310_23.11.0-2-Linux-x86_64.sh' -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda and configure
RUN /opt/miniconda3/bin/conda init --all \
    && /opt/miniconda3/bin/conda config --append channels conda-forge

# Create testbed environment with Python 3.10
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda create -n testbed python=3.10 -y && \
    conda activate testbed && \
    pip install --upgrade pip setuptools wheel"

# Set default shell to bash for all RUN commands
SHELL ["/bin/bash", "-c"]

# Set workdir
WORKDIR /testbed/

# Clone repository and checkout specific commit
RUN source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard 28cfb99a21902d330dab6cb3762a739198cf972f && \
    git remote remove origin

# Install core dependencies
RUN source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    pip install \
    aioitertools \
    anthropic \
    dashscope \
    docstring_parser \
    json5 \
    json_repair \
    'mcp>=1.13' \
    numpy \
    openai \
    python-datauri \
    'opentelemetry-api>=1.39.0' \
    'opentelemetry-sdk>=1.39.0' \
    'opentelemetry-exporter-otlp>=1.39.0' \
    'opentelemetry-semantic-conventions>=0.60b0' \
    python-socketio \
    shortuuid \
    tiktoken \
    sounddevice \
    sqlalchemy \
    python-frontmatter

# Install test dependencies
RUN source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    pip install \
    pytest \
    pytest-forked \
    fakeredis \
    aiosqlite \
    greenlet \
    py-openjudge

# Install the project in development mode
RUN source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    cd /testbed && \
    pip install -e .

# Configure bash to automatically activate testbed environment
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc

# Set environment variable for DASH_API_KEY (placeholder, can be overridden at runtime)
ENV DASH_API_KEY=""

# Default command
CMD ["/bin/bash"]
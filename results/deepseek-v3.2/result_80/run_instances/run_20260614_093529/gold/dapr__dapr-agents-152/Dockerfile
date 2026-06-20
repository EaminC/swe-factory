# Base image with bash and essential tools
FROM --platform=linux/x86_64 ubuntu:22.04

# Set environment variables to avoid interactive prompts
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PATH=/opt/miniconda3/bin:$PATH

# Install system dependencies including protobuf compilation tools
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    libssl-dev \
    curl \
    ca-certificates \
    libprotobuf-dev \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda for Python environment management
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py310_23.11.0-2-Linux-x86_64.sh -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

# Initialize conda and set up channels
RUN conda init bash \
    && conda config --append channels conda-forge

# Create and activate conda environment with Python 3.10 (as specified in README)
RUN conda create -n testbed python=3.10 -y

# Clone the repository and checkout the specific commit
WORKDIR /testbed
RUN git clone https://github.com/dapr/dapr-agents.git . \
    && git reset --hard caaad181ce706c4e7a5b55a225ca06154965ec70

# First install specific protobuf version to ensure it's available before other dependencies
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh \
    && conda activate testbed \
    && pip install --upgrade pip setuptools wheel \
    && pip install \"protobuf>=6.31.1,<7.0\""

# Install the project in development mode with test dependencies
# Note: This will install durabletask-dapr which may have its own protobuf requirements
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh \
    && conda activate testbed \
    && pip install -e .[test]"

# Force reinstall protobuf to ensure runtime version matches the required version
# This is critical because durabletask-dapr may downgrade protobuf during installation
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh \
    && conda activate testbed \
    && pip install --force-reinstall \"protobuf>=6.31.1,<7.0\""

# Verify protobuf version matches the expected version
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh \
    && conda activate testbed \
    && python -c 'import google.protobuf; version = google.protobuf.__version__; print(f\"Protobuf version: {version}\"); assert version >= \"6.31.1\", f\"Protobuf version {version} is too old, need >=6.31.1\"'"

# Install additional dependencies from tox.ini
# Note: numpy, durabletask, cloudevents should already be installed via .[test]
# But we ensure numpy is at the exact version specified
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh \
    && conda activate testbed \
    && pip install numpy==2.2.2"

# Make sure conda environment is activated by default for interactive sessions
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc

# Set the working directory back to /testbed
WORKDIR /testbed
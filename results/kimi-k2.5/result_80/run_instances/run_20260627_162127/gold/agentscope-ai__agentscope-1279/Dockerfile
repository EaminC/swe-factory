FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies including git, build tools, and other essentials
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    wget \
    curl \
    ca-certificates \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda for Python environment management
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/miniconda3 \
    && rm miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda and configure channels
RUN conda init bash && conda config --append channels conda-forge

# Accept Conda Terms of Service for default channels (required for non-interactive use)
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Create conda environment with Python 3.10 (required: >=3.10)
RUN conda create -n testbed python=3.10 -y

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout to the specific commit
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed/ \
    && git reset --hard 28cfb99a21902d330dab6cb3762a739198cf972f \
    && git remote remove origin \
    && chmod -R 777 /testbed/

# Install the package in development mode with all dev/test dependencies
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    pip install --upgrade pip setuptools wheel && \
    pip install -e '.[dev]'"

# Configure shell to use bash and auto-activate conda environment
SHELL ["/bin/bash", "-c"]
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc
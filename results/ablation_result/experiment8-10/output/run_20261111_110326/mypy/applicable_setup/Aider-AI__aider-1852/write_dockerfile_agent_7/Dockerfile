# Use Ubuntu 22.04 as base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system packages: git, python3.11, python3.11-venv, python3-pip, build essentials, curl
RUN apt-get update && apt-get install -y \
    git \
    python3.11 \
    python3.11-venv \
    python3-pip \
    python3.11-distutils \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Symlink python to python3.11 and upgrade pip, setuptools, and wheel
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    python -m pip install --upgrade pip setuptools wheel

# Set environment variable for the repository directory
ENV REPO_DIR=/testbed

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/Aider-AI/aider.git $REPO_DIR \
    && cd $REPO_DIR \
    && git checkout 9789668ca4d14d3b6c24e56f3fe956147ea78039

# Remove litellm dependency from requirements files to avoid pip trying to clone during install
RUN cd $REPO_DIR \
    && sed -i '/litellm==1.47.0/d' requirements.txt \
    && sed -i '/litellm==1.47.0/d' requirements/requirements-dev.txt

# Clone litellm explicitly via git to local folder and install from local folder (avoiding authentication errors)
RUN git clone https://github.com/StanGirard/litellm.git /tmp/litellm

# Setup python3.11 virtual environment, install litellm from local, then other dependencies & project in editable mode
RUN cd $REPO_DIR \
    && python3.11 -m venv venv \
    && source venv/bin/activate \
    && pip install --upgrade pip setuptools wheel \
    && pip install /tmp/litellm \
    && pip install -r requirements.txt \
    && pip install -r requirements/requirements-dev.txt \
    && pip install -e .

# Set working directory
WORKDIR /testbed

# Enable automatic virtual environment activation when starting bash session
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc

# Environment variables for required API keys (to be overridden at runtime)
ENV ANTHROPIC_API_KEY=your-key-goes-here
ENV OPENAI_API_KEY=your-key-goes-here

# Use bash shell by default
CMD ["bash"]
# Use Ubuntu 22.04 as base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system packages: git, python3.10, python3.10-venv, python3-pip, build essentials
RUN apt-get update && apt-get install -y \
    git \
    python3.10 \
    python3.10-venv \
    python3-pip \
    python3.10-distutils \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Symlink python to python3.10 and upgrade pip for python3.10
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    python -m pip install --upgrade pip

# Set environment variable for the repo directory
ENV REPO_DIR=/testbed

# Clone the repository, checkout to the given commit, setup venv, install dependencies & project (editable)
RUN git clone https://github.com/Aider-AI/aider.git $REPO_DIR \
    && cd $REPO_DIR \
    && git checkout 9789668ca4d14d3b6c24e56f3fe956147ea78039 \
    && python -m venv venv \
    && source venv/bin/activate \
    && pip install --upgrade pip setuptools wheel \
    && pip install -r requirements.txt \
    && pip install -r requirements/requirements-dev.txt \
    && pip install -e .

# Set working directory
WORKDIR /testbed

# Recommended: add bashrc to activate venv automatically when container is started with bash
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc

# Environment variables for required API keys (to be overridden at container runtime)
ENV ANTHROPIC_API_KEY=your-key-goes-here
ENV OPENAI_API_KEY=your-key-goes-here

# Use bash shell by default
CMD ["bash"]
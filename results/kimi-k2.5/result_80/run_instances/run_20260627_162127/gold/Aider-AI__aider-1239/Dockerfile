FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies including Python 3.11, git, build tools, and audio/image libraries required by dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip \
    wget \
    curl \
    libsndfile1 \
    portaudio19-dev \
    libportaudio2 \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Set python3.11 as default python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Upgrade pip and install build tools
RUN pip install --upgrade pip setuptools>=68

# Create virtual environment named testbed
RUN python -m venv /opt/testbed
ENV PATH="/opt/testbed/bin:$PATH"

# Set workdir
WORKDIR /testbed/

# Clone repository and checkout specific commit
RUN git clone https://github.com/Aider-AI/aider /testbed/ && \
    chmod -R 777 /testbed && \
    git reset --hard 301c4265b76a5b8c4a939acb59314e091cacebec && \
    git remote remove origin

# Install dependencies and package in editable mode
RUN pip install -r requirements.txt && \
    pip install -r requirements/requirements-dev.txt && \
    pip install -e .

# Set bash as default shell
SHELL ["/bin/bash", "-c"]
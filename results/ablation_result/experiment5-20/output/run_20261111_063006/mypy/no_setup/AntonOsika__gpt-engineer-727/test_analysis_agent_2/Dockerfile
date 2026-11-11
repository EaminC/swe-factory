# Use Ubuntu 22.04 as a stable base with bash available
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies including python3.10, pip, git and build tools
# Also install tkinter as required by the OS package note
RUN apt update && apt install -y \
    git \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-tk \
    build-essential \
    curl \
    wget \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.10 and pip to pip3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && python3 -m pip install --upgrade pip setuptools wheel

# Set working directory
WORKDIR /testbed/

# Clone the repo and checkout specific commit SHA
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed/ \
    && cd /testbed/ \
    && git checkout 27e2566cff7e3dcf79f37b5271efbc1c0c01c3e0

# Install the cloned repo in editable mode, then install required test dependencies and langchain with proper version
RUN cd /testbed/ \
    && python3 -m pip install -e . \
    && python3 -m pip install pytest==7.3.1 pytest-cov \
    && python3 -m pip install 'langchain>=0.0.240'

# Export environment variable placeholder (to be set at runtime)
ENV OPENAI_API_KEY=""

# Use bash as default shell
CMD ["/bin/bash"]
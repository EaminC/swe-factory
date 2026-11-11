# Use Ubuntu 22.04 as base image since it includes Python 3.11 in default repos
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and basic tools
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    curl \
    ca-certificates \
    locales \
    locales-all \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    python3-setuptools \
    && rm -rf /var/lib/apt/lists/*

# Set default python and pip commands to python3.11 and pip3.11
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Create virtual environment named testbed
RUN python -m venv /opt/testbed

# Upgrade pip and setuptools inside the virtual environment separately to reduce layered complexity
RUN /opt/testbed/bin/pip install --upgrade pip setuptools

# Set working directory
WORKDIR /testbed/

# Clone repo, checkout specific commit, and install dependencies inside the virtual environment
RUN source /opt/testbed/bin/activate \
    && git clone https://github.com/MLSysOps/MLE-agent.git . \
    && git reset --hard cc7d248e9ec8f9359d7454017ddc6a31bde840b4 \
    && pip install openai~=1.34.0 pandas~=2.2.2 numexpr~=2.10.1 bottleneck~=1.4.0 \
    && pip install rich click pyyaml requests questionary tavily-python instructor kaggle \
    && pip install -e .

# Add virtual environment activation to root user's bashrc for convenience
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Default to workdir /testbed
WORKDIR /testbed/
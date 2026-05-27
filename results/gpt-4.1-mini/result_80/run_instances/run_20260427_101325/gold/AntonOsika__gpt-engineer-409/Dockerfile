# Use Ubuntu 22.04 LTS base image with bash shell support
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies: git, python3.10, venv, pip, build essentials
RUN apt-get update && apt-get install -y \
    git \
    python3.10 \
    python3.10-venv \
    python3-pip \
    python3.10-distutils \
    build-essential \
    curl \
    locales \
    locales-all \
    && rm -rf /var/lib/apt/lists/*

# Configure python3 and pip to use python3.10 explicitly
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
 && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 \
 && python -m pip install --upgrade pip setuptools wheel

# Use bash explicitly as default shell
SHELL ["/bin/bash", "-c"]

# Set working directory
WORKDIR /testbed/

# Clone the repository and check out the specified commit
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed/ \
    && git reset --hard 0596b07a39c2c99c46509c17660f5c8aef4b2114

# Create Python virtual environment 'testbed'
RUN python -m venv /testbed/venv

# Install project and testing dependencies in the venv, no PyPI pre-installs of the same main package
RUN /testbed/venv/bin/pip install --upgrade pip setuptools wheel \
 && /testbed/venv/bin/pip install -e . \
 && /testbed/venv/bin/pip install pytest

# Configure bashrc to auto-activate the virtual environment on container start
RUN echo 'source /testbed/venv/bin/activate' >> /root/.bashrc

# Omit chmod -R 777 /testbed/ due to Docker internal caching issues

# Set environment variables for virtual environment usage
ENV VIRTUAL_ENV=/testbed/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
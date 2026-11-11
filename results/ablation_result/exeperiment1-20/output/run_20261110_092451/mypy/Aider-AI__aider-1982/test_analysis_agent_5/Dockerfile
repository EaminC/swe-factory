# Use Ubuntu 22.04 base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install system dependencies and default Python 3.10 (no deadsnakes PPA)
# Replace locales-all with locales and generate en_US.UTF-8 locale explicitly
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    curl \
    ca-certificates \
    locales \
    python3 \
    python3-distutils \
    python3-venv \
    && locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Install pip for python3
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3

# Set working directory to /testbed
WORKDIR /testbed/

# Clone the repository, checkout the specific commit, create a virtual environment,
# and install development dependencies inside it
ARG COMMIT_SHA=0fe5247d4c8aa9ceff28f65c6e7fc04b4ce53ec4

RUN git clone https://github.com/Aider-AI/aider.git /testbed/ && \
    cd /testbed && \
    git checkout ${COMMIT_SHA} && \
    python3 -m venv testbed && \
    /bin/bash -c "source testbed/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install -e . && \
    pip install -r requirements.txt && \
    pip install -r requirements/requirements-dev.txt"

# Add virtual environment activation to bashrc for convenience
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

# Use bash as default shell
SHELL ["/bin/bash", "-c"]
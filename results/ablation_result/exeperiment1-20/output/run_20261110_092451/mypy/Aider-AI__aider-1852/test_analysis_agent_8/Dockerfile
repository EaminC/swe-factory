# Use an official Ubuntu base image with bash and broad compatibility
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Install minimal base dependencies first to reduce memory pressure and isolate potential build layer issues
RUN apt-get update && apt-get install -y \
    ca-certificates \
    locales \
    tzdata \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set timezone environment variable after installing tzdata
ENV TZ=Etc/UTC

# Generate locale separately to reduce layers and isolate locale config
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install Python and build dependencies in a separate step for clarity and layer isolation
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-venv \
    python3-distutils \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Create a Python virtual environment named "testbed" with python3.10 explicitly
RUN python3.10 -m venv /opt/testbed

# Add virtual environment binaries to PATH
ENV PATH="/opt/testbed/bin:$PATH"

# Install pip inside the virtual environment using get-pip.py for latest pip version independently of system pip
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | /opt/testbed/bin/python -

# Upgrade pip, setuptools, and wheel inside the virtual environment only
RUN /opt/testbed/bin/pip install --upgrade pip setuptools wheel

# Clone the repository and checkout the specified commit
RUN git clone https://github.com/paul-gauthier/aider.git /testbed \
    && cd /testbed \
    && git reset --hard 9789668ca4d14d3b6c24e56f3fe956147ea78039

# Install project dependencies and the project itself in editable mode inside the virtual environment
RUN /opt/testbed/bin/pip install -r /testbed/requirements.txt \
    && /opt/testbed/bin/pip install -r /testbed/requirements/requirements-dev.txt \
    && /opt/testbed/bin/pip install -e /testbed

# Set the working directory
WORKDIR /testbed/

# Configure bash to auto-activate the virtual environment on shell login (optional)
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc
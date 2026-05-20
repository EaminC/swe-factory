FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Ensure clean minimal install and update
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    locales \
    locales-all \
    tzdata \
    python3.11 \
    python3.11-venv \
    python3-pip \
    python3.11-distutils \
    && rm -rf /var/lib/apt/lists/*

# Set python3 to point to python3.11 explicitly
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Upgrade pip and install virtualenv in global python3.11
RUN python3 -m pip install --upgrade pip virtualenv

# Create a dedicated virtual environment
RUN python3 -m virtualenv /opt/venv

# Clone the repository and install in development mode within the virtual environment
RUN git clone https://github.com/Aider-AI/aider.git /testbed && \
    cd /testbed && \
    git reset --hard 301c4265b76a5b8c4a939acb59314e091cacebec && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install -e . && \
    /opt/venv/bin/pip install -r requirements.txt && \
    /opt/venv/bin/pip install -r requirements/requirements-dev.txt

# Set the working directory to /testbed as required
WORKDIR /testbed

# Enable auto-activation of virtual environment for interactive shells
RUN echo "source /opt/venv/bin/activate" >> /root/.bashrc
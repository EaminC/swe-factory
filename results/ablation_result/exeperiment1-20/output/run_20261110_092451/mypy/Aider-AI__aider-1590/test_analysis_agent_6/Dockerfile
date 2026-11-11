# Use official Ubuntu 24.04 base image to get native Python 3.12 support and avoid PPA issues
FROM --platform=linux/x86_64 ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install python3.12, venv, pip, git and build essentials
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-venv \
    python3-pip \
    python3-distutils \
    git \
    build-essential \
    curl \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 command points to python3.12
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Upgrade pip and setuptools for python3.12
RUN python3 -m pip install --upgrade pip setuptools wheel

# Set working directory
WORKDIR /testbed/

# Clone the repo and checkout specific commit
RUN git clone https://github.com/Aider-AI/aider.git /testbed && \
    git checkout ca4141564f86dd1b7dee3082959042dc05d5d471 && \
    git remote remove origin

# Create Python virtual environment using python3.12
RUN python3 -m venv /testbed/testbed-venv

# Install dependencies inside the virtual environment
RUN /bin/bash -c "source /testbed/testbed-venv/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt && \
    pip install -e ."

# Add virtual environment activation to bashrc
RUN echo "source /testbed/testbed-venv/bin/activate" >> /root/.bashrc
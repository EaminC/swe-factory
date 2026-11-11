FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and tools
RUN apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3-pip \
    python3.10-distutils \
    curl \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.10 and pip is installed for python3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    python3 -m pip install --upgrade pip setuptools wheel

# Create working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit SHA
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed && \
    git reset --hard 9dbddfcbdd69cc064992266aa2a295c110948e33 && \
    git remote remove origin

# Create virtual environment and activate it, then install project dependencies
RUN python3 -m venv /testbed/venv

# Install dependencies inside the virtual environment (including dev installation of the repo)
RUN source /testbed/venv/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install -e . && \
    pip install pytest pytest-cov

# Add virtual environment activation to bashrc for interactive use
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc
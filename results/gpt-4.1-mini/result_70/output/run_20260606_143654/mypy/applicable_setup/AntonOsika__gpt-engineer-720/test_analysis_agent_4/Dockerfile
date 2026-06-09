FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies and tools
RUN apt-get update && apt-get install -y \
    git \
    python3.10 \
    python3.10-venv \
    python3-pip \
    python3.10-distutils \
    curl \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set locale (ensure UTF-8 support)
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Setup python3 as default python command
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && python --version

# Upgrade pip, setuptools, and wheel to latest
RUN python -m pip install --upgrade pip setuptools wheel

# Set workdir for the repository
WORKDIR /testbed/

# Clone the repo and checkout specific commit
ARG COMMIT_SHA=2058edb3cfb8764cf642d73035af4bb6c783b7e5
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed/ \
    && cd /testbed/ \
    && git reset --hard ${COMMIT_SHA}

# Create virtual environment and install repo plus test dependencies (including langchain via repo dependencies)
RUN python -m venv /testbed/venv

RUN /bin/bash -c "source /testbed/venv/bin/activate \
    && pip install --upgrade pip setuptools wheel \
    && pip install -e . \
    && pip install pytest pytest-cov"

# Add virtual environment activation to root user's bashrc for convenience
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc

# Default shell set to bash
ENV SHELL=/bin/bash